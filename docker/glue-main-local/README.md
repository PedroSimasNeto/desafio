# Glue main local em Docker

Esta pasta contem uma execucao local do fluxo de transformacao e data quality do `app/glue/src/main.py`, sem dependencias de runtime AWS Glue.

## O que este processo faz

- Le CSV de entrada.
- Aplica as mesmas selecoes/casts de colunas do Glue main.
- Gera coluna de particionamento `anomesdia`.
- Executa regras de Data Quality com Great Expectations usando `app/glue/utils/quality/config/config.json`.
- Grava saida em Parquet local particionado por `anomesdia`.

## Build

```bash
docker build -f docker/glue-main-local/Dockerfile -t desafio-glue-main-local .
```

## Run

```bash
docker run --rm \
  -v "$(pwd)/data:/opt/project/data" \
  -v "$(pwd)/output:/opt/project/output" \
  desafio-glue-main-local
```

## Parametros opcionais

```bash
docker run --rm \
  -v "$(pwd)/data:/opt/project/data" \
  -v "$(pwd)/output:/opt/project/output" \
  desafio-glue-main-local \
  python /opt/project/docker/glue-main-local/run_main_local.py \
  --input-path /opt/project/data/input.csv \
  --output-path /opt/project/output/desafio \
  --dq-config /opt/project/app/glue/utils/quality/config/config.json
```
