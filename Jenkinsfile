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
  - name: kubectl
    namespace: jenkins
    image: bitnami/kubectl:latest
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
    environment {
        REPOSITORY  = 'jang1023'
        IMAGE       = 'shinhan'
    }
    stages {
        stage('Build Docker image') {
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
        stage('Deploy') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'kubeconfig', serverUrl: 'https://10.6.20.75:6443']) {
                        container('kubectl') {
                            sh """
                            use $FILE
                            sed -i 's@nginx:.*@jang1023/shinhan:\${GIT_COMMIT}@g' test.yaml
                            kubectl apply -f test.yaml -n ingress-nginx --kubeconfig=$KUBECONFIG
                            """
                        }
                    }
                }
            }
        }
    }
}
