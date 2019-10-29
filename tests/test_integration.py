import unittest
import requests
import json


# Default Vagrant port mappings (should match Vagrant file!)
DEFAULT_PORTS = {
    "regquery": {
        '80': '8882'
    },
    "node": {
        '80': '8884',
        '8858': '8858',
        '8860': '8860'
    },
    "auth": {
        '80': '8886'
    },
    "testing": {
        '5000': '8888'
    }
}
# Default Vagrant internal IP addresses (should match Vagrant file!)
DEFAULT_IP = {
    "regquery": "172.28.128.102",
    "node": "172.28.128.104",
    "auth": "172.28.128.106",
    "testing": "172.28.128.108"
}


class NodeIntegrationTests(unittest.TestCase):

    @classmethod
    def loadPorts(cls):
        try:
            with open("vagrantPorts.json", "r") as f:
                toReturn = json.load(f)
        except Exception:
            print("Did not find vagrantPorts.json in current directory, using default ports")
            toReturn = DEFAULT_PORTS
        return toReturn

    @classmethod
    def setUpClass(cls):
        ports = cls.loadPorts()
        print(ports)
        cls.apiPort = ports['node']['80']
        cls.mockDriverPort = ports['node']['8858']
        cls.uiPort = ports['node']['8860']

    def checkUp(self, path, port, msg):
        r = requests.get("http://localhost:{}{}".format(port, path))
        self.assertEqual(r.status_code, 200, msg)

    def test_apache_up(self):
        msg = "Could not find apache running"
        self.checkUp('/', self.apiPort, msg)

    def test_mdns_bridge__up(self):
        msg = "Could not find MDNS Bridge service"
        self.checkUp('/x-ipstudio/mdnsbridge/v1.0/', self.apiPort, msg)

    def test_node_api_up(self):
        msg = "Could not find Node API"
        self.checkUp('/x-nmos/node/', self.apiPort, msg)

    def test_cm_api_up(self):
        msg = "Could not find Connection Management API"
        self.checkUp('/x-nmos/connection/', self.apiPort, msg)

    def test_mock_driver_up(self):
        msg = "Could not find mock driver"
        self.checkUp('/', self.mockDriverPort, msg)

    def test_ui_up(self):
        msg = "Could not find connection management user interface"
        self.checkUp('/', self.uiPort, msg)


class RegQueryIntegrationTests(unittest.TestCase):

    @classmethod
    def loadPorts(cls):
        try:
            with open("vagrantPorts.json", "r") as f:
                toReturn = json.load(f)
        except Exception:
            print("Did not find vagrantPorts.json in current directory, using default ports")
            toReturn = DEFAULT_PORTS
        return toReturn

    @classmethod
    def setUpClass(cls):
        ports = cls.loadPorts()
        print(ports)
        cls.apiPort = ports['regquery']['80']

    def checkUp(self, path, port, msg):
        r = requests.get("http://localhost:{}{}".format(port, path))
        self.assertEqual(r.status_code, 200, msg)

    def test_apache_up(self):
        msg = "Could not find apache running"
        self.checkUp('/', self.apiPort, msg)

    def test_mdns_bridge__up(self):
        msg = "Could not find MDNS Bridge service"
        self.checkUp('/x-ipstudio/mdnsbridge/v1.0/', self.apiPort, msg)

    def test_reg_api_up(self):
        msg = "Could not find Registration API"
        self.checkUp('/x-nmos/registration/', self.apiPort, msg)

    def test_reg_api_nodes(self):
        msg = "Registration API responded incorrectly"
        self.checkUp('/x-nmos/registration/v1.2/resource/nodes', self.apiPort, msg)

    def test_query_api_up(self):
        msg = "Could not find Query API"
        self.checkUp('/x-nmos/query/', self.apiPort, msg)

    def test_query_api_nodes(self):
        msg = "Query API responded incorrectly"
        self.checkUp('/x-nmos/query/v1.2/nodes', self.apiPort, msg)

    def test_query_api_nodes_not_empty(self):
        msg = "Query API contains exactly one Node"
        r = requests.get("http://localhost:{}{}".format(self.apiPort, "/x-nmos/query/v1.2/nodes"))
        self.assertEqual(len(r.json()), 1, msg)


class AuthIntegrationTests(unittest.TestCase):

    @classmethod
    def loadPorts(cls):
        try:
            with open("vagrantPorts.json", "r") as f:
                toReturn = json.load(f)
        except Exception:
            print("Did not find vagrantPorts.json in current directory, using default ports")
            toReturn = DEFAULT_PORTS
        return toReturn

    @classmethod
    def setUpClass(cls):
        ports = cls.loadPorts()
        print(ports)
        cls.apiPort = ports['auth']['80']

    def checkUp(self, path, port, msg):
        r = requests.get("http://localhost:{}{}".format(port, path))
        self.assertEqual(r.status_code, 200, msg)

    def test_apache_up(self):
        msg = "Could not find apache running"
        self.checkUp('/', self.apiPort, msg)

    def test_mdns_bridge__up(self):
        msg = "Could not find MDNS Bridge service"
        self.checkUp('/x-ipstudio/mdnsbridge/v1.0/', self.apiPort, msg)

    def test_auth_api_up(self):
        msg = "Could not find Auth API"
        self.checkUp('/x-nmos/auth/', self.apiPort, msg)


class TestingIntegrationTests(unittest.TestCase):

    def loadPorts():
        try:
            with open("vagrantPorts.json", "r") as f:
                toReturn = json.load(f)
        except Exception:
            print("Did not find vagrantPorts.json in current directory, using default ports")
            toReturn = DEFAULT_PORTS
        return toReturn

    @classmethod
    def setUpClass(cls):
        cls.ports = cls.loadPorts()
        cls.apiPort = cls.ports['testing']['5000']
        cls.ipAddr = DEFAULT_IP

    def checkUp(self, path, port, msg, status_code=200):
        headers = {
            "Content-Type": "application/json"
        }
        r = requests.get("http://localhost:{}{}".format(port, path), headers=headers)
        self.assertEqual(
            r.status_code,
            status_code,
            msg + ". Path: {}, Port: {}. Response: {}".format(path, port, r.text)
        )
        return r

    def runTest(self, body, query=None, headers=None, msg=""):
        if not headers:
            headers = {
                "Content-Type": "application/json"
            }
        resp = requests.post(
            "http://localhost:{}/api".format(self.apiPort),
            json=body,
            params=query,
            headers=headers
        )
        if not msg:
            msg = "Response: {}: \nBody: {}".format(resp.text, body)
        self.assertEqual(resp.status_code, 200, msg)
        return resp

    def checkResults(self, response):
        for result in response.json()["results"]:
            self.assertNotEqual(
                result["state"].lower(),
                "fail",
                "failed on test: {} - {}".format(result["name"], result["detail"])
            )

    def test_tool_up(self):
        msg = "Could not find testing tool running"
        self.checkUp('/', self.apiPort, msg)
        msg = "Could not find API endpoint"
        # Returns 400 due to no JSON body being present
        self.checkUp('/api', self.apiPort, msg, 400)

    def test_list_suites(self):
        body = {
            "list_suites": True
        }
        r = self.runTest(body)
        self.assertTrue(isinstance(r.json(), list))
        self.assertTrue("IS-04-01" in r.json())

    def test_run_is04_node(self):
        body = {
            "suite": "IS-04-01",
            "host": [self.ipAddr["node"]],
            "port": ['80'],
            "version": ["v1.2"]
        }
        resp = self.runTest(body)
        self.checkResults(resp)

    def test_run_is04_regquery(self):
        body = {
            "suite": "IS-04-02",
            "host": [self.ipAddr["regquery"], self.ipAddr["regquery"]],
            "port": ['80', '80'],
            "version": ['v1.2', 'v1.2']
        }
        resp = self.runTest(body)
        self.checkResults(resp)

    def test_run_is05_tests(self):
        body = {
            "suite": "IS-05-01",
            "host": [self.ipAddr["node"]],
            "port": ['80'],
            "version": ["v1.0"]
        }
        resp = self.runTest(body)
        self.checkResults(resp)

    # Requires config parameter to be changed
    def test_run_is10_tests(self):
        body = {
            "suite": "IS-10-01",
            "host": [self.ipAddr["auth"]],
            "port": ['80'],
            "version": ["v1.0"]
        }
        resp = self.runTest(body)
        self.checkResults(resp)
