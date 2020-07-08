FROM continuumio/miniconda3:4.7.12

RUN adduser --disabled-password --gecos "Default user" --uid 1000 eggplant

RUN mkdir /opt/conda/envs/eggplant /opt/conda/pkgs && \
    chgrp eggplant /opt/conda/pkgs && \
    chmod g+w /opt/conda/pkgs && \
    touch /opt/conda/pkgs/urls.txt && \
    chown eggplant /opt/conda/envs/eggplant /opt/conda/pkgs/urls.txt

RUN mkdir -p /app

RUN chown -R eggplant:eggplant /app

RUN chmod 755 /app

USER 1000

ADD environment.yml /tmp/environment.yml

RUN conda env create -f /tmp/environment.yml

SHELL ["conda", "run", "-n", "eggplant", "/bin/bash", "-c"]

COPY . /app

WORKDIR /app

ARG DB_URL

ARG DB_PORT

ARG DB_USERNAME

ARG DB_PASSWORD

ARG DB_NAME

ARG DB_AUTHENTICATION

RUN python trainModel.py

ENV DB_URL="host.docker.internal" \
    DB_PORT=27017 \
    RABBIT_MQ_HOST="host.docker.internal" \
    RABBIT_MQ_PORT=5672 \
    RABBIT_MQ_SERVER="rabbitmq"

CMD python predictionLoop.py
