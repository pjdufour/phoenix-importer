#!/bin/bash

if [ -z "$1" ]; then
    echo "Temp directory must be specified."
    exit 0
fi

if [ -z "$2" ]; then
    echo "Date must be specified."
    exit 0
fi

TEMP=$1
DATE=$2

if [[ ! "$TEMP" = /* ]]; then
    echo "Temp directory must be fully qualified"
    exit 0
fi

if [ ! -d "$TEMP" ]; then
    mkdir -p $TEMP
fi
cd $TEMP

ZIPFILE="events.full.$DATE.txt.zip"
BASEURL="https://s3.amazonaws.com/openeventdata/current/"

if [ ! -f "$ZIPFILE" ]; then
    wget "$BASEURL$ZIPFILE" -O $ZIPFILE 
fi

unzip -u $ZIPFILE

DB_HOST=localhost
DB_HOST=5432
DB_NAME=phoenix
DB_USER=phoenix
DB_PASS=phoenix
TABLE='phoenix_data_$DATE'
SQL="SELECT * FROM $TABLE LIMIT 1;"
PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=$DB_PORT --username $DB_USER -c "$SQL"
