pipeline {
  agent {
    kubernetes {
      yamlFile 'kaniko-builder.yaml'
      defaultContainer 'jnlp'
      serviceAccount 'jenkins-service-account'
      namespace 'jenkins'
    }
  }

  environment {
    APP_NAME = "chronoscd"
    RELEASE = "1.0.0"
    DOCKER_USER = "lance0821"
    DOCKER_PASS = 'docker-hub-pass'
    IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}"
    IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    DOCKER_REGISTRY = 'docker.io' // Assuming Docker Hub
  }

  stages {
    stage("Cleanup Workspace") {
      steps {
        cleanWs()
      }
    }

    stage("Checkout from SCM") {
      steps {
        git branch: 'main', credentialsId: 'github', url: 'https://github.com/lance0821/chronoscd'
      }
    }

    stage('Build & Push with Kaniko') {
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            sh '''#!/busybox/sh
              /kaniko/executor --dockerfile `pwd`/Dockerfile --context `pwd` --destination=${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} --destination=${DOCKER_REGISTRY}/${IMAGE_NAME}:latest --verbosity=debug
            '''
          }
        }
      }
    }
  }

  post {
    always {
      echo 'Cleaning up...'
      cleanWs()
    }
  }
}
