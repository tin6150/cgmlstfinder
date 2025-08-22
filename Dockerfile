##FROM debian:stretch
FROM debian:bullseye

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
	prodigal \
    libz-dev \
    ; \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*;

ENV DEBIAN_FRONTEND Teletype

# Install python dependencies
RUN pip3 install -U ete3 tabulate cgecore numpy;
RUN pip3 install -U six;

# Install kma
RUN git clone --depth 1 https://bitbucket.org/genomicepidemiology/kma.git; \
    cd kma && make; \
    mv kma* /bin/

COPY cgMLST.py /usr/src/cgMLST.py

RUN chmod 755 /usr/src/cgMLST.py;



#Sn50
# install database , into the container, rather than rely on bind mount
# not enought space in build env to build this container with the DB
RUN mkdir -p /opt/database    ;\
    cd       /opt/database    ;\
    git clone https://bitbucket.org/genomicepidemiology/cgmlstfinder_db.git ;\
    cd / ;\
    ln -s /opt/database/cgmlstfinder_db /database ;\
    cd /database         ;\
    echo "skipped DB install python3 INSTALL.py"   ;\
    echo $?

ENV DBG_CONTAINER_VER  "Dockerfile 2025.0821 sn50 skipDB"
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

