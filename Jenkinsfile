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
	}
}