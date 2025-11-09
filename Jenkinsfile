pipeline {
    agent any

    environment {
        IMAGE = 'varshika05/bluegreen-dash'
        DOCKER_CREDS = credentials('dockerhub-login')
    }

    stages {

        stage('Checkout Code') {
            steps {
                // Explicitly fetch the 'main' branch to avoid branch resolution issues
                git branch: 'main', url: 'https://github.com/VarshikaAnand/bluegreen.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat """
                echo Building Docker image: %IMAGE%
                docker build -t %IMAGE%:latest ./app
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                bat """
                echo Logging in to Docker Hub...
                echo %DOCKER_CREDS_PSW% | docker login -u %DOCKER_CREDS_USR% --password-stdin
                echo Pushing image %IMAGE%:latest
                docker push %IMAGE%:latest
                """
            }
        }

        stage('Deploy Blue-Green') {
            steps {
                bat """
                echo Starting Blue-Green deployment...
                powershell -ExecutionPolicy Bypass -File scripts\\deploy_blue_green.ps1
                """
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
