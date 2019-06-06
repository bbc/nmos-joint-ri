nmos-service-install
=========

This module install an NMOS service

Requirements
------------

This module requires Ansible 2.8

Role Variables
--------------

* package_name: <Python package name>
* repo_url: <URL to Git repository>
* branch: <Git branch>
* service_file: <Relative path to python service file>
  * This is a optional variable
* reverse_proxy_file: <Relative path to reverse proxy Apache config file>
  * This is a optional variable

## Usage

This role install the NMOS service specified by the variables

Dependencies
------------

Example Playbook
----------------

Example to call:
```
    - hosts: all
      become: yes
      roles:
         - { role: nmos-service-install }
      vars:
        package_name: nmos-auth
        repo_url: https://github.com/bbc/nmos-auth-server.git
        branch: master
        service_file: python-nmos-auth.service
        reverse_proxy_file: ips-api-auth.conf
```
