FROM python:3.11
WORKDIR /app/
COPY ./src/main.py .
COPY ./requirements.txt .
RUN pip install -r requirements.txt
CMD uvicorn main:app --host 0.0.0.0 --port 8888
EXPOSE 8888
