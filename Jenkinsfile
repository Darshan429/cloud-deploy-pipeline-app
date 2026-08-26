pipeline {
    agent any

    environment {
        // Must match the credential ID you created in
        // Manage Jenkins > Credentials (Milestone 2).
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')

        // CHANGE THIS to your actual Docker Hub username/repo.
        IMAGE_NAME = 'darshan99015/clouddeploy-notes-api'

        // Short commit SHA makes each image traceable back to the exact
        // commit that produced it — this is the "traceability" point
        // interviewers ask about.
        IMAGE_TAG = "${env.GIT_COMMIT ? env.GIT_COMMIT.take(7) : env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

    stage('Install Dependencies') {
        steps {
            script {
                docker.image('node:20-alpine').inside('-e HOME=/tmp') {
                sh 'npm ci'
            }
        }
        }
    }

        stage('Unit Test') {
    steps {
        script {
            docker.image('node:20-alpine').inside('-e HOME=/tmp') {
                sh 'npm test'//added comment
            }
        }
    }
}

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
            }
        }

        // Milestone 4 will insert a Trivy Scan stage right here, between
        // build and push — deliberately left out for now.

        stage('Push Image') {
            steps {
                sh """
                    echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${IMAGE_NAME}:latest
                """
            }
        }
    }

    post {
        always {
            // Log out and clean up the local image so the Jenkins host's
            // disk doesn't slowly fill up with old image layers.
            sh "docker logout || true"
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest || true"
        }
        success {
            echo "Pipeline succeeded — pushed ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed — check the stage logs above for which step broke."
        }
    }
}
//webhook test