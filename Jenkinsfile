pipeline {
  agent {
    none {
      reuseNode true
    }

  }
  stages {
    stage('阶段-1') {
      steps {
        writeFile(file: 'README.md', text: 'hello CODING')
      }
    }
  }
}