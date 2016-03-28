FROM ubuntu:trusty

#RUN apt-get update && \
	#    apt-get upgrade && \
	# DEBIAN_FRONTEND=noninteractive apt-get install \
	#    ca-certificates \
	#    nginx \
	#    apt-mirror && \
	#rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ca-certificates \
        nginx \
        apt-mirror
RUN rm -rf /var/lib/apt/lists/*

ADD mirror.list /etc/apt

RUN mkdir -p /var/www/docker && apt-mirror

ADD nginx.conf /etc/nginx

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
   && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

ADD get-key.sh /

RUN /get-key.sh /var/www/docker/mirror/packages.docker.com/1.10/apt/repo

CMD ["nginx", "-g", "daemon off;"]
