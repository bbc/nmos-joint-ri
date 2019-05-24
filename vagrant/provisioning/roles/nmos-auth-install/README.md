nmos-auth-install
=========

This module installs nmos-auth

Requirements
------------

This module requires Ansible 2.4

Role Variables
--------------

See defaults for variables and descriptions

## Usage

This role install the NMOS Authentication Server

Then it installs a systemd unit file for the service, enables it on boot and
starts it. (On-boot enable can be disabled with `enable_on_boot`)


Dependencies
------------

This role depends on nmoscommon being installed

Example Playbook
----------------

Example to call:

    - hosts: all
      roles:
         - { role: nmos-auth-install }
