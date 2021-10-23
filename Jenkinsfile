#!/usr/bin/env groovy
String daily_cron_string = BRANCH_NAME == "master" ? "@daily" : ""


// Uses Declarative syntax to run commands inside a container.
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  namespace: jenkins
spec:
  containers:
  - name: platformio
    image: shaguarger/platformio
    command:
    - sleep
    args:
    - infinity
'''
            defaultContainer 'platformio'
        }
    }
    triggers { cron(daily_cron_string) }

    stages {
        stage('Check') {
            steps{
                sh "env"
                sh "whoami"
                sh "platformio --version"
                sh "ls -al"
                sh "git remote -v"
            }
        }
        stage('Rebase') {
            steps{
                sh "git remote add arendst https://github.com/arendst/Tasmota || echo Remote already exists"
                sh "git fetch --all -p"
                sh "git config user.name TinkerKenjins"
                sh "git config user.email kenjins@tinker.works"
                sh "git rebase arendst/master"

                sh "git log | head -n10"
            }
        }
        stage('Compile') {
            steps{
                sh "platformio run"
            }
        }
    }
}
