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
                      image: docker:17-dind
                      securityContext:
                        privileged: true  
            '''.stripIndent() 
        }
    }

    stages {
        stage("Get commit msg") {
            steps {
                container('jnlp') {
                    script {
                        env.GIT_COMMIT_MSG = sh (script: 'git log -1 --pretty=%B ${GIT_COMMIT}', returnStdout: true).trim()
                    }  
                }
            }
        } 

        stage("Build nginx and php images") {
            when {
                expression {
                    return env.GIT_BRANCH == "origin/master"
                }
            }
            steps {
                container('dind') {
                    script {
                        nginx = docker.build("norogh/php-app-eks:${env.GIT_COMMIT}", "--target", "stage-nginx", ".")
                        php = docker.build("norogh/php-app-eks:${env.GIT_COMMIT}", "--target", "stage-php", "." )
                    }
                }
            }
        }

        stage("Push php image") {
            when {
                expression {
                    return env.GIT_BRANCH == "origin/master"
                }
            }       
            steps {
                script {
                    docker.withRegistry('public.ecr.aws/y6q8o0k2', 'php_image') {
                        php.push("${env.GIT_COMMIT}")
                    }
                }
            }
        }

        stage("Push nginx image") {
            when {
                expression {
                    return env.GIT_BRANCH == "origin/master"
                }
            }       
            steps {
                script {
                    docker.withRegistry('public.ecr.aws/y6q8o0k2', 'nginx_image') {
                        nginx.push("${env.GIT_COMMIT}")
                    }
                }
            }
        }

        stage ('Starting CD') {
            when {
                expression {
                    return env.GIT_BRANCH == "origin/master"
                }
            }        
            steps {
                build job: 'app cd', parameters: [[$class: 'StringParameterValue', name: 'dockertag', value: "${env.GIT_COMMIT}"]]
            }
        }
    }
}