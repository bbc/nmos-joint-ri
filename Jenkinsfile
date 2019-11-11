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
                            env.NMOS_RI_TESTING_BRANCH = "dannym-api"
                            env.NMOS_RI_COMMON_BRANCH = "jamesg-consistent-iface-selection"
                        }
                        bbcGithubNotify(context: "tests/integration", status: "PENDING")
                        dir ('vagrant') {
                            sh 'vagrant up --provision'
                        }
                    }
                }
                stage ("Run Integration Tests") {
                    steps {
                        bbcVagrantFindPorts(vagrantDir: "vagrant")
                        sh 'python3 -m unittest discover -v'
                        script {
                            env.int_result = "SUCCESS"
                        }
                    }
                }
                stage ("Analyse XML / JUnit files") {
                    steps {
                        junit '*.xml'
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
