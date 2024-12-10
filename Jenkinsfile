pipeline {
  agent any

  environment {
    DOCKER_CREDS_USR = credentials('DOCKER_CREDS_USR')
    DOCKER_CREDS_PSW = credentials('DOCKER_CREDS_PSW')
    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_KEY')
    //DEV_KEY =credentials('dev_key')
    XAI_KEY = credentials('XAI_KEY')
  }

    stages {
        // stage('Build') {
        //     steps {
        //         script {
        //             sh '''
        //             chmod +x ./CICD_Scripts/frontend.sh
        //             ./CICD_Scripts/frontend.sh
        //             chmod +x ./CICD_Scripts/backend.sh
        //             ./CICD_Scripts/backend.sh
        //             '''

        //               }
        //           } 
        //       }
    

        // stage ('Sec-Check: OWASP') {
        //     environment {
        //         NVD_APIKEY = credentials("NVD-ApiKey")
        //     }
        //     steps {
        //         dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey ${NVD_APIKEY}', odcInstallation: 'DP-Check'
        //         dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
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

    // stage('Build & Push Images') {
    //     agent { label 'build-node' }
    //     steps {
    //         // Log in to Docker Hub
    //         sh 'echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin'
            
    //         // Inject API Key
    //         withCredentials([string(credentialsId: 'XAI_KEY', variable: 'XAI_KEY')]) {
    //             // Build and push backend
    //             sh '''
    //               echo "Current directory: $(pwd)"
    //               docker build --build-arg XAI_KEY=${XAI_KEY} -t ${DOCKER_CREDS_USR}/farseer_back:latest -f ./docker/back.Dockerfile .
    //               docker push ${DOCKER_CREDS_USR}/farseer_back:latest
    //             '''
                
    //             // Build and push frontend
    //             sh '''
    //               docker build -t ${DOCKER_CREDS_USR}/farseer_front:latest -f ./docker/front.Dockerfile .
    //               docker push ${DOCKER_CREDS_USR}/farseer_front:latest
    //             '''
    //         }
    //     }
    // }
    

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
                } else if (env.BRANCH_NAME == 'qa-eks-test') {
                    echo "Deploying to Testing Environment"
                    dir('Terraform/QA') { // Navigate to the qa environment directory
                        sh '''
                          echo "Current working directory:"
                          echo "terraform init + apply"
                          pwd
                          terraform init
                          terraform destroy -auto-approve

                          # configure kubectl
                          echo "configuring kubectl"
                          eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=qa-eks-cluster --approve


                          # test connection
                          echo "describe cluster"
                          aws eks describe-cluster --name qa-eks-cluster --region us-east-1
                          echo "testing connection"
                          kubectl get nodes --request-timeout=5m

                          # create xai key secret from secrets yaml
                          kubectl create secret generic farseer-secret \
                            --from-literal=XAI_KEY=${XAI_KEY} \
                            --dry-run=client -o yaml | kubectl apply -f - --validate=false

                          # Get the IAM role ARN and annotate the service account
                          ROLE_ARN=$(terraform output -raw aws_load_balancer_controller_role_arn || aws_iam_role.aws_load_balancer_controller_role.arn)
                          kubectl annotate serviceaccount aws-load-balancer-controller \
                            -n kube-system \
                            eks.amazonaws.com/role-arn=$ROLE_ARN \
                            --overwrite


                          # deploy k8s resources
                          echo "deploying k8s resources"
                          kubectl apply -f k8s/backend-deployment.yaml --validate=false
                          kubectl apply -f k8s/backend-service.yaml --validate=false
                          kubectl apply -f k8s/frontend-deployment.yaml --validate=false
                          kubectl apply -f k8s/frontend-service.yaml --validate=false
                          kubectl apply -f k8s/frontend-ingress.yaml --validate=false

                          # wait for deployments to complete
                          echo "waiting for deployments to complete"
                          kubectl wait --for=condition=available --timeout=600s deployment/backend
                          kubectl wait --for=condition=available --timeout=600s deployment/frontend

                          # verify deployments
                          echo "verifying deployments"
                          kubectl get nodes
                          kubectl get pods
                          kubectl get services
                          kubectl get ingress

                          # check if all pods are running
                          echo "checking if all pods are running"
                          if kubectl get pods | grep -v Running | grep -v Completed | grep -v NAME; then
                            echo "pods are not running"
                            exit 1
                          fi
                        '''
                    }
                } else if (env.BRANCH_NAME == 'develop') {
                    echo "Deploying to Staging Environment"
                    dir('Terraform/Dev') { // Navigate to the staging environment directory
                        sh '''
                          echo "Current working directory:"
                          pwd
                          terraform init
                          terraform apply -auto-approve \
                            -var dev_key="${DEV_KEY}" \
                            -var DOCKER_CREDS_USR="${DOCKER_CREDS_USR}" \
                            -var DOCKER_CREDS_PSW="${DOCKER_CREDS_PSW}" \
                            -var XAI_KEY="${XAI_KEY}"      
                        '''
                    }
                } else if (env.BRANCH_NAME.startsWith('feature/')) {
                    echo "Deploying to Staging Environment"
                    dir('Terraform/Dev') { // Navigate to the staging environment directory
                        sh '''
                          echo "Current working directory:"
                          pwd
                          terraform init
                          terraform destroy -auto-approve \
                            -var DOCKER_CREDS_USR="${DOCKER_CREDS_USR}" \
                            -var DOCKER_CREDS_PSW="${DOCKER_CREDS_PSW}" \
                            -var XAI_KEY="${XAI_KEY}"
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
    // stage('logout') {
    //   agent { label 'build-node' } // Specify your preferred agent here
    //   steps {
    //     sh '''
    //       docker logout
    //       docker system prune -f
    //     '''
    //   }
    // }



    // stage('Destroy') {
    //   agent { label 'build-node' }
    //   steps {
    //     dir('Terraform/Dev') {
    //       sh ''' 
    //         terraform destroy -auto-approve
    //       '''
    //     }
    //   }
    // }
    }
        }
  






