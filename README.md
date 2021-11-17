# SlicerMorphCloud
Docker for running SlicerMorph on Cloud

## Overview 
This repository enable you to launch a VM (a host) to deploy SlicerMorpCloud docker containers per user-basis. Accounts are created on the host, and users access to the docker images using their host ssh username and passwd via TurboVNC client. Docker runtime scripts allow you to adjust resources (GPU, CPU, memory, data storage) per user-basis.  

## Prerequsites for host
1. If this is a GPU node, latest Nvidia Linux drivers need to be installed
2. install docker, nvidia-docker, create docker group (each user will be added to docker group).  
3. TurboVNC prerelease from https://s3.amazonaws.com/turbovnc-pr/dev/linux/index.html 
4. Install the latest VirtualGL dev/3.0 evolving pre-release build (https://virtualgl.org/DeveloperInfo/PreReleases) on the host, using the procedure described in the VirtualGL User's Guide.
5. sudo vglserver_config (Select Option 3.)

Last two steps can be skipped on non-GPU hosts.

## Prerequsites to docker build
1. If your host doesn't have GPU, you can comment out the lines related to VirtualGL in Dockerfile. VGL has no bearing on non-accelerated instances.
2. Review the contents of dockername file. If you are planning to push the image to your docker hub account, edit it appropriately, otherwise you can leave it as is.
3. Create persistent storage volumes that will be mounted under the /home/docker for user's data. Depending on how you want your users to access There is some tricks to this, and you may need the bindfs package on the host system to get the permissions on the host side as well as docker side correctly.

## Build docker
1. Either execute the `build.sh` script, or use `docker build -t mmaga/vgl_slicer:eglbackend .`

## Setting up users on host
1. Review the `run` script to limit resource (memory and cpu) allocations to each instance, we will use this as a way to configure each users allocation. Make sure container tag matches to the one you used during the build (in this case  mmaga/vgl_slicer:eglbackend)
2. Create a user an host (e.g., test1) and setup ssh password. (Below we use test1 as example, edit this to match the user account).
3. Soft link (or use bindfs) users persistent storage to a /home/test1/MyData 
4. Create __/home/test1/.vnc/__ folder on host
5. Copy __/etc/turbovncserver.conf__ to __/home/test1/.vnc__
6. Uncomment `#$xstartup ` line in /home/test1/.vnc/turbovncserver.conf line and point it to the user's start docker run script e.g., `$xstartup = "/usr/local/vgl/test1.run.novgl"`
7. Create the reference script (e.g., /usr/local/vgl-scripts/test1.run.novgl) using the run script provided as a starting point (adjust GPU assignment, CPU cores, memory, and persistent storage point) and make it executable.

At this step users should be able to access the system using the TurboVNC client on their computer by entering the syntax `test1@HOST.ADDRESS`
and entering their SSH password. 

Once this example works, rest can be configured via number of bash scripts (not provided yet).

## How users bring their data in?
1. Use the built-in Firefox browser in the container image to bring data directly to their session (important to save it to persistent storage). 
2. Use scp or sftp (if configure) to access the host and copy data to their persistent storage, which is mapped in the example above (/home/test1/MyData). 
