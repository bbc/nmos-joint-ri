nmos-install
=========

This module installs nmos services

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
         - { role: nmos-install }
