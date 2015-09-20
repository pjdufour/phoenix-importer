# Assert Latest Ubuntu
apt-get update; apt-get upgrade;
# Install Basic CLI
apt-get install -y vim git unzip
# Install Python Basics
#apt-get install -y python-software-properties
# Install OpenGeo Suite Repo
wget -qO - http://apt.boundlessgeo.com/gpg.key | apt-key add -
echo "deb http://apt.boundlessgeo.com/suite/v4/ubuntu/ precise main" > /etc/apt/sources.list.d/boundlessgeo.list
apt-get update
# Install OpenGeo Suite
apt-get install opengeo
# Remove Sensitive Documents
cat /var/lib/opengeo/geoserver/security/masterpw.info
rm -f /var/lib/opengeo/geoserver/security/masterpw.info
rm -f /var/lib/opengeo/geoserver/security/users.properties.old
# Initialize PostGIS
sudo -u postgres psql -c "CREATE USER phoenix WITH ENCRYPTED PASSWORD 'phoenix';"
sudo -u postgres psql -c "CREATE DATABASE template_postgis ENCODING 'UTF8' TEMPLATE template1;"
sudo -u postgres psql -d template_postgis -c "CREATE EXTENSION postgis;"
sudo -u postgres psql -c "CREATE DATABASE phoenix ENCODING 'UTF8' TEMPLATE template_postgis;"
sudo -u postgres psql -d phoenix -c "ALTER DATABASE phoenix OWNER TO phoenix;"
sudo -u postgres psql -d phoenix -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO phoenix;"
