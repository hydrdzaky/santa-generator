pipeline {
    agent any
    tools{
        jdk 'jdk17'
        maven 'maven3'
    }
    environment{
        SCANNER_HOME= tool 'sonar-scanner'
        IMAGE_VERSION = "${env.BUILD_NUMBER}"
        IMAGE_NAME = "santasecret.${IMAGE_VERSION}"
        CLOUDSDK_CORE_PROJECT='proyekdicoding-416705'
        CLIENT_EMAIL='4820298729-compute@developer.gserviceaccount.com'
        CLOUD_CREDS=credentials('gcloud-creds')
    }

    stages {
        // stage('git-checkout') {
        //     steps {
        //         git 'https://github.com/hydrdzaky/santa-generator.git'
        //     }
        // }

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
               dependencyCheck additionalArguments: ' --scan ./ ', odcInstallation: 'DP-check'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }


        // stage('Sonar Analysis') {
        //     steps {
        //        withSonarQubeEnv('sonar'){
        //            sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Santa \
        //            -Dsonar.java.binaries=. \
        //            -Dsonar.projectKey=Santa '''
        //        }
        //     }
        // }

		 
        stage('Code-Build') {
            steps {
               sh "mvn clean package"
            }
        }

         stage('Docker Build') {
            steps {
               script{
                   withDockerRegistry(credentialsId: 'daf7a33e-03ef-480b-be60-ba7513d8a509') {
                    sh "docker build -t  ${IMAGE_NAME} . "
                 }
               }
            }
        }

        stage('Docker Push') {
            steps {
               script{
                   withDockerRegistry(credentialsId: 'daf7a33e-03ef-480b-be60-ba7513d8a509') {
                    sh "docker tag santa123 haydardzaky123/${IMAGE_NAME}"
                    sh "docker push haydardzaky123/${IMAGE_NAME}"
                 }
               }
            }
        }

    stage('Verify version') {
      steps {
        sh '''
          gcloud version
        '''
      }
    }
    stage('Authenticate') {
      steps {
        sh '''
          gcloud auth activate-service-account --key-file="$GCLOUD_CREDS"
        '''
      }
    }
    stage('Install service') {
      steps {
        sh '''
          gcloud run services replace service.yaml --platform='managed' --region='us-central1'
        '''
      }
    }
    stage('Allow allUsers') {
      steps {
        sh '''
          gcloud run services add-iam-policy-binding secretsanta --region='us-central1' --member='allUsers' --role='roles/run.invoker'
        '''
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
                    to: 'dr.stranger157@gmail.com',
                    from: 'haydar.dzaky@gmail.com',
                    replyTo: 'dr.stanger@gmail.com',
                    mimeType: 'text/html'
                )
                sh 'gcloud auth revoke $CLIENT_EMAIL'
            }
        }
}
