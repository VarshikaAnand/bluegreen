pipeline {
    agent any

    environment {
        IMAGE = 'varshika05/bluegreen-dash'
        DOCKER_CREDS = credentials('dockerhub-login')
    }

    options {
        // ensures Jenkins actually performs the SCM checkout step
        skipDefaultCheckout(false)
    }

    stages {

        stage('Verify Workspace') {
            steps {
                sh '''
                echo "✅ Checking workspace contents before build..."
                pwd
                ls -la
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "🛠️  Building Docker image: $IMAGE"
                docker build -t $IMAGE:latest ./app
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh '''
                echo "🔑 Logging in to Docker Hub..."
                echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin
                echo "📦 Pushing image $IMAGE:latest"
                docker push $IMAGE:latest
                '''
            }
        }

        stage('Deploy Blue-Green') {
            steps {
                sh '''
                echo "🚀 Starting Blue-Green deployment..."
                bash scripts/deploy_blue_green.sh
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
