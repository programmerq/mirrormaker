FROM centos:7

RUN yum update -y && \
    yum install -y yum-utils createrepo epel-release && \
    yum install -y nginx && \
    yum clean all

ADD docker-main.repo /etc/yum.repos.d/
ADD nginx.conf /etc/nginx

RUN mkdir -p /var/www

WORKDIR /var/www

RUN reposync -r docker-main-repo

WORKDIR /var/www/docker-main-repo

ADD get-key.sh /

RUN createrepo .

RUN /get-key.sh /var/www/docker-main-repo

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
   && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
