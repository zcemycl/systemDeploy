FROM node:18-alpine

RUN apk add --no-cache clamav
COPY package.json package-lock.json index.js ./
RUN npm install
RUN freshscan

CMD ["/bin/bash"]
