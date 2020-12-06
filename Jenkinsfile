pipeline
{
	agent any
	
	environment 
	{ 
		PrdVersion = "1.${env.BUILD_ID}"
		DevVersion = "1.0.${env.BUILD_ID}"
	}
	
	stages
	{
		stage('Verify Branch')
		{
			steps
			{
				echo "$GIT_BRANCH"
			}
		}
		
		stage('Pull Changes') 
		{
			steps 
			{
				powershell(script: "git pull")
			}
		}
		
		stage('Run Unit Tests')
		{
			steps
			{
				powershell(script: """
					cd Server
					dotnet test
					cd ..
				""")

			}
		}
		
		stage('Docker Build')
		{
			steps
			{
				powershell(script: 'docker-compose build')
				powershell(script: 'docker build -t blagodockerhub/carrental-user-client-dev --build-arg configuration=development ./Client')   
				powershell(script: 'docker images -a')
			}
		}
		
		stage('Run Test App')
		{
			steps
			{
				powershell(script: 'docker-compose up -d')
				powershell(script: './Tests/ContainerTests.ps1')
			}
		}
		
		stage('Stop Test App')
		{
			steps
			{
				powershell(script: 'docker-compose down')
				powershell(script: 'docker volume prune -f')   
			}
			post
			{
				success
				{
					echo "Success!! Can be deployed ..."
				}
				failure
				{
					echo "Build failed! Send email"
				}
			}
		}
		
		stage('Push Images') 
		{
			when { branch 'main' }
			steps 
			{
				script 
				{
					docker.withRegistry('https://index.docker.io/v1/', 'DockerHubCredentialsId') 
					{
						def identity = docker.image("blagodockerhub/carrental-identity-service")
							identity.push(env.PrdVersion)
							
						def dealers = docker.image("blagodockerhub/carrental-dealers-service")
							dealers.push(env.PrdVersion)
							
						def statistics = docker.image("blagodockerhub/carrental-statistics-service")
							statistics.push(env.PrdVersion)
							
						def notifications = docker.image("blagodockerhub/carrental-notifications-service")
							notifications.push(env.PrdVersion)
							
						def client = docker.image("blagodockerhub/carrental-user-client")
							client.push(env.PrdVersion)
							
						def adminclient = docker.image("blagodockerhub/carrental-admin-client")
							adminclient.push(env.PrdVersion)
							
						def watchdog = docker.image("blagodockerhub/carrental-watchdog-service")
							watchdog.push(env.PrdVersion)
					}
				}
			}
		} 
		
		stage('Push Development Images') 
		{
			when { branch 'development' }
			steps 
			{
				script 
				{
					docker.withRegistry('https://index.docker.io/v1/', 'DockerHubCredentialsId') 
					{
						def identity = docker.image("blagodockerhub/carrental-identity-service")
							identity.push(env.DevVersion)
							identity.push('latest')
							
						def dealers = docker.image("blagodockerhub/carrental-dealers-service")
							dealers.push(env.DevVersion)
							dealers.push('latest')
							
						def statistics = docker.image("blagodockerhub/carrental-statistics-service")
							statistics.push(env.DevVersion)
							statistics.push('latest')
							
						def notifications = docker.image("blagodockerhub/carrental-notifications-service")
							notifications.push(env.DevVersion)
							notifications.push('latest')
							
						def client = docker.image("blagodockerhub/carrental-user-client")
							client.push(env.DevVersion)
							client.push('latest')
							
						def adminclient = docker.image("blagodockerhub/carrental-admin-client")
							adminclient.push(env.DevVersion)
							adminclient.push('latest')
							
						def watchdog = docker.image("blagodockerhub/carrental-watchdog-service")
							watchdog.push(env.DevVersion)
							watchdog.push('latest')
					}
				}
			}
		} 
		
		stage('Deploy Development') 
		{
			when { branch 'development' }
			steps 
			{
				withKubeConfig([credentialsId: 'DevServer', serverUrl: 'https://34.123.145.46']) 
				{
				   powershell(script: 'kubectl apply -f ./k8s/environment/development.yml') 
				   powershell(script: 'kubectl apply -f ./k8s/databases') 
				   powershell(script: 'kubectl apply -f ./k8s/event-bus') 
				   powershell(script: 'kubectl apply -f ./k8s/web-services') 
				   powershell(script: 'kubectl apply -f ./k8s/clients') 
				   powershell(script: 'kubectl set image deployments/user-client user-client=blagodockerhub/carrental-user-client-dev:latest')
				}
			}
		}
		
		stage('Deploy Production') 
		{
			when{branch 'main'}
			steps 
			{
				input(message:'Confirm production deployment')
				withKubeConfig([credentialsId: 'DevServer', serverUrl: "https://34.123.145.46"]) 
				{
					powershell(script: 'kubectl apply -f ./k8s/environment/production.yml') 
					powershell(script: 'kubectl apply -f ./k8s/databases') 
					powershell(script: 'kubectl apply -f ./k8s/event-bus') 
					powershell(script: 'kubectl apply -f ./k8s/web-services') 
					powershell(script: 'kubectl apply -f ./k8s/clients') 
					powershell(script: 'kubectl set image deployments/user-client user-client=blagodockerhub/carrental-identity-service:${env.PrdVersion}')
					powershell(script: 'kubectl set image deployments/dealers-service dealers-service=blagodockerhub/carrental-dealers-service:${env.PrdVersion}')
					powershell(script: 'kubectl set image deployments/identity-service identity-service=blagodockerhub/carrental-identity-service:${env.PrdVersion}')
					powershell(script: 'kubectl set image deployments/statistics-service statistics-service=blagodockerhub/carrental-statistics-service:${env.PrdVersion}')
				}
			}
		}
	}
}