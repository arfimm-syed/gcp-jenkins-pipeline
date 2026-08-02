pipeline {

    agent any

    environment {
        PROJECT_ID = "gcp-jenkins-pipeline"
        TF_IN_AUTOMATION = "true"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Authenticate to GCP') {
            steps {
                sh '''
                    gcloud auth list
                    gcloud config set project ${PROJECT_ID}
                    gcloud config list
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir('env') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Format Check') {
            steps {
                dir('env') {
                    sh 'terraform fmt -check'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('env') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('env') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {

            when {
                branch 'main'
            }

            steps {

                input message: 'Approve Terraform Apply?'

                dir('env') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

    }

    post {

        success {
            echo 'Terraform deployment completed successfully.'
        }

        failure {
            echo 'Terraform deployment failed.'
        }

        always {
            cleanWs()
        }
    }
}