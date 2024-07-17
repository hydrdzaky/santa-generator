pipeline {
    agent any
    tools{
        jdk 'jdk17'
        maven 'maven3'
        terraform 'terraform'

    }
    environment{
        SCANNER_HOME= tool 'sonar-scanner'
        IMAGE_VERSION = "${env.BUILD_NUMBER}"
        IMAGE_NAME = "santasecret.${IMAGE_VERSION}"
        GCLOUD_CREDS=credentials('gcloud-creds')
    }

    stages {
        /*stage('git-checkout') {
            steps {
                git 'https://github.com/hydrdzaky/santa-generator.git'
            }
        }*/

        stage('Code-Compile') {
            steps {
               sh "mvn clean compile"
            }
        }
        
        stage('Code-Tests') {
            steps {
               sh "mvn test"
            }
        }

        stage('Sonar Analysis') {
            steps {
               withSonarQubeEnv('sonarqube'){
                   sh ''' $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=SecretSanta \
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=SecretSanta '''
               }
            }
        }

        stage('Quality Gate Sonar') {
            steps {
                script {
                  waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            }
        }
        
		stage('OWASP Dependency Check') {
            steps {
               dependencyCheck additionalArguments: ' --scan ./ ', odcInstallation: 'DP-check'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

		 
        stage('Code-Build') {
            steps {
               sh "mvn clean package"
            }
        }

        stage('Authenticate service account') {
            steps {
                sh '''
                gcloud auth activate-service-account privy-super-account@constant-jigsaw-414207.iam.gserviceaccount.com --key-file="$GCLOUD_CREDS" --project=constant-jigsaw-414207
                '''
                sh 'gcloud config set project constant-jigsaw-414207'
            }
        }

        stage('build and push'){
            steps {
                echo 'Authentication stage for push to GCR'
                sh 'gcloud auth list'
                sh 'gcloud auth configure-docker asia.gcr.io'
                sh 'docker build . -t asia.gcr.io/constant-jigsaw-414207/secretsanta:v$BUILD_NUMBER'
                sh 'docker push asia.gcr.io/constant-jigsaw-414207/secretsanta:v$BUILD_NUMBER'
            }
        }

        stage("Build the service of cloud run using Terraform"){
            steps{
                echo 'updating the service of cloud run with latest image using terraform'
                sh 'terraform init'
                sh 'terraform plan -var tags="v$BUILD_NUMBER" -var credskey="$GCLOUD_CREDS"'
                sh 'terraform apply --auto-approve -var tags="v$BUILD_NUMBER" -var credskey="$GCLOUD_CREDS"'
            }
        }

        /*stage("Build the service of cloud run using Gcloud CLI"){
            steps{
                sh '''
                gcloud run deploy secretsanta$BUILD_NUMBER \
                --image=gcr.io/proyekdicoding-416705/secretsanta:v$BUILD_NUMBER \
                --allow-unauthenticated \
                --port=8080 \
                --service-account=jenkins-gcloud@proyekdicoding-416705.iam.gserviceaccount.com \
                --max-instances=10 \
                --region=us-central1 \
                --project=proyekdicoding-416705
                '''
            }
        }*/
    }

    post {
        always {
            discordSend description: '', enableArtifactsList: true, footer: '', image: '', link: '', result: '', scmWebUrl: '', showChangeset: true, thumbnail: '', title: '', webhookURL: 'https://discordapp.com/api/webhooks/1221715538728849450/LH2KZSJEc1PMqwi3iqPZpvA9FsQT5-nRUBDuReyuCxGdReUmHyR_Z2mfPbCWPUqqNm2y'
        }
    }
}
