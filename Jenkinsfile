pipeline {
    agent {
        kubernetes {
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
            '''
        }
    }

    stages {
        stage('CI') {
            git ""
            container('jnlp')
            steps {
                echo 'Building..'
            }
        }
        stage('CD') {
            container('jnlp')
            steps {
                echo 'Deploying..'
            }
        }
    }
}