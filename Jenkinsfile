pipeline {
    agent any
    tools {
        maven "maven3"
        jdk "java8"
    }

    environment { //declare environment variables 
        registerycred = 'ecr:us-east-2:aws-cred' //ecr:ecrregion:cred name given in jenkins for aws crendentials 
        ecruri = '708840523913.dkr.ecr.us-east-2.amazonaws.com/cd-ecr-registry' // uri of ECR AWS
        ecrurl = 'https://708840523913.dkr.ecr.us-east-2.amazonaws.com' // add https://uri of ECR AWS
    }

    stages {
        stage ('fetch code') {
            steps {
                git branch: 'ci-jenkins', credentialsId: 'git-cred', url: 'https://github.com/vignesh2310/ci-jenkins.git'
            }
        }

        stage ('maven build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('sonarqube code analysis') { // SonarQube Scanner for Jenkins - https://www.jenkins.io/doc/pipeline/steps/sonar/
            steps {
              withSonarQubeEnv('sonarserver') {
                sh 'mvn clean package sonar:sonar' // sonar:sonar - code review
              }
            }
        }
        
        stage('upload artifact through nexus') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'demo', classifier: '', file: 'target/demo-v2.war', type: 'war']], credentialsId: 'nexus-cred', groupId: 'devops', nexusUrl: '172.31.30.75:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'artifact-snap', version: '1.0'
            } // snapshot dosnt allow version, create repo in release.
        }

        stage('deploy to tomcat') {
            steps {
                sshagent(['tomcat-ssh-deploy']) {
                sh 'scp -o StrictHostKeyChecking=no target/demo-v2.war ubuntu@3.145.100.132:/opt/tomcat/webapps'
                }   // ubuntu user have access to tomcat files. (i.e)chown ubuntu:ubuntu under tomcat directory.
            } 
        }

        stage('build image from dokcer') {
            steps {
                script {
                    dockerImage = docker.build(ecruri + ":$BUILD_NUMBER", .)
                }
            }
        }

        stage('upload to dockerehub') {
            steps {
                script {
                    docker.withRegistry(ecrurl, registerycred) {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        } 
    }
}
