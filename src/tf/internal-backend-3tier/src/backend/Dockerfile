FROM python:3.10-slim-bullseye

ENV APP_LISTEN_IP=0.0.0.0
ENV APP_PORT=80
ENV RDS_HOST="http://0.0.0.0:5432"
ENV RDS_PWD=""
EXPOSE ${APP_PORT}

RUN mkdir /app
WORKDIR /app
ADD requirements.txt /app
ADD main.py /app
RUN pip3 install -r requirements.txt

CMD uvicorn main:app --host ${APP_LISTEN_IP} --port ${APP_PORT}
