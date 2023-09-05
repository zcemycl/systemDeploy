FROM python:3.10-slim-bullseye

ENV APP_LISTEN_IP=0.0.0.0
ENV APP_PORT=80
EXPOSE ${APP_PORT}

RUN mkdir /app
WORKDIR /app
ADD requirements.txt /app
ADD main.py /app
RUN pip3 install -r requirements.txt

CMD gunicorn -w 4 -b ${APP_LISTEN_IP}:${APP_PORT} main:app
