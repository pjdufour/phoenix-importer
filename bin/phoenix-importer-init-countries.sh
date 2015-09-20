#!/bin/bash

if [ -z "$1" ]; then
    echo "Temp directory not specified."
    exit 0
fi

TEMP=$1

if [[ ! "$TEMP" = /* ]]; then
    echo "Temp directory must be fully qualified"
    exit 0
fi

if [ ! -d "$TEMP" ]; then
    mkdir -p $TEMP
fi
cd $TEMP

BASEURL="http://geonode.state.gov/geoserver/wfs?format_options=charset%3AUTF-8&typename=geonode%3A{name}&outputFormat=SHAPE-ZIP&version=1.0.0&service=WFS&request=GetFeature"

NAME_AFRICA_AMERICAS="AfricaAmericas_LSIB_Polygons_Simplified_2015"
NAME_EURASIA_OCEANIA="EurasiaOceania_LSIB_Polygons_Simplified_2015"

if [ ! -f "$NAME_AFRICA_AMERICAS.zip" ]; then
    wget $(echo $BASEURL | sed -r 's/\{name\}/'$NAME_AFRICA_AMERICAS'/') -O "$NAME_AFRICA_AMERICAS.zip"
fi

if [ ! -f "$NAME_EURASIA_OCEANIA.zip" ]; then
    wget $(echo $BASEURL | sed -r 's/\{name\}/'$NAME_EURASIA_OCEANIA'/') -O "$NAME_EURASIA_OCEANIA.zip"
fi

unzip -u $NAME_AFRICA_AMERICAS.zip
unzip -u $NAME_EURASIA_OCEANIA.zip

#SHP="$TEMP/Global_LSIB_Polygons_Simplified_2015.shp"
#rm $SHP
#ogr2ogr -f "ESRI Shapefile" $SHP "$NAME_AFRICA_AMERICAS.shp"
#ogr2ogr -f "ESRI Shapefile" -append -overwrite $SHP "$NAME_EURASIA_OCEANIA.shp"

DB_HOST=localhost
DB_NAME=phoenix
DB_USER=phoenix
DB_PASS=phoenix
TABLE='countries'
sudo -u postgres psql -d phoenix -c "DROP TABLE IF EXISTS $TABLE;"
ogr2ogr -lco PRECISION=NO -f "PostgreSQL" PG:"host=$DB_HOST user=$DB_USER dbname=$DB_NAME password=$DB_PASS" -nln $TABLE -nlt "MULTIPOLYGON" "$NAME_AFRICA_AMERICAS.shp"
ogr2ogr -append -f "PostgreSQL" PG:"host=$DB_HOST user=$DB_USER dbname=$DB_NAME password=$DB_PASS" -nln $TABLE -nlt "MULTIPOLYGON" "$NAME_EURASIA_OCEANIA.shp"
