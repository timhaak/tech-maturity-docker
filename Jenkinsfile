pipeline {
  agent any

  stages {
    stage ('Checkout Code') {
      steps {
        checkout scm
      }
    }
    stage ('Verify Tools'){
      steps {
        parallel (
          docker: { sh "docker -v" }
        )
      }
    }

    stage ('Build container') {
      steps {
        sh "docker build --pull --no-cache --rm -t dr.haak.co/tech-maturity ."
        sh "docker tag dr.haak.co/tech-maturity:latest dr.haak.co/tech-maturity:${env.GIT_COMMIT}"
      }
    }
    stage ('Deploy') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'bamboo_dr_haak_co', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "docker login --username ${USERNAME} --password ${PASSWORD} https://dr.haak.co"
          sh "docker push dr.haak.co/tech-maturity:latest"
          sh "docker push dr.haak.co/tech-maturity:${env.GIT_COMMIT}"
        }
      }
    }
  }
}
