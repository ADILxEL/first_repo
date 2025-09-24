FROM python:3.12-slim-bookworm AS base

WORKDIR /usr/src/app 

COPY requirements.txt .

RUN python -m pip install --upgrade pip

RUN python -m pip install -r requirements.txt

COPY . .


ENTRYPOINT ["python", "recommendation_server.py"]

