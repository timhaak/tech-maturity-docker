FROM node:8.4
MAINTAINER tim@haak.co

ENV DEBIAN_FRONTEND="noninteractive" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    TERM="xterm" \
    TZ="/usr/share/zoneinfo/UTC"


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

RUN echo "deb http://nginx.org/packages/debian/ jessie nginx" >  /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list.d/nginx-development.list && \
    wget https://nginx.org/keys/nginx_signing.key -O - | apt-key add -

RUN apt-get update && \
    apt-get install -qy \
        nginx \
        && \
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

ENV NODE_ENV=production

ADD ./files/nginx_config /site/nginx_config
ADD ./files/start.sh /start.sh
ADD ./files/supervisord.conf /supervisord.conf

RUN chmod u+x  /start.sh && \
    chown -R nginx: /site/tech-maturity/dist

WORKDIR /site/

EXPOSE 80 443

CMD ["/start.sh"]
