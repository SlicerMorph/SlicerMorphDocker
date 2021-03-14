# SlicerMorphCloud
Docker for running SlicerMorph on Cloud

## Instructions
While the container supports Nvidia drivers and GPU, this example for launching the containers from a non-GPU VM instance. 

1. Inside the SlicerMorphCloud folder build the contained :

```sudo docker build -t cloud .```

2. Create a users file that contains usernames in each line. 
3. Create persistent storage points for shared data and user space and modify the **nogpu.sh** accordingly. (Note the /temp folder location)
3. start a container for each user using the command

```for user in $(cat users); do ./nogpu.sh $user ; done > instance-table.csv```

this will generate a table of containers tied to users name, URL to be accessed and the password to be used. 

If you need the R/Rstudio to be built along SlicerMorph, use the Dockerfile.rstudio. However, this increases build time considerably. 

Also the resultant docker image will be very large, anywhere from 12-30GB depending on whether R and other things installed. Since the docker images saved under /var/lib/docker, you may run into space issues with your primary / partition. Follow these instructions to relocate your /var/lib/docker folder somewhere else with more space. Eg.,

```
sudo service docker stop
mkdir /data/docker
rsync -aXs /var/lib/docker/. /data/docker/
mv /var/lib/docker /var/lib/docker.old
ln -s /data/docker/ /var/lib/docker
sudo service docker start
```

once you confirmed everything works as intended, remove the old docker folder
```
rm -fr /var/lib/docker.old
```
