pipeline {
    agent {
        kubernetes {
            defaultContainer 'dind'
            yaml '''
                apiVersion: v1
                kind: Pod
                metadata:
                  labels:
                    jenkins/kube-default: "true"
                    app: jenkins
                    component: agent                
                spec:
                    containers:
                    - name: jnlp
                      image: jenkinsci/jnlp-slave
                      imagePullPolicy: Always
                      env:
                      - name: POD_IP
                        valueFrom:
                            fieldRef:
                                fieldPath: status.podIP
                    - name: dind
                      image: docker:20.10.8-dind
                      env:
                      - name: AWS_ACCESS_KEY_ID
                        value: AKIAT7LGXONOC3PQR62Q
                      - name: AWS_SECRET_ACCESS_KEY
                        value: 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
                      lifecycle:
                        postStart:
                          exec:
                            command: 
                            - "sh" 
                            - "-c" 
                            - |
                              apk add --no-cache python3 py3-pip
                              pip3 install --upgrade pip
                              pip3 install awscli
                      securityContext:
                        privileged: true 
            '''.stripIndent() 
        }
    }

    stages {

        stage("Build nginx and php images") {
            when {
                expression {
                    return env.GIT_BRANCH == "origin/master"
                }
            }
            steps {
                container('dind') {
                    script {
                        nginx = docker.build("norogh/php-app-eks:${env.GIT_COMMIT}", "--target stage-nginx .")
                        php = docker.build("norogh/php-app-eks:${env.GIT_COMMIT}", "--target stage-php ." )
                    }
                }
            }
        }

        stage('ECR Login php') {
            steps {
                container('dind') {
                    sh """aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/y6q8o0k2"""
                }
            } 
        } 

        stage("Push php image") {      
            steps {
                container('dind') {
                    script {
                        sh """docker tag php_image:${env.GIT_COMMIT} public.ecr.aws/y6q8o0k2/php_image:${env.GIT_COMMIT}"""
                        sh """docker push public.ecr.aws/y6q8o0k2/php_image:${env.GIT_COMMIT}"""
                        
                        }
                    }
                }   
            }
        }

        stage('ECR Login nginx') {
            steps {
                container('dind') {
                    sh """aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/y6q8o0k2"""
                }
            } 
        } 
        stage("Push nginx image") {    
            steps {
                container('dind') {
                    script {
                        docker.withRegistry('https://public.ecr.aws/y6q8o0k2', 'nginx_image') {
                            nginx.push("${env.GIT_COMMIT}")
                        }
                    }
                }    
            }
        }

        stage ('Starting CD') {    
            steps {
                build job: 'app cd', parameters: [[$class: 'StringParameterValue', name: 'dockertag', value: "${env.GIT_COMMIT}"]]
            }
        }
    }
}