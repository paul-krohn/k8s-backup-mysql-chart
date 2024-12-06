#!/bin/bash

set -e
set -o pipefail

if [[ "${DEBUG}" != "" ]] ; then
  set -x
fi

BACKUP_DATE_FORMAT=${BACKUP_DATE_FORMAT:=%F-%H:%M:%S}
BACKUP_PREFIX=${BACKUP_PREFIX:=backups}
REQUIRED_VARS=("TARGET_DATABASES" "AWS_BUCKET_URI")

function notify() {
  if [ -n "${NOTIFICATION_WEBHOOK_URL}" ] ; then
    curl -X POST -d "message=$1" "${NOTIFICATION_WEBHOOK_URL}"
  fi
}

function usage() {
  echo "all of ${REQUIRED_VARS[*]} are required as env vars"
  exit 1
}

for ((i=0; i<${#REQUIRED_VARS[@]}; i++)); do {
  if [ -z "${!REQUIRED_VARS[$i]}" ] ; then
    usage
  fi
} ; done

for CURRENT_DATABASE in ${TARGET_DATABASES//,/ } ; do
  BACKUP_LOCATION="${AWS_BUCKET_URI}${BACKUP_PREFIX}/$(date "+${BACKUP_DATE_FORMAT}").tar.gz"
  if BACKUP_OUTPUT=$(mysqldump "${CURRENT_DATABASE}" | gzip -9 | aws s3 ${S3_OPTIONS} cp - "${BACKUP_LOCATION}" 2>&1) ; then
    echo -e "Database backup successfully completed for $CURRENT_DATABASE to ${BACKUP_LOCATION}"
  else
    notify "Database backup failed for ${CURRENT_DATABASE} at $(date +'%d-%m-%Y %H:%M:%S'). Output: ${BACKUP_OUTPUT}" 
  fi
done
