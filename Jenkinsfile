pipeline{
	agent any

	tools {
        maven 'maven-jenkins'  // Nome que você deu na configuração
    }

	environment {
        AWS_DEFAULT_REGION = 'sa-east-1'
    }

	stages{
		stage('Build Backend'){
			steps{
				sh 'mvn clean install'
			}
		}

		stage('Deletar versao antiga'){
			steps{
				script{
					def dockerImageId = sh(
                        script: 'docker images --format "{{.ID}}" --filter "reference=lucasycosta/teste"',
                        returnStdout: true
                    ).trim()
                    echo "Docker Image ID: ${dockerImageId}"

					sh """
						if [ -z "${dockerImageId}" ]; then
							echo "não há imagem para ser deletada"
						else
							docker rmi ${dockerImageId}
						fi
					"""
				}
			}
		}

		stage('Build/Run Image Backend'){
			steps{
				script{
					def buildId = env.BUILD_ID
					sh 'echo $BUILD_ID'

					sh 'docker build -t lucasycosta/teste:$BUILD_ID .'
				}
			}
		}

		stage('docker login'){
			steps{
				script{
					sh 'docker logout'
					sh 'docker login -u "lucasycosta" -p "Lucas14062000"'
				}
			}
		}
		
		stage('Push image'){
			steps{
				script{
					sh 'docker push lucasycosta/teste:$BUILD_ID'
				}
			}
		}

        // stage('Conectar com o cluster'){
		// 	steps{
		// 		script{
		// 			sh 'aws eks update-kubeconfig --name eks-wayconsig-prd '
		// 		}
		// 	}
		// }

        //INSTALAR KUBECTL
        //curl.exe -LO "https://dl.k8s.io/release/v1.31.0/bin/windows/amd64/kubectl.exe
        stage('Deploy com a nova imagem'){
			steps{
				script{
					withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
						sh '''
						aws eks update-kubeconfig --name eks-wayconsig-prd
						kubectl set image deployment/teste teste=lucasycosta/teste:$BUILD_ID -n wayconsig-eks
						'''
						//export TAG=$BUILD_ID
						//envsubst < teste.yaml | kubectl apply -f teste.yaml
					}
				}
			}
		}

	}
}