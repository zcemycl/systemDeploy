FROM node:lts-alpine

ENV APP_PORT=3001
EXPOSE ${APP_PORT}

RUN mkdir /app
WORKDIR /app
COPY package*.json .
COPY src .
RUN npm install
CMD npm run dev
