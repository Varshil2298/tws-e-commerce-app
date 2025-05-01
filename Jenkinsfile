pipeline {
    agent any 
    tools {
        nodejs 'nodejs'
    }
    environment  {
        AWS_ACCOUNT_ID = credentials('ACCOUNT_ID')
        AWS_ECR_REPO_NAME = credentials('ECR_REPO')
        AWS_DEFAULT_REGION = 'ap-south-1'
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/"
    }
    stages {
        stage('Cleaning Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout from Git') {
            steps {
                git branch: 'master', credentialsId: 'GITHUB', url: 'https://github.com/Varshil2298/tws-e-commerce-app.git'
            }
        }
        // stage('Sonarqube Analysis') {
        //     steps {
        //         dir('vote') {
        //             withSonarQubeEnv('sonar-server') {
        //                 sh ''' $SCANNER_HOME/bin/sonar-scanner \
        //                 -Dsonar.projectName=frontend \
        //                 -Dsonar.projectKey=frontend '''
        //             }
        //         }
        //     }
        // }
        // stage('Quality Check') {
        //     steps {
        //         script {
        //             waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
        //         }
        //     }
        // }
        // stage('OWASP Dependency-Check Scan') {
        //     steps {
        //         dir('Application-Code/frontend') {
        //             dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
        //             dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        //         }
        //     }
        // }
        // stage('Trivy File Scan') {
        //     steps {
        //         dir('vote') {
        //             sh 'trivy fs . > trivyfs.txt'
        //         }
        //     }
        // }
        stage("Docker Image Build") {
            steps {
                script {
                    dir('') {
                            sh 'docker system prune -f'
                            sh 'docker container prune -f'
                            sh 'docker build -t ${AWS_ECR_REPO_NAME} .'
                    }
                }
            }
        }
        stage("ECR Image Pushing") {
           steps {
               withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-key']]) {
                    script {
                        sh '''
                            aws ecr get-login-password --region $AWS_DEFAULT_REGION | \
                            docker login --username AWS --password-stdin $REPOSITORY_URI
                            docker tag $AWS_ECR_REPO_NAME $REPOSITORY_URI/$AWS_ECR_REPO_NAME:$BUILD_NUMBER
                            docker push $REPOSITORY_URI/$AWS_ECR_REPO_NAME:$BUILD_NUMBER
                        '''
                    }
               }
        }               
    }
        stage("TRIVY Image Scan") {
            steps {
                sh 'trivy image ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${BUILD_NUMBER} > trivyimage.txt' 
            }
        }
        stage('Checkout Code') {
            steps {
                git branch: 'master', credentialsId: 'GITHUB', url: 'https://github.com/Varshil2298/tws-e-commerce-app.git'
            }
        }

        stage('Update K8s Manifest with Image') {
            steps {
                dir('kubernetes') {
                    script {
                        def imageTag = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${AWS_ECR_REPO_NAME}:${BUILD_NUMBER}"
                        echo "Updating image in 08-easyshop-deployment.yaml..."
                        sh "sed -i 's|image: .*|image: ${imageTag}|' 08-easyshop-deployment.yaml"
                        echo "Updated image to ${imageTag}"
                    }
                }
            }
        }

        stage('Push Updated Manifest to GitHub') {
            environment {
                GIT_REPO_NAME = "tws-e-commerce-app"
                GIT_USER_NAME = "Varshil2298"
    }
            steps {
                dir('kubernetes') {
                    withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                        sh '''
                            git config user.email 'devopstest@gmail.com'
                            git config user.name 'Varshil2298'
                            git add 08-easyshop-deployment.yaml
                            git commit -m "Update Kubernetes manifest with image tag ${BUILD_NUMBER}"
                            git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:master
                        '''
                   }
                }
           }
       
        }
    }
}          
