#!/usr/bin/env groovy
String daily_cron_string = BRANCH_NAME == "master" ? "0 5 * * 0" : ""


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
    image: python:3
    command:
    - sleep
    args:
    - infinity
  - name: mosquitto
    image: eclipse-mosquitto
    imagePullPolicy: Always
    command:
    - sleep
    args:
    - infinity
'''
            defaultContainer 'platformio'
        }
    }
    triggers { cron(daily_cron_string) }

    environment {
        PATH = "/root/.platformio/penv/bin:${env.PATH}"
    }

    stages {
        stage('Check') {
            steps{
                sh "env"
                sh "whoami"
                sh "ls -al"
                sh "curl -V"
            }
        }
        stage('Install Platformio') {
            steps {
                sh 'curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py'
                sh 'python3 get-platformio.py'

                sh "platformio --version"
            }
        }
        stage('Rebase') {
            steps{
                sh "git config --global --add safe.directory ${env.WORKSPACE}"
                sh "git remote -v"
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
        stage('Deploy') {
            when {
                anyOf {
                    branch 'master'
                }
            }
            steps {
                echo 'Deploying ...'
                sh "bash deploy.sh http://tasmota.tinker.haus"
            }
        }
        stage('Rollout') {
            when {
                anyOf {
                    branch 'master'
                }
            }
            steps {
                container('mosquitto') {
                    echo 'Triggering upgrade ...'
                    sh 'mosquitto_pub -h mqtt.tinker.haus -t "cmnd/tasmotas/Upgrade" -m "1"'
                }
            }
        }
    }
}
