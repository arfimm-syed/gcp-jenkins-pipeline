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

        stage('Authenticate to GCP CLI') {
            steps {
                sh '''
                    gcloud auth list
                    gcloud config set project ${PROJECT_ID}
                    gcloud config list
                '''
            }
        }

        stage('Terraform Setup & Plan') {
            steps {
                dir('env') {
                    // Copy the credentials into the active terraform directory
                    sh 'cp /mnt/c/Users/afzal/Downloads/clientLibraryConfig-jenkins-provider.json .'
                    
                    // Set environment variable and run the core validation and planning steps
                    withEnv(["GOOGLE_APPLICATION_CREDENTIALS=${WORKSPACE}/env/clientLibraryConfig-jenkins-provider.json"]) {
                        sh 'terraform init'
                        sh 'terraform fmt -check'
                        sh 'terraform validate'
                        sh 'terraform plan -out=tfplan'
                    }
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
                    // Ensure credentials are also present for the apply step
                    withEnv(["GOOGLE_APPLICATION_CREDENTIALS=${WORKSPACE}/env/clientLibraryConfig-jenkins-provider.json"]) {
                        sh 'terraform apply -auto-approve tfplan'
                    }
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
