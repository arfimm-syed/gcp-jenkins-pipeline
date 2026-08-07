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

        stage('Terraform Setup & Plan') {
            steps {
                dir('env') {
                    // Injecting the token string directly as an environment variable
                    withCredentials([string(credentialsId: 'gcp-token', variable: 'GOOGLE_OAUTH_ACCESS_TOKEN')]) {
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
                anyOf {
                    changeRequest target: 'main'
                    branch 'main'
                }
            }
            steps {
                // 1. Pause for human approval FIRST. Token time will not waste while waiting.
                input message: 'Approve Terraform Apply?'
            
                dir('env') {
                    // 2. Fetch a brand new, fresh token the exact second "Proceed" is clicked.
                    withEnv(["GOOGLE_OAUTH_ACCESS_TOKEN=\$(gcloud auth print-access-token)"]) {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
    } // <-- Added this missing closing brace to properly end the 'stages' block

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
