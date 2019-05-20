#!/usr/bin/env bash

set -e

: "${S3_BUCKET:?"No value supplied for s3 bucket name"}"

echo "Checking Credentials before starting backup"
: "${PGHOST:?"Need to set PGHOST non-empty?"}"
: "${PGPORT:?"Need to set PGPORT non-empty?"}"
: "${PGDATABASE:?"Need to set PGDATABASE non-empty?"}"
: "${PGUSER:?"Need to set PGUSER non-empty?"}"
: "${PGPASSWORD:?"Need to set PGPASSWORD non-empty?"}"

if [ ! -e ~/.aws/credentials ]; then
  echo "AWS credentials file not found." >&2
  : "${AWS_ACCESS_KEY_ID:?"Need to set AWS_ACCESS_KEY_ID non-empty?"}"
  : "${AWS_SECRET_ACCESS_KEY:?"Need to set AWS_SECRET_ACCESS_KEY non-empty?"}"
fi

mkdir backup_dump
args=("$@")
dump_command="pg_dump -Fd -f backup_dump ${args[*]} '${PGDATABASE}' --verbose"
echo "Starting ${dump_command}"
eval "$dump_command"
if [ "$(ls -A backup_dump)" ]; then
  echo "PGDUMP Complete"
else
  echo "PGDUMP failed"
  exit -1
fi

now=$(date +%d-%m-%Y-%H-%M-%S)
today=$(date +%u)
zipped_filename="$PGDATABASE-$now.tar.gz"
tar -zcvf "$zipped_filename" backup_dump/
rm -rf backup_dump/
echo "Completed Backup"

if aws s3 ls "s3://$S3_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
  echo "${S3_BUCKET} bucket does not exist"
  echo "Create s3://${S3_BUCKET}"
  aws s3 mb --region "$S3_REGION" s3://"$S3_BUCKET"
  sleep 30
fi

aws s3 cp --region "$S3_REGION" "$zipped_filename" s3://"$S3_BUCKET/daily/"
if [ "$today" == "7" ]; then
  aws s3 cp --region "$S3_REGION" "$zipped_filename" s3://"$S3_BUCKET/weekly/"
fi
sleep 30
rm "$zipped_filename"
exit 0
