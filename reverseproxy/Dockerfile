FROM nginx:alpine
LABEL maintainer "Shyam Sunder <sgsunder1@gmail.com>"

COPY init.sh nginx.conf /etc/nginx/

ENTRYPOINT ["/etc/nginx/init.sh"]
EXPOSE 80
