#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

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
DB_PORT=5432
DB_NAME=phoenix
DB_USER=phoenix
DB_PASS=phoenix
TABLE="phoenix_data_"$DATE"_staging"
MVIEW="phoenix_data_$DATE"
sudo -u postgres psql -d phoenix -c "DROP MATERIALIZED VIEW IF EXISTS $MVIEW;"
sudo -u postgres psql -d phoenix -c "DROP TABLE IF EXISTS $TABLE;"
################
SQL=$(cat "$DIR/../lib/phoenix-importer-init-daily-raw.sql" | sed -r 's/\{table\}/'$TABLE'/')
PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=$DB_PORT -d $DB_NAME --username $DB_USER -c "$SQL"
#SQL="SELECT * FROM $TABLE LIMIT 1;"
SQL="COPY $TABLE FROM STDIN;"
cat "$TEMP/$ZIPFILE" | PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=$DB_PORT -d $DB_NAME --username $DB_USER -c "$SQL"
SQL=$(cat "$DIR/../lib/phoenix-importer-init-daily-mview.sql" | sed -r 's/\{table\}/'$TABLE'/'| sed -r 's/\{mview\}/'$MVIEW'/')
PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=$DB_PORT -d $DB_NAME --username $DB_USER -c "$SQL"
#SQL="SELECT * FROM $MVIEW LIMIT 1;"
#PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=$DB_PORT -d $DB_NAME --username $DB_USER -c "$SQL"
