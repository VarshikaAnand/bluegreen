pipeline {
    agent any
    environment {
        IMAGE = 'varshika05/bluegreen-dash'
        DOCKER_CREDS = credentials('dockerhub-login')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/VarshikaAnand/bluegreen.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                docker build -t %IMAGE%:latest ./app
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                bat '''
                echo %DOCKER_CREDS_PSW% | docker login -u %DOCKER_CREDS_USR% --password-stdin
                docker push %IMAGE%:latest
                '''
            }
        }

        stage('Deploy Blue-Green') {
            steps {
                bat 'powershell -ExecutionPolicy Bypass -File scripts/deploy_blue_green.ps1'
            }
        }
    }
}
