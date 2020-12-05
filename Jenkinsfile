pipeline
{
	agent any
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
				powershell(script: 'docker images -a')
			}
		}
		
		stage('Run Test App')
		{
			steps
			{
				powershell(script: 'docker-compose up -d')
				powershell(script: '.Tests/ContainerTests.ps1')
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
							identity.push("1.0.${env.BUILD_ID}")
							identity.push('latest')
							
						def dealers = docker.image("blagodockerhub/carrental-dealers-service")
							dealers.push("1.0.${env.BUILD_ID}")
							dealers.push('latest')
							
						def statistics = docker.image("blagodockerhub/carrental-statistics-service")
							statistics.push("1.0.${env.BUILD_ID}")
							statistics.push('latest')
							
						def notifications = docker.image("blagodockerhub/carrental-notifications-service")
							notifications.push("1.0.${env.BUILD_ID}")
							notifications.push('latest')
							
						def client = docker.image("blagodockerhub/carrental-user-client")
							client.push("1.0.${env.BUILD_ID}")
							client.push('latest')
							
						def adminclient = docker.image("blagodockerhub/carrental-admin-client")
							adminclient.push("1.0.${env.BUILD_ID}")
							adminclient.push('latest')
							
						def watchdog = docker.image("blagodockerhub/carrental-watchdog-service")
							watchdog.push("1.0.${env.BUILD_ID}")
							watchdog.push('latest')
					}
				}
			}
		} 
	}
}