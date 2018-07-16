FROM node:10-alpine
WORKDIR /opt/app

RUN apk --no-cache add zfs

COPY package.json ./
RUN npm install && rm -f package-lock.json

COPY server.js ./

CMD ["node", "server.js", "--zfs"]
EXPOSE 3000
