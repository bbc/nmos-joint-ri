# NMOS IS-04, IS-05 and BCP-003-02 Joint Reference Implementation

## Introduction

This repository contains a Vagrant provisioning to build 3 virtual machines:
* IS-04/05 node
* IS-04 registry
* BCP-003-02 Authorisation Server

The node VM will also present a user interface for interacting with the APIs, and another which allows senders and receivers to be added to a "mock driver". This mock driver takes the place of the interface that would normally exist between the APIs and a sender or receiver, and allows the user to add mock up senders or receivers to the Connection Management and Node APIs. Note that the VM does not contain any actual RTP senders or receivers - you cannot produce media streams using this software.

The mock user interfaces allows calls to be made to the IS-05 API, the effects of which can be observed by inspecting the Node and Connection management APIs on port 8884, and the Query API on port 8882. If there are any port colissions on the host, Vagrat will attempt to re-map the ports to compensate. Run `vagrant port <machine name>` to check.

## Setup

### Prerequisites

For the best experience:
- Use a host machine running Ubuntu Linux (tested on 16.04 and 14.04) - it may work on other platforms but this has not been tested.
- Install vagrant using a Virtualbox as a provider (https://www.vagrantup.com/docs/installation/) (https://www.vagrantup.com/docs/virtualbox/).

The Node VM will bind to three host machine ports: 8884 to present the APIs themselves, 8858 to present the mock driver user interfaces and 8859 to present the IS-05 API user interface. 

The Registration and Query machine will present its APIs on port 8882. 

The Authorisation Server will present its APIs on port 8886. 

If these ports are already in use on the host machine the bindings may be changed in the Vagrant file.


### Installing behind a proxy

[Optionally] Install vagrant proxyconf plugin if you want to easily pass host machine proxy configuration to the guest machines. If you are running the machines behind a proxy they will not configure correctly without proxy information, as they use git to pull down repositories to install.
```
vagrant plugin install vagrant-proxyconf
```

Set environment HTTP proxy variables (these will be passed to Vagrant VMs for use by git, apt and pip if Vagrant proxyconf plugin is installed):
```
export http_proxy=http://<path-to-your-proxy:proxy-port>
export https_proxy=https://<path-to-your-proxy:proxy-port>
```

For Windows users the proxy settings will have to be added to the vagrant file. Please see the [vagrant-proxyconf github](https://github.com/tmatilai/vagrant-proxyconf) for details.

### Start

To bring up the vagrant machine:

```
cd vagrant
vagrant up
```

## Mock Driver User Interface

The mock driver is presented on (http://localhost:8858/). Two forms allow the creation of mock-up senders and receivers, which have the following options:

* Number of legs - Typically one unless SMPTE 2022-7 is use to allow use of a redundant path.
* Enable FEC - If checked the sender/receiver will expose parameters related to operation with forward error correction.
* Enable RTCP - If checked sender/receiver will expose parameters related to operation with RTCP.

Once added the sender or receiver's UUID will be listed in the table below the form, along with the settings used to create it. Clicking on the dustbin symbol on the right of each entry will remove the corresponding sender/receiver.

Once senders and receivers have been added they will show up in both the Node and Connection APIs on the node machine, and be propagated to the registry. This can be seen by inspecting the APIs presented on ports 8884 (Node machine) and 8882 (registry machine).

## IS-05 API User Interface

The IS-05 API user interface is presented on (http://localhost:8859/).

The interface defaults to expecting the API to be presented on http://localhost:8859. If this is not the case enter the root URL for the API (e.g http://localhost:12345) into the text box in the top left corner of the page, then click "Change API Root". If your browser supports HTML5, this value is saved to your browser, and will be remembered even if the page is refreshed.

If the API currently has senders and receivers registered their UUIDs will be listed below the "Senders" and "Receivers" headings. If no UUIDs are visible this may indicate that the root address for the API is set incorrectly. If using the example API presented by the VM ensure you have used the Mock Driver Interface (see above) to add some senders and receivers. Note that the page must be refreshed before new to update this list.

Clicking on the UUIDs causes a set of headings to appear beneath it. These are subtly different for senders and receivers. Click on a heading to expand its corresponding form. Each of the sections (for both senders and receivers) are detailed below:

### Staged Transport Parameters

Lists the staged transport parameters currently presented by the API. Only fields that are permitted by the sender/receiver's schema will be present. The "leg" drop down allows the user to toggle between parameters for the primary and redundant leg of SMPTE 2022-7 devices. Parameters for both legs must be populated before staging on such devices.

Clicking "Stage Parameters" makes an HTTP PUT request to the API. At present only PUT is supported by the UI, and as such all parameters will be updated to reflect their values in the form.


### Staged Transport File (Receivers Only)

This allows the transport file for a given receivers to be staged. "Transport File Type" should be set to application/sdp if working with SDP files. If passing in the actual content of the sdp file directly "By Reference" should be left un-checked. If passing in a URL to the transport file "By Reference" should be checked. The sdp file contents or the URL pointing to it should be placed in the "Data" box. Optionally the user may provide a Sender ID.

Clicking "Stage File" will staged these setting to the API. Once again only PUT is supported by the UI, however leaving "Sender ID" empty is acceptable, and will result in the Sender Id being set to "null".

### Activation

The activation form has a button for each of the activation types supported by the API - immediate, absolute and relative. Clicking "Activate Now" will transfer all staged parameters to active immediately. Clicking "Activate Relative" will move staged parameters to active after the offset defined by the "seconds" and "nanoseconds" fields has elapsed. Finally "Activate Absolute" will move the parameters at the TAI time provided in its own "seconds" and "nanoseconds" boxes. Note that TAI time differs from UTC, as it does not account for leap seconds.

During the period between a activation being requested and it occurring staged parameters are deemed to be "locked". Attempting to change the parameters during this time will result in an error.

### Active Transport File (Senders Only)

Provides a link to the transport file that should be used to configure receivers to receiver from this sender.

### Active Transport Parameters

Displays the transport parameters currently active on the device. The refresh button may be used to update these as required.

## Debugging

### SSH into guests

Vagrant allows ssh into guest machines. To ssh into the node and registry machines respoectivly use the following commands from the Vagrant directory:

```
vagrant ssh node
```

```
vagrant ssh regquery
```

```
vagrant ssh auth
```

The directories cloned down during setup are found in the home directory, but have root permissions. As such any operations on them require root privilidges. Software in the repositories may be built using:

```
sudo make deb
```

and installed using dpkg in the usual way from the home directory:

```
sudo dpkg -i ../<deb name>
```

### Logging

The NMOS software installed on both guests will log into the /var/log/nmos.log. SSH into the guests as detailed above to view these logs.

### Using alternative NMOS branches

The joint RI allows the user to set which branches of each of the NMOS repositories will be used when provisioning. The branches are set in environment variables on the host before the VM is provisioned. This is primarily intended for use in automated testing.

The environment variables to be set are as follows:

```
NMOS_RI_COMMON_BRANCH
NMOS_RI_MDNS_BRIDGE_BRANCH
NMOS_RI_REVERSE_PROXY_BRANCH
NMOS_RI_NODE_BRANCH
NMOS_RI_QUERY_BRANCH
NMOS_RI_REGISTRATION_BRANCH
NMOS_RI_CONNECTION_BRANCH
NMOS_RI_AUTH_BRANCH
```

For example, the RI may be configured to use the "dev" branch of the reverse proxy as follows:

```
export NMOS_RI_REVERSE_PROXY_BRANCH=dev
vagrant up
```
