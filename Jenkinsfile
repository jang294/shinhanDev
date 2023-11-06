pipeline {
    agent {
        kubernetes {
            yaml """
kind: Pod
metadata:
  name: kaniko
spec:
  nodeName: k8s-worker01
  dnsPolicy: Default
  containers:
  - name: kaniko
    namespace: jenkins
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  - name: gitops
    namespace: jenkins
    image: bitnami/git:latest
    imagePullPolicy: Always
    command:
    - /bin/sh
    tty: true
  volumes:
  - name: jenkins-docker-cfg
    namespace: jenkins
    projected:
      sources:
      - secret:
          name: registry-credentials
          items:
            - key: .dockerconfigjson
              path: config.json
"""
        }
    }

    stages {
        stage('Build Docker image') {
            environment {
                REPOSITORY  = 'jang1023'
                IMAGE       = 'shinhan'
            }
            steps {
                container('kaniko') {
                    script {
                        sh "executor --dockerfile=Dockerfile --context=./ --destination=${REPOSITORY}/${IMAGE}:${GIT_COMMIT}"
                    }
                }
            }
        }
        stage('Approval'){
          steps{
            slackSend(color: '#FF0000', message: "Please Check Deployment Approval (${env.JOB_URL})")
            timeout(time: 15, unit:"MINUTES"){
              input message: 'Do you want to approve the deployment?', ok:'YES'
            }
          }
        }
        stage('GitOps') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'git_cre', passwordVariable: 'password', usernameVariable: 'username')]) {
                        container('gitops') {
                            git credentialsId: 'git_cre', url: 'https://github.com/jang294/shinhanDeploy.git', branch: 'main'
                            sh """
                            git init
                            git config --global --add safe.directory /home/jenkins/agent/workspace/test
                            git config --global user.email 'jenkins@jenkins.com'
                            git config --global user.name 'jenkins'
                            sed -i 's@jang1023/jeongeun:.*@jang1023/shinhan:${GIT_COMMIT}@g' deploy.yaml
                            git add deploy.yaml
                            git commit -m 'Update: Image ${GIT_COMMIT}'
                            git remote set-url origin https://${username}:${password}@github.com/jang294/shinhanDeploy.git
                            git push origin main
                            """
                        }
                    }
                }
            }
        }
    }
}
