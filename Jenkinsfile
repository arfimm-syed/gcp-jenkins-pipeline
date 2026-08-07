```groovy
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

        stage('Authenticate to GCP') {
            steps {
                sh '''
                    set -e

                    echo "========================================"
                    echo "GCP Workload Identity Authentication"
                    echo "========================================"

                    if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
                        echo "ERROR: WIF credential file does not exist:"
                        echo "$GOOGLE_APPLICATION_CREDENTIALS"
                        exit 1
                    fi

                    echo "WIF credential file found."

                    # Authenticate gcloud using the WIF credential
                    gcloud auth login \
                        --cred-file="$GOOGLE_APPLICATION_CREDENTIALS" \
                        --quiet

                    gcloud config set project "$PROJECT_ID"

                    echo ""
                    echo "Authenticated identity:"
                    gcloud auth list

                    echo ""
                    echo "Active project:"
                    gcloud config get-value project

                    echo ""
                    echo "Testing GCP access..."

                    gcloud storage ls gs://arfimm-bucket

                    echo ""
                    echo "GCP authentication successful."
                '''
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
```
