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
        NMOS_RI_COMMON_BRANCH = "${env.GIT_COMMIT}"
    }
    stages {
        stage("Clean Environment") {
            steps {
                sh 'git clean -dfx'
            }
        }
        stage ("Integration Tests") {
            when {
                expression { params.INTEGRATION_TEST }
            }
            stages {
                stage ("Start Test Environment") {
                    steps {
                        script {
                            env.int_result = "FAILURE"
                        }
                        bbcGithubNotify(context: "tests/integration", status: "PENDING")
                        sh 'rm -r nmos-joint-ri || :'
                        withBBCGithubSSHAgent{
                            sh 'git clone git@github.com:bbc/nmos-joint-ri.git'
                        }
                        dir ('nmos-joint-ri/vagrant') {
                            sh 'vagrant up --provision'
                        }
                    }
                }
                stage ("Run Integration Tests") {
                    steps {
                        dir ('nmos-joint-ri') {
                            bbcVagrantFindPorts(vagrantDir: "vagrant")
                            sh 'python3 -m unittest discover'
                        }
                        script {
                            env.int_result = "SUCCESS"
                        }
                    }
                }
            }
            post {
                always {
                    dir ('nmos-joint-ri/vagrant') {
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
