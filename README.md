# SlicerMorphCloud
Docker for running SlicerMorph on Cloud

## Overview 
This repository enable you to launch a VM (a host) to deploy SlicerMorpCloud docker containers per user-basis. Accounts are created on the host, and users access to the docker images using their host ssh username and passwd via TurboVNC client. Docker runtime scripts allow you to adjust resources (GPU, CPU, memory, data storage) per user-basis.  

## Prerequsites for host
1. If this is a GPU node, latest Nvidia Linux drivers need to be installed
2. install docker, nvidia-docker, create docker group (each user will be added to docker group).  
3. TurboVNC prerelease from https://s3.amazonaws.com/turbovnc-pr/dev/linux/index.html 

## Prerequsites to docker build
1. If your host doesn't have GPU, you can comment out the lines related to VirtualGL in Dockerfile. VGL has no bearing on non-accelerated instances.
2. Review the contents of dockername file. If you are planning to push the image to your docker hub account, edit it appropriately, otherwise you can leave it as is.
3. Create persistent storage volumes that will be mounted under the /home/docker for user's data. Depending on how you want your users to access There is some tricks to this, and you may need the bindfs package on the host system to get the permissions on the host side as well as docker side correctly.

## Build docker
1. Either execute the `build.sh` script, or use `docker build -t mmaga/vgl_slicer:eglbackend .`

## Docker runtime variables.
1. Edit the `run` script to limit resource (memory and cpu) allocations to each instance
2. Review 
