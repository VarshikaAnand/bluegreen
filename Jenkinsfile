pipeline {
    agent any

    environment {
        IMAGE = 'varshika05/bluegreen-dash'
        DOCKER_CREDS = credentials('dockerhub-login')
    }

    stages {

        stage('Checkout Code') {
            steps {
                // Fetch the 'main' branch explicitly to avoid branch issues
                git branch: 'main', url: 'https://github.com/VarshikaAnand/bluegreen'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                echo "🛠️  Building Docker image: $IMAGE"
                docker build -t $IMAGE:latest ./app
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh """
                echo "Logging in to Docker Hub..."
                echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin
                echo "Pushing image $IMAGE:latest"
                docker push $IMAGE:latest
                """
            }
        }

        stage('Deploy Blue-Green') {
            steps {
                sh """
                echo "Starting Blue-Green deployment..."
                bash scripts/deploy_blue_green.sh
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
