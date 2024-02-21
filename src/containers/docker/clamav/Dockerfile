FROM node:18-alpine

RUN apk add --update util-linux
RUN apk add --no-cache clamav
RUN chmod -R 777 /usr/bin/clam*
COPY package.json package-lock.json index_.js ./
RUN npm install

RUN freshclam

# CMD ["/bin/sh"]
CMD ["node", "index_.js"]
