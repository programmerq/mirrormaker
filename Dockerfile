FROM ubuntu:trusty

ENV CS_VERSION=1.10 \
    CADDY_VERSION=0.8.2

ENV WWW_ROOT=/var/www/mirror/packages.docker.com/${CS_VERSION}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        yum-utils createrepo apt-mirror curl && \
    rm -rf /var/lib/apt/lists/*

# mirroring for debs
ADD mirror.list /etc/apt

# mirroring for rpms
ADD docker-main.repo /etc/yum.repos.d/

# script to grab the package signing key
ADD get-key.sh /

RUN mkdir -p ${WWW_ROOT}

WORKDIR ${WWW_ROOT}

# get the key
RUN /get-key.sh ${WWW_ROOT}

# get the rpms
RUN touch /etc/yum.conf && \
    reposync -r yum -p ${WWW_ROOT} && \
    createrepo ${WWW_ROOT}/yum && \
    # get the debs
    apt-mirror

EXPOSE 2015

RUN curl -sLO https://github.com/mholt/caddy/releases/download/v${CADDY_VERSION}/caddy_linux_amd64.tar.gz && \
    tar zxvf caddy_linux_amd64.tar.gz && \
    mv caddy /usr/bin/caddy && chmod 755 /usr/bin/caddy && \
    rm -rf caddy* *txt

ADD Caddyfile /etc
ADD index.html ${WWW_ROOT}/..
ADD docker.list ${WWW_ROOT}/..
ADD docker.repo ${WWW_ROOT}/..
ADD install.sh ${WWW_ROOT}/..

CMD ["caddy", "-conf", "/etc/Caddyfile"]
