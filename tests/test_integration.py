import unittest
import requests
import json


# Default Vagrant port mappings (should match Vagrant file!)
DEFAULT_PORTS = {
    "node": {
        '80': '8884',
        '8858': '8858',
        '8860': '8859',
        '22': '2222'
    },
    "regquery": {
        '80': '8882',
        '22': '2222'
    },
    "auth": {
        '80': '8886',
        '22': '2222'
    }
}


class NodeIntegrationTests(unittest.TestCase):

    @classmethod
    def loadPorts(cls):
        try:
            with open("vagrantPorts.json", "r") as f:
                toReturn = json.load(f)
        except:
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
        except:
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

class AuthIntegrationTests(unittest.TestCase):

    @classmethod
    def loadPorts(cls):
        try:
            with open("vagrantPorts.json", "r") as f:
                toReturn = json.load(f)
        except:
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
