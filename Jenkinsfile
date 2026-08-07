pipeline {

    agent any

    environment {
        PROJECT_ID       = "gcp-jenkins-pipeline"
        TF_IN_AUTOMATION = "true"

        // WIF external account credential configuration
        GOOGLE_APPLICATION_CREDENTIALS = "/var/lib/jenkins/gcp-wif.json"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('GCP Authentication') {
            steps {
               withCredentials([
             string(
                credentialsId: 'gcp-token',
                variable: 'GOOGLE_OAUTH_ACCESS_TOKEN'
            )
        ]) {
            sh '''
                set -e

                echo "Testing GCP authentication..."

                export CLOUDSDK_AUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"

                echo "Testing project access..."
                gcloud projects describe "$PROJECT_ID" \
                    --format="value(projectId)"

                echo "Testing Terraform bucket..."
                gcloud storage ls gs://arfimm-bucket

                echo "GCP authentication successful."
            '''
        }
    }
}

        stage('Terraform Init') {
            steps {
                dir('env') {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Terraform Init"
                        echo "========================================"

                        terraform init \
                            -input=false \
                            -reconfigure
                    '''
                }
            }
        }

        stage('Terraform Format') {
            steps {
                dir('env') {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Terraform Format Check"
                        echo "========================================"

                        terraform fmt -check -recursive
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('env') {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Terraform Validate"
                        echo "========================================"

                        terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('env') {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Terraform Plan"
                        echo "========================================"

                        terraform plan \
                            -input=false \
                            -out=tfplan

                        echo ""
                        echo "Terraform plan completed successfully."
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            when {
                branch 'main'
            }

            steps {

                input message: 'Terraform plan completed. Approve infrastructure deployment?'

                dir('env') {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Refreshing GCP WIF authentication"
                        echo "========================================"

                        # Refresh gcloud authentication after manual approval.
                        # This obtains fresh short-lived credentials.
                        gcloud auth login \
                            --cred-file="$GOOGLE_APPLICATION_CREDENTIALS" \
                            --quiet

                        gcloud config set project "$PROJECT_ID"

                        echo ""
                        echo "Authenticated identity:"
                        gcloud auth list

                        echo ""
                        echo "Testing backend access before apply..."

                        gcloud storage ls gs://arfimm-bucket

                        echo ""
                        echo "========================================"
                        echo "Terraform Apply"
                        echo "========================================"

                        terraform apply \
                            -input=false \
                            -auto-approve \
                            tfplan

                        echo ""
                        echo "Terraform apply completed successfully."
                    '''
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
