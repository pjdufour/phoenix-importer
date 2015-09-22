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

BASEFILE="events.full.$DATE.txt"
ZIPFILE="$BASEFILE.zip"
BASEURL="https://s3.amazonaws.com/openeventdata/current/"

echo "Accessing $TEMP/$ZIPFILE"

if [ ! -f "$TEMP/$ZIPFILE" ]; then
    wget "$BASEURL$ZIPFILE" -O "$TEMP/$ZIPFILE" 
fi

unzip -u $ZIPFILE

if [ ! -f "$TEMP/$BASEFILE" ]; then
    echo "No event data available for date $DATE"
    exit 0
fi

if [ ! -s "$TEMP/$BASEFILE" ]; then
    echo "No event data available for date $DATE"
    exit 0
fi

DB_HOST=localhost
DB_PORT=5432
DB_NAME=phoenix
DB_USER=phoenix
DB_PASS=phoenix
TABLE1="phoenix_data_"$DATE"_staging"
TABLE2="phoenix_data_$DATE"
#sudo -u postgres psql -d phoenix -c "DROP MATERIALIZED VIEW IF EXISTS $MVIEW;"
sudo -u postgres psql -d phoenix -c "DROP TABLE IF EXISTS $TABLE2;"
sudo -u postgres psql -d phoenix -c "DROP TABLE IF EXISTS $TABLE1;"
################
SQL=$(cat "$DIR/../lib/phoenix-importer-init-daily-raw.sql" | sed -r 's/\{table\}/'$TABLE1'/')
PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=$DB_PORT -d $DB_NAME --username $DB_USER -c "$SQL"
#SQL="SELECT * FROM $TABLE LIMIT 1;"
SQL="COPY $TABLE1 FROM STDIN;"
cat "$TEMP/$BASEFILE" | PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=$DB_PORT -d $DB_NAME --username $DB_USER -c "$SQL"
SQL=$(cat "$DIR/../lib/phoenix-importer-init-daily-final.sql" | sed -r 's/\{table1\}/'$TABLE1'/'| sed -r 's/\{table2\}/'$TABLE2'/')
PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=$DB_PORT -d $DB_NAME --username $DB_USER -c "$SQL"
#SQL="SELECT * FROM $MVIEW LIMIT 1;"
#PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=$DB_PORT -d $DB_NAME --username $DB_USER -c "$SQL"
################
GS='http://localhost:8080/geoserver/'
WS='phoenix'
DS='phoenix'
FT=$TABLE2
GS_USER='admin'
GS_PASS='geoserver'
cybergis-script-geoserver-publish-layers.py -gs $GS -ws $WS -ds $DS -ft $FT --username $GS_USER --password $GS_PASS
