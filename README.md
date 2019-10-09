# XoruX Docker Image
This is the Git repo of the Docker image for [XoruX](https://www.xorux.com) applications - [LPAR2RRD](http://www.lpar2rrd.com) & [STOR2RRD](http://www.stor2rrd.com).

This docker image is based on official [Debian 8 (Jessie)](https://hub.docker.com/_/debian) with all necessary dependencies installed.

Quick start:

    docker run -d --name XoruX -p 8080:80 xorux/apps

	or 

    docker run -d --name XoruX -v xorux:/home -p 8080:80 xorux/apps

The longer command will create volume called xorux, all data and configuration will be stored there. You can find info on this volume with command:

	docker volume inspect xorux

All future instances of xorux/apps started with -v xorux:/home parameter will use data & cfg stored in xorux volume.

 - web GUI on ports 80 & 443, can be mapped to host via parameter -p
 - set timezone for running container
 - continue to LPAR2RRD and use admin/admin as username/password
 - or continue to STOR2RRD and use admin/admin as username/password
 - container name is XoruX
 - application data and configuration is stored in volume called xorux ( more info: docker volume inspect xorux ).

You can connect via SSH on port 22 (exposed), username **lpar2rrd**, password **xorux4you** - please change it ASAP.
