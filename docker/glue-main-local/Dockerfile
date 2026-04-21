FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYSPARK_PYTHON=python3
ENV PYTHONPATH=/opt/project/app/glue

WORKDIR /opt/project

RUN apt-get update \
    && apt-get install -y --no-install-recommends default-jre-headless procps \
    && rm -rf /var/lib/apt/lists/*

COPY docker/glue-main-local/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY app/glue /opt/project/app/glue
COPY docker/glue-main-local/run_main_local.py /opt/project/docker/glue-main-local/run_main_local.py

CMD ["python", "/opt/project/docker/glue-main-local/run_main_local.py", "--input-path", "/opt/project/data/input.csv", "--output-path", "/opt/project/output/desafio"]
