nmos-joint-ri-setup
=========

This module provisions a machine with the required packages to run NMOS services

Requirements
------------

This module requires Ansible 2.8

Role Variables
--------------

See defaults for variables and descriptions

## Usage

Dependencies
------------

Example Playbook
----------------

Example to call:
```
    - hosts: all
      become: yes
      roles:
         - { role: nmos-joint-ri-setup }
```
