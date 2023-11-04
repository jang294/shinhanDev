pipeline {
    agent {
        kubernetes {
            defaultContainer 'jnlp'
            yaml """
spec:
  dnsPolicy: Default
  containers:
    - name: docker
      image: docker:latest
      command:
        - cat
      tty: true
      privileged: true
      volumeMounts:
        - name: dockersock
          mountPath: /var/run/docker.sock
  volumes:
    - name: dockersock
      hostPath:
        path: /var/run/docker.sock
            """
        }
    }

    stages {
         stage('My test') {
            steps {
                container('docker') {
                    sh "echo hello world"
                }
            }
        }
    }
}
