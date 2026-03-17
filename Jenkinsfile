pipeline {
  agent { label 'build' }

  environment {
    registry = "nehalwandhare/democicd"
    registryCredential = 'dockerhub'
    JAVA_HOME = "/usr/lib/jvm/java-17-openjdk-amd64"
    PATH = "/usr/lib/jvm/java-17-openjdk-amd64/bin:/usr/bin:/usr/local/bin:/bin"
  }

  stages {

    stage('Debug Env') {
      steps {
        sh '''
        echo "USER: $(whoami)"
        echo "HOST: $(hostname)"
        which mvn || echo "mvn not found"
        ls -l /usr/bin/mvn || echo "mvn missing"
        java -version
        '''
      }
    }

    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://gitlab.com/nehal-wandhare/springboot-build-pipeline.git'
      }
    }

    stage('Build') {
  steps {
    echo "Building Jar Component ..."
    sh '''
    mvn -version
    mvn clean package -DskipTests
    '''
  }
}

    stage('Code Coverage') {
      steps {
        echo "Running Code Coverage ..."
        sh 'mvn jacoco:report'
      }
    }

    stage('SCA') {
      steps {
        echo "Running OWASP Dependency Check ..."
        sh 'mvn org.owasp:dependency-check-maven:check -DfailOnError=false'
      }
    }

    stage('SAST') {
      steps {
        echo "Running SonarQube Scan ..."
        withSonarQubeEnv('mysonarqube') {
          sh '''
          mvn sonar:sonar \
          -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
          -Dsonar.dependencyCheck.jsonReportPath=target/dependency-check-report.json \
          -Dsonar.dependencyCheck.htmlReportPath=target/dependency-check-report.html \
          -Dsonar.projectName=wezvatech
          '''
        }
      }
    }

    stage('Quality Gate') {
      steps {
        script {
          timeout(time: 2, unit: 'MINUTES') {
            def qg = waitForQualityGate()
            if (qg.status != 'OK') {
              error "Pipeline failed due to Quality Gate: ${qg.status}"
            }
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          docker.withRegistry('', registryCredential) {
            def myImage = docker.build(registry)
            myImage.push()
          }
        }
      }
    }

    stage('Scan Image') {
      steps {
        sh "trivy image --scanners vuln nehalwandhare/democicd:latest > trivyresults.txt"
      }
    }

    stage('Smoke Test') {
      steps {
        sh '''
        docker run -d --name smokerun -p 8080:8080 nehalwandhare/democicd
        sleep 60
        ./check.sh
        docker rm -f smokerun
        '''
      }
    }

  }
}