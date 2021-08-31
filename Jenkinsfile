pipeline {
    agent {
        kubernetes {
            defaultContainer 'dind'
            yaml '''
                apiVersion: v1
                kind: Pod
                metadata:
                    namespace: ci-cd
                spec:
                    containers:
                    - name: jnlp
                        image: public.ecr.aws/y6q8o0k2/jenkins_dockercli
                        command:
                        - /bin/sh
                        - -c
                        - export DOCKER_HOST="tcp://localhost:2375"
                    - name: dind
                        image: docker:17-dind
                        securityContext:
                            privileged: true 
            '''
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