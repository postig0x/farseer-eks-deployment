pipeline {
  agent any

  environment {
    DOCKER_CREDS_USR = credentials('DOCKER_CREDS_USR')
    DOCKER_CREDS_PSW = credentials('DOCKER_CREDS_PSW')
    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_KEY')
    XAI_KEY = credentials('XAI_KEY')
    SONAR_TOKEN = credentials('SonarQube-Token')
    SONAR_SCANNER_HOME = tool 'SonarQube Scanner' // Name configured in Jenkins global tools
  }

    stages {
        stage('Build') {
            steps {
                script {
                    sh '''
                    chmod +x ./CICD_Scripts/frontend.sh
                    ./CICD_Scripts/frontend.sh
                    chmod +x ./CICD_Scripts/backend.sh
                    ./CICD_Scripts/backend.sh
                    '''

                      }
                  } 
              }
    

    //     stage('SonarQube Analysis') {
    //       agent { label 'build-node' }
    //         steps {
    //             withSonarQubeEnv('SonarQube Scanner') { // 'SonarQube' is the name configured in Jenkins
    //                 sh """
    //                 ${env.SONAR_SCANNER_HOME}/bin/sonar-scanner \
    //                     -Dsonar.projectKey=FARSEER \
    //                     -Dsonar.sources=FARSEER \
    //                     -Dsonar.host.url=http://localhost:9000 \
    //                     -Dsonar.login=${SONAR_TOKEN}
    //                 """
    //             }
    //         }
    //     }
    //     stage('Quality Gate') {
    //       agent { label 'build-node' }
    //         steps {
    //             timeout(time: 2, unit: 'MINUTES') { // Adjust timeout as necessary
    //                 waitForQualityGate abortPipeline: true
    //             }
    //         }
    //     }
    // }


      stage('Cleanup') {
        agent { label 'build-node' }
        steps {
          sh '''
            docker system prune -f
            git clean -ffdx -e "*.tfstate*" -e ".terraform/*"
          '''
        }
      }

    stage('Build & Push Images') {
        agent { label 'build-node' }
        steps {
            // Log in to Docker Hub
            sh 'echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin'
            
            // Inject API Key
            withCredentials([string(credentialsId: 'XAI_KEY', variable: 'XAI_KEY')]) {
                // Build and push backend
                sh '''
                  echo "Current directory: $(pwd)"
                  docker build --build-arg XAI_KEY=${XAI_KEY} -t ${DOCKER_CREDS_USR}/farseer_back:latest -f ./docker/back.Dockerfile .
                  docker push ${DOCKER_CREDS_USR}/farseer_back:latest
                '''
                
                // Build and push frontend
                sh '''
                  docker build -t ${DOCKER_CREDS_USR}/farseer_front:latest -f ./docker/front.Dockerfile .
                  docker push ${DOCKER_CREDS_USR}/farseer_front:latest
                '''
            }
        }
    }
    

    stage('Deploy') {
        agent { label 'build-node' }
        steps {
            script {
                if (env.BRANCH_NAME == 'production') {
                    echo "Deploying to Production Environment"
                    dir('Terraform/Production') { // Navigate to the production environment directory
                        sh '''
                          echo "Current working directory:"
                          pwd
                          terraform init
                          terraform apply -auto-approve
                        '''
                          // -var="dockerhub_username=${DOCKER_CREDS_USR}" \
                          //   -var="dockerhub_password=${DOCKER_CREDS_PSW}"
                    }
                } else if (env.BRANCH_NAME == 'qa') {
                    echo "Deploying to Testing Environment"
                    dir('Terraform/QA') { // Navigate to the qa environment directory
                        sh '''
                          echo "Current working directory:"
                          pwd
                          terraform init
                          terraform apply -auto-approve
                        '''
                    }
                } else if (env.BRANCH_NAME == 'develop') {
                    echo "Deploying to Staging Environment"
                    dir('Terraform/Dev') { // Navigate to the staging environment directory
                        sh '''
                          echo "Current working directory:"
                          pwd
                          terraform init
                          terraform apply -auto-approve
                        '''
                    }
                } else if (env.BRANCH_NAME.startsWith('feature/')) {
                    echo "Deploying to Staging Environment"
                    dir('Terraform/Dev') { // Navigate to the staging environment directory
                        sh '''
                          echo "Current working directory:"
                          pwd
                          terraform init
                          terraform destroy -auto-approve
                        '''
                    // echo "Skipping deployment for feature branch: ${env.BRANCH_NAME}"
                    }
                } else {
                    echo "No deployment for branch: ${env.BRANCH_NAME}"
                    error("Unknown branch: ${env.BRANCH_NAME}")
                }
            }
        }
    }
    
  

    // Add a Cleanup Stage Here
    stage('logout') {
      agent { label 'build-node' } // Specify your preferred agent here
      steps {
        sh '''
          docker logout
          docker system prune -f
        '''
      }
    }
    }
}

    // stage('Destroy') {
    //   agent { label 'build-node' }
    //   steps {
    //     dir('Terraform') {
    //       sh ''' 
    //         terraform destroy -auto-approve \
    //           -var="dockerhub_username=${DOCKER_CREDS_USR}" \
    //           -var="dockerhub_password=${DOCKER_CREDS_PSW}"
    //       '''
    //     }
    //   }
    // }
  






