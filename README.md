# Postgres Backup Script

Script for backing up postres database dumps to AWS S3

## Start

``` bash
docker run --rm \
  -e PGHOST="" \
  -e PGPORT="" \
  -e PGDATABASE="" \
  -e PGUSER="" \
  -e PGPASSWORD="" \
  -e AWS_ACCESS_KEY_ID="" \
  -e AWS_SECRET_ACCESS_KEY="" \
  -e S3_BUCKET="" \
  CoderDojo/pg-backup
```

## Build
docker build . --tag=coderdojo/pg-backup

## Push
docker push coderdojo/pg-backup
