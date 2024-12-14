# CI/CD Pipeline for Application Deployment

This Jenkins pipeline automates the process of building, testing, securing, and deploying an application across multiple environments. It leverages Docker, Terraform, and security tools to streamline the entire lifecycle of the application. Below is an overview of each stage in the pipeline.

## High-Level Workflow

1. **Build**: Compiles the frontend and backend components by running specific shell scripts for each part of the application.
2. **Security Check**: Executes a security scan using OWASP Dependency-Check to identify known vulnerabilities in third-party libraries and dependencies.
3. **Cleanup**: Cleans up unused Docker resources and unnecessary files in the Git repository to maintain a clean working environment.
4. **Build & Push Docker Images**: Builds Docker images for the frontend and backend services, injects necessary API keys, and pushes them to Docker Hub for containerization and distribution.
5. **Deploy**: Deploys the application to the appropriate environment (Production, QA, or Staging) using Terraform scripts. This stage is environment-aware and adapts based on the branch being built.
6. **Logout**: Logs out from Docker Hub and performs final cleanup to remove any remaining unused Docker images and resources.

## Detailed Breakdown

### 1. Build
In this stage, the pipeline executes shell scripts that build both the frontend and backend components of the application. These scripts are made executable and run sequentially to ensure that the application is properly compiled before moving on to the next stage.

### 2. Security Check: OWASP Dependency-Check
This stage performs a security scan of the application’s dependencies using OWASP Dependency-Check. It analyzes the codebase for known vulnerabilities in third-party libraries and reports any issues, helping to ensure the application is secure and free from critical security flaws.

### 3. Cleanup
After the build and security checks, this stage cleans up the build environment. Docker resources, such as unused containers and images, are pruned, and Git clean is used to remove untracked files and directories (e.g., `.terraform` state files), ensuring that the workspace remains tidy and free from unnecessary clutter.

### 4. Build & Push Docker Images
In this stage, the pipeline builds Docker images for both the frontend and backend services. It also authenticates with Docker Hub using stored credentials and pushes the newly created images to Docker Hub, making them available for deployment across various environments. API keys are injected into the build process, ensuring that sensitive information is handled securely.

### 5. Deploy
This stage is responsible for deploying the application to different environments (Production, QA, or Staging) based on the branch being built. For production and QA branches, it uses Terraform to provision and apply the necessary infrastructure configurations, while for development and feature branches, it deploys to a staging environment. Each environment is configured separately, ensuring that the application is deployed correctly according to the target environment's requirements.

### 6. Logout
In the final stage, the pipeline logs out from Docker Hub to maintain security and then cleans up any remaining unused Docker resources, ensuring that the build environment is ready for the next pipeline run.

## Key Environment Variables

- **DOCKER_CREDS_USR**: Docker Hub username for image authentication.
- **DOCKER_CREDS_PSW**: Docker Hub password for image authentication.
- **AWS_ACCESS_KEY_ID**: AWS access key used for deploying resources.
- **AWS_SECRET_ACCESS_KEY**: AWS secret key used for deploying resources.
- **DEV_KEY**: Development key used for staging deployments.
- **XAI_KEY**: API key injected into the backend Docker image during the build process.

## Requirements

- Jenkins with Docker installed and configured.
- Terraform and AWS CLI installed on the build nodes.
- Terraform configuration files for each environment (Production, QA, and Dev).
- Docker Hub credentials stored securely in Jenkins.

## Conclusion

This CI/CD pipeline streamlines the application lifecycle, automating tasks such as building, securing, and deploying the application to multiple environments. It integrates essential tools such as Docker, Terraform, and OWASP Dependency-Check to ensure a smooth, secure, and efficient deployment process.
