##FROM debian:stretch
FROM debian:bullseye
##FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

## .github/workflow/publish__ghcr.yml WRONG dir, missed s. that that version was the actual push to ghcr.  FIX TBD ++

### RUN set -ex; \

RUN echo  ''  ;\
    touch _TOP_DIR_OF_CONTAINER_  ;\
    echo  'debian_bullseye'                  | tee -a _TOP_DIR_OF_CONTAINER_ ;\
    echo "begining docker build process at " | tee -a _TOP_DIR_OF_CONTAINER_  ;\
    date | tee -a       _TOP_DIR_OF_CONTAINER_ ;\
    export TERM=dumb      ;\
    export NO_COLOR=TRUE  ;\
    cd /     ;\
    echo "" 


RUN apt-get update -qq; \
    apt-get install -y -qq git \
    apt-utils \
    wget \
    python3-pip \
    python3-full \
    python3-numpy \
    pipx \
    prodigal \
    phylip \
    libz-dev \
    gnu-which \
    ; \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*;

ENV DEBIAN_FRONTEND Teletype

# Install python dependencies
#RUN pip3 install  ete3 tabulate cgecore;
#RUN pip3 install -U ete3 tabulate cgecore numpy;
RUN python3 -m pip  install ete3 tabulate;
RUN python3 -m pip  install --break-system-packages cgecore;
RUN python3 -m pip  install --break-system-packages six;
# something changed between 2025.08.20-ish and 08.30
# this bulid ok before, but now complain it is externally managed... and to use pipx 
# try forcing it.  it was just circumvent warnings.  it is a container, disposable.

# Install kma
RUN git clone --depth 1 https://bitbucket.org/genomicepidemiology/kma.git; \
    cd kma && make; \
    mv kma* /bin/

COPY cgMLST.py /usr/src/cgMLST.py

RUN chmod 755 /usr/src/cgMLST.py;

#Sn50 >>
COPY make_nj_tree.py /usr/src/make_nj_tree.py   
RUN  chmod 755       /usr/src/make_nj_tree.py;
# hmm... cant just run out out of the git repo, cuz has pip dependencies for ete3, maybe other



#Sn50
# install database , into the container, rather than rely on bind mount
# not enought space in build env to build this container with the DB
RUN mkdir -p /opt/database    ;\
    cd       /opt/database    ;\
    git clone https://bitbucket.org/genomicepidemiology/cgmlstfinder_db.git ;\
    cd / ;\
    ln -s /opt/database/cgmlstfinder_db /database ;\
    cd /database         ;\
    export cgMLST_DB=$(pwd)           ;\
    echo cgMLST_DB is set to $cgMLST_DB           | tee -a cgmlstfinder_db_install.TXT  ;\
    echo "skipped DB install python3 INSTALL.py"  | tee -a cgmlstfinder_db_install.TXT  ;\
    echo $?

RUN echo ''  ;\
    echo '==================================================================' ;\
    test -d /opt/gitrepo            || mkdir -p /opt/gitrepo             ;\
    test -d /opt/gitrepo/container  || mkdir -p /opt/gitrepo/container   ;\
    #the git command dont produce output, thought container run on the dir squatting on the git files.  COPY works... oh well
    #git branch |tee /opt/gitrepo/container/git.branch.out.txt            ;\
    #git log --oneline --graph --decorate | tee /opt/gitrepo/container/git.lol.out.txt       ;\
    #--echo "--------" | tee -a _TOP_DIR_OF_CONTAINER_           ;\
    #--echo "git cloning the repo for reference/tracking" | tee -a _TOP_DIR_OF_CONTAINER_ ;\
    cd /     ;\
    echo ""

# add some marker of how Docker was build.
COPY .              /opt/gitrepo/container/
#COPY Dockerfile*   /opt/gitrepo/container/

ENV DBG_CONTAINER_VER  "Dockerfile 2025.0830a sn50 skipDB gnu-which make_nj_tree.py phylip no_pipx"
ENV DBG_DOCKERFILE Dockerfile

RUN  cd / \
  && touch _TOP_DIR_OF_CONTAINER_  \
  && echo  "--------" >> _TOP_DIR_OF_CONTAINER_   \
  && TZ=PST8PDT date  >> _TOP_DIR_OF_CONTAINER_   \
  && uptime    | tee -a  _TOP_DIR_OF_CONTAINER_   \
  && echo  $DBG_CONTAINER_VER   | tee -a  _TOP_DIR_OF_CONTAINER_   \
  && echo  "Grand Finale for Dockerfile"



ENV PATH $PATH:/usr/src
# Setup .bashrc file for convenience during debugging
RUN echo "alias ls='ls -h --color=tty'\n"\
"alias ll='ls -lrt'\n"\
"alias l='less'\n"\
"alias du='du -hP --max-depth=1'\n"\
"alias cwd='readlink -f .'\n"\
"PATH=$PATH\n">> ~/.bashrc

WORKDIR /workdir

# Execute program when running the container
ENTRYPOINT ["python3", "/usr/src/cgMLST.py"]

