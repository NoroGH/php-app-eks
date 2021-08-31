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
                      command:
                      - /bin/sh
                      - -c
                      - sleep 24h
                    - name: dind
                      image: docker:17-dind
                      command:
                      - sh 
                      - -c
                      - tail -f /dev/null
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

        stage("Build nginx image") {
            when {
                expression {
                    return env.GIT_BRANCH == "origin/master"
                }
            }
            steps {
                script {
                    nginx = docker.build("NoroGH/php-app-eks:${env.GIT_COMMIT}", "--target stage-nginx -f ./Dockerfile .")
                }
            }
        }

        stage("Build php image") {
            when {
                expression {
                    return env.GIT_BRANCH == "origin/master"
                }
            }
            steps {
                script {
                    php = docker.build("NoroGH/php-app-eks:${env.GIT_COMMIT}", "--target stage-php -f ./Dockerfile .")
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