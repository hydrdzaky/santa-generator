pipeline {
    agent any
    tools{
        jdk 'jdk17'
        maven 'maven3'
    }
    environment{
        SCANNER_HOME= tool 'sonar-scanner'
        IMAGE_VERSION = "${env.BUILD_NUMBER}"
        LAST_CLOUD_RUN_REVISION = "back-end-${currentBuild.previousBuild.getNumber()}"
        IMAGE_NAME = "gcr.io/proyekdicoding-416705>/santasecret.${IMAGE_VERSION}"
        PREVIOUS_IMAGE_NAME = "gcr.io/proyekdicoding-416705>/santasecret.${currentBuild.previousBuild.getNumber()}"
    }

    stages {
        stage('git-checkout') {
            steps {
                git 'https://github.com/hydrdzaky/santa-generator.git'
            }
        }

        stage('Code-Compile') {
            steps {
               sh "mvn clean compile"
            }
        }
        
        stage('Unit Tests') {
            steps {
               sh "mvn test"
            }
        }
        
		stage('OWASP Dependency Check') {
            steps {
               dependencyCheck additionalArguments: ' --scan ./ ', odcInstallation: 'DC'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }


        stage('Sonar Analysis') {
            steps {
               withSonarQubeEnv('sonar'){
                   sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Santa \
                   -Dsonar.java.binaries=. \
                   -Dsonar.projectKey=Santa '''
               }
            }
        }

		 
        stage('Code-Build') {
            steps {
               sh "mvn clean package"
            }
        }

         stage('Docker Build') {
            steps {
               script{
                   withDockerRegistry(credentialsId: 'docker-cred') {
                    sh "docker build -t  santa123 . "
                 }
               }
            }
        }

        stage('Docker Push') {
            steps {
               script{
                   withDockerRegistry(credentialsId: 'docker-cred') {
                    sh "docker tag santa123 adijaiswal/santa123:latest"
                    sh "docker push adijaiswal/santa123:latest"
                 }
               }
            }
        }
        
        	 
        stage('Docker Image Scan') {
            steps {
               sh "trivy image ${IMAGE_NAME} "
            }
        }
        

		stage ("Remove last docker image"){
            steps{
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh "docker rmi -f ${PREVIOUS_IMAGE_NAME}"
                }
            }
        }
        stage("Build new docker image"){
            steps{
                sh "docker build --tag=${IMAGE_NAME} . --file=docker/Dockerfile"
            }
        }
        stage("Push to Google Container Registry"){
            steps{
                sh "docker push ${IMAGE_NAME}"
            }
        }
        stage("Delete last image from Container Registry"){
            steps{
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh "gcloud container images delete ${PREVIOUS_IMAGE_NAME}"
                }
            }
        }
        stage("Deploy new image to Cloud Run"){
            steps{
                sh "gcloud run deploy back-end --image  ${IMAGE_NAME} --platform=managed --region=us-central1 --port=8080 --revision-suffix=${IMAGE_VERSION}"
            }
        }
        stage("Delete last Cloud Run revision"){
            steps{
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh "yes | gcloud run revisions delete ${LAST_CLOUD_RUN_REVISION} --platform=managed --region=us-central1"
                }
            }
        }
    }

        post {
            always {
                emailext (
                    subject: "Pipeline Status: ${BUILD_NUMBER}",
                    body: '''<html>
                                <body>
                                    <p>Build Status: ${BUILD_STATUS}</p>
                                    <p>Build Number: ${BUILD_NUMBER}</p>
                                    <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                                </body>
                            </html>''',
                    to: 'haydar.dzaky@gmail.com',
                    from: 'jenkins@example.com',
                    replyTo: 'jenkins@example.com',
                    mimeType: 'text/html'
                )
            }
        }
}
