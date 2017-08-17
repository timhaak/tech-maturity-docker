FROM node:8.4
MAINTAINER tim@haak.co

ENV DEBIAN_FRONTEND="noninteractive" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    TERM="xterm" \
    TZ="/usr/share/zoneinfo/UTC" \
    NODE_ENV=production

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    echo 'deb http://ftp.debian.org/debian jessie-backports main' | tee /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy \
        apt-transport-https \
        bash-completion \
        build-essential \
        bzip2 \
        ca-certificates curl \
        dnsutils \
        gawk git \
        inetutils-ping \
        openssl \
        python python-pip python-setuptools python-software-properties procps psmisc \
        ssl-cert strace sudo supervisor \
        tar telnet tmux traceroute tree \
        wget whois \
        unzip \
        vim \
        xz-utils \
        zsh && \
    apt-get install -qy python-certbot-apache -t jessie-backports && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN echo "deb http://ppa.launchpad.net/nginx/development/ubuntu zesty main" >  /etc/apt/sources.list.d/nginx-development.list && \
    echo "deb-src http://ppa.launchpad.net/nginx/development/ubuntu zesty main" >> /etc/apt/sources.list.d/nginx-development.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C

RUN apt-get update && \
        apt-get install -qy \
        nginx-extras \
        && \
    pip install xlsx2csv && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN npm install --unsafe-perm -g \
      @angular/cli \
      babel-cli \
      node-gyp \
      typescript

RUN git clone https://github.com/timhaak/tech-maturity-api /site/tech-maturity-api && \
    cd /site/tech-maturity-api/ && \
    npm install && \
    npm run build

RUN git clone https://github.com/timhaak/tech-maturity.git /site/tech-maturity && \
    cd /site/tech-maturity/ && \
    npm install && \
    npm run prod

ADD ./files /site/nginx

RUN chmod u+x  /nginx/start.sh
# && \
#    ln -sf /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime

WORKDIR /site/

EXPOSE 80 443

CMD ["/nginx/start.sh"]
