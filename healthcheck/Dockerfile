FROM node:10-alpine
LABEL maintainer "Shyam Sunder <sgsunder1@gmail.com>"
WORKDIR /opt/app

# Get System Depenencies
RUN apk --no-cache add \
        zfs

# Get Node Dependencies
COPY package.json ./
RUN npm install \
 && rm -f package-lock.json

# Copy Application Files
COPY server.js ./

# Final Touches
CMD ["node", "server.js", "--zfs"]
EXPOSE 3000
