FROM nginx:alpine
COPY init.sh nginx.conf /etc/nginx/
ENTRYPOINT ["/etc/nginx/init.sh"]
EXPOSE 80
