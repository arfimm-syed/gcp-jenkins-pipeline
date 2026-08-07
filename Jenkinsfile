pipeline {

    agent any

    environment {
        PROJECT_ID       = "gcp-jenkins-pipeline"
        TF_IN_AUTOMATION = "true"
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

                        echo "========================================"
                        echo "GCP Authentication"
                        echo "========================================"

                        # Use the OAuth access token stored in Jenkins.
                        export CLOUDSDK_AUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"
                        export GOOGLE_OAUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"

                        # Make sure the old WIF configuration is not used.
                        unset GOOGLE_APPLICATION_CREDENTIALS

                        echo ""
                        echo "Testing GCP project access..."

                        gcloud projects describe "$PROJECT_ID" \
                            --format="value(projectId)"

                        echo ""
                        echo "Testing Terraform state bucket..."

                        gcloud storage ls gs://arfimm-bucket

                        echo ""
                        echo "GCP authentication successful."
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {

                withCredentials([
                    string(
                        credentialsId: 'gcp-token',
                        variable: 'GOOGLE_OAUTH_ACCESS_TOKEN'
                    )
                ]) {

                    dir('env') {

                        sh '''
                            set -e

                            echo "========================================"
                            echo "Terraform Init"
                            echo "========================================"

                            export CLOUDSDK_AUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"
                            export GOOGLE_OAUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"

                            unset GOOGLE_APPLICATION_CREDENTIALS

                            terraform init \
                                -input=false \
                                -reconfigure

                            echo ""
                            echo "Terraform init completed successfully."
                        '''
                    }
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

                        echo ""
                        echo "Terraform format check passed."
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {

                withCredentials([
                    string(
                        credentialsId: 'gcp-token',
                        variable: 'GOOGLE_OAUTH_ACCESS_TOKEN'
                    )
                ]) {

                    dir('env') {

                        sh '''
                            set -e

                            echo "========================================"
                            echo "Terraform Validate"
                            echo "========================================"

                            export CLOUDSDK_AUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"
                            export GOOGLE_OAUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"

                            unset GOOGLE_APPLICATION_CREDENTIALS

                            terraform validate

                            echo ""
                            echo "Terraform validation passed."
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {

                withCredentials([
                    string(
                        credentialsId: 'gcp-token',
                        variable: 'GOOGLE_OAUTH_ACCESS_TOKEN'
                    )
                ]) {

                    dir('env') {

                        sh '''
                            set -e

                            echo "========================================"
                            echo "Terraform Plan"
                            echo "========================================"

                            export CLOUDSDK_AUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"
                            export GOOGLE_OAUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"

                            unset GOOGLE_APPLICATION_CREDENTIALS

                            terraform plan \
                                -input=false \
                                -out=tfplan

                            echo ""
                            echo "Terraform plan completed successfully."
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {

            when {
                branch 'main'
            }

            steps {

                input message: 'Terraform plan completed. Approve infrastructure deployment?'

                withCredentials([
                    string(
                        credentialsId: 'gcp-token',
                        variable: 'GOOGLE_OAUTH_ACCESS_TOKEN'
                    )
                ]) {

                    dir('env') {

                        sh '''
                            set -e

                            echo "========================================"
                            echo "Terraform Apply"
                            echo "========================================"

                            export CLOUDSDK_AUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"
                            export GOOGLE_OAUTH_ACCESS_TOKEN="$GOOGLE_OAUTH_ACCESS_TOKEN"

                            unset GOOGLE_APPLICATION_CREDENTIALS

                            echo ""
                            echo "Testing GCP backend access..."

                            gcloud storage ls gs://arfimm-bucket

                            echo ""
                            echo "Applying Terraform plan..."

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

