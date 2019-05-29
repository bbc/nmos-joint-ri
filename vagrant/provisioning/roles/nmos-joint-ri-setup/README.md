nmos-joint-ri-setup
=========

This module provsions a NMOS reference implementation VM

Requirements
------------

This module requires Ansible 2.4

Role Variables
--------------

See defaults for variables and descriptions

## Usage

This role install the NMOS services specified by the VARS

Dependencies
------------

Example Playbook
----------------

Example to call:

    - hosts: all
      roles:
         - { role: nmos-joint-ri-setup }
