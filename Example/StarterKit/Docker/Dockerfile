FROM nginx:alpine
MAINTAINER You Yourself <you@company.com>

ADD ./app /usr/share/nginx/html
ADD ./certs /etc/nginx/certs
ADD ./nginx.conf /etc/nginx/
ADD ./run /

CMD sh /run
