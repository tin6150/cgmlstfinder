#!/bin/bash

## install packages.   rpm/deb and/or pip
## expect to be called by a container install script, eg Dockerfile
## but then also portable and usable in a new linux install, eg new wsl env



export TERM=dumb
export NO_COLOR=TRUE
export DEBIAN_FRONTEND=noninteractive

# debian bulleye (v11) package name

# these no longer work, complain that they are externally managed... and to use virt env instead.  
# PITA, seems new 2025-08-30, just last week they worked.
# #RUN pip3 install  ete3 tabulate cgecore;
#RUN pip3 install -U ete3 tabulate cgecore numpy;
# python3 -m pip  install ete3 tabulate;
# python3 -m pip  install --break-system-packages cgecore;
# python3 -m pip  install --break-system-packages six;


#apt-get -y --quiet install beast2-mcmc beast2-mcmc-examples beast2-mcmc-doc beagle beagle-doc
apt-get -y --quiet install python3-full python3-venv
echo $?
apt-get -y --quiet phylip
echo $?

echo "pip stuff"

[[ -d /opt ]] || mkdir /opt 
python3 -m venv /opt/python_venv

source /opt/python_venv/bin/activate
python3 -m pip install ete3 tabulate
echo $?
python3 -m pip install cgecore
echo $?
python3 -m pip install six
echo $?



date
uptime
hostname
df -hT 
