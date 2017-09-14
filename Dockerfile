FROM python:alpine
MAINTAINER butlerx <cian@coderdojo.org>
RUN apk add --update bash postgresql openssl && \
    pip install awscli==1.10.38 && \
    mkdir /scripts
COPY backupToS3.sh /scripts/backupToS3.sh
CMD ["bin/sh", "/scripts/backupToS3.sh"]
