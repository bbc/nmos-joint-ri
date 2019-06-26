@Library("rd-apmm-groovy-ci-library@v1.x") _

pipeline {
    agent {
        label "ubuntu&&apmm-slave"
    }
    options {
        ansiColor('xterm') // Add support for coloured output
        buildDiscarder(logRotator(numToKeepStr: '10')) // Discard old builds
    }
    environment {
        http_proxy = "http://www-cache.rd.bbc.co.uk:8080"
        https_proxy = "http://www-cache.rd.bbc.co.uk:8080"
    }
    stages {
        stage("Clean Environment") {
            steps {
                sh 'git clean -dfx'
            }
        }
        stage ("Integration Tests") {
            stages {
                stage ("Start Test Environment") {
                    steps {
                        script {
                            env.int_result = "FAILURE"
                        }
                        bbcGithubNotify(context: "tests/integration", status: "PENDING")
                        dir ('vagrant') {
                            sh 'vagrant up --provision'
                        }
                        sleep(20)
                    }
                }
                stage ("Run Integration Tests") {
                    steps {
                        bbcVagrantFindPorts(vagrantDir: "vagrant")
                        sh 'python3 -m unittest discover'
                        script {
                            env.int_result = "SUCCESS"
                        }
                    }
                }
            }
            post {
                always {
                    dir ('vagrant') {
                        sh 'vagrant destroy -f'
                    }
                    bbcGithubNotify(context: "tests/integration", status: env.int_result)
                }
            }
        }
    }
    post {
        always {
            bbcSlackNotify()
        }
    }
}
