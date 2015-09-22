Phoenix Importer (phoenix-importer)
================

## Description

This repo contains scripts for importing Phoenix event data into PostGIS for use by GeoNode/GeoServer

## Installation

These installation instructions are subject to change.  Right now, since there are non-debian package dependencies, you can really extract the scripts to whatever directory you want.  The instructions below are suggested as they mirror Linux best practices for external packages.  Please be careful when installing gdal-bin and python-gdal packages as they may require different version of some packages than other programs, such as the OpenGeo Suite.  It is recommended to test this and other GDAL scripts within a vagrant environment first.

As root (`sudo su -`), for basic install execute the following:

```
apt-get update; apt-get upgrade;
apt-get install -y curl vim git
#==#
cd /opt
git clone https://github.com/pjdufour/phoenix-importer.git phoenix-importer.git
cp phoenix-importer.git/profile/phoenix-importer.sh /etc/profile.d/
#==#
source /etc/profile.d/phoenix-importer.sh
```

Depending on the context, follow either standalone, OpenGeo Suite, or GeoNode instructions.  Follow the `database` instructions after either.

### Standalone

We'll now begin project-specific initialization.  As root (`sudo su -`), run `phoenix-importer-init-standalone.sh` to:

- install Python dependencies,
- install system libraries,
- install and configure PostGiS;

### OpenGeo Suite

If you are adding to a new OpenGeo Suite deployment, run `phoenix-importer-init-opengeo.sh`.  This script will install the OpenGeo Suite and initialize the Phoenix PostGIS database.

### GeoNode

If you are adding to an existing GeoNode deployment, run `phoenix-importer-init-geonode.sh`.  This script will only set up the database and will not (re-)install/overwrite system dependencies.

### Database

Lastly, we'll need to adjust the authentication permission for PostGIS, so that OGR can authenticate using md5.  Change the pg_hba.conf file to look like the following (`vim /etc/postgresql/9.3/main/pg_hba.conf`)

```
local all postgres peer
local phoenix phoenix md5
host phoenix phoenix 127.0.0.1/32 md5
```

Restart PostGIS (`/etc/init.d/postgresql restart`) and everything should be ready.  From your regular user (`ubuntu` or `vagrant`), double check the database connecton with:

```
PGPASSWORD=phoenix psql -d phoenix -U phoenix
```

### Other Dependencies

phoenix-importer relies on `cybergis-scripts` for publishing tables in GeoServer.  Follow the instructions at [https://github.com/state-hiu/cybergis-scripts](https://github.com/state-hiu/cybergis-scripts) to install as non-debian package to `/opt/cybergis-scripts`.

## Usage

As a regular user (`vagrant` or `ubuntu`) run the following:

```Shell
phoenix-importer-init-countries.sh TEMP 
phoenix-importer-collect-daily.sh TEMP DATE
```

You'll need to run `phoenix-importer-init-countries.sh` once to download and import the country information.  Then set up a cron job to run `phoenix-importer-collect-daily` each day.  Example cron jobs are in the examples folder.

For the crontab, try

```
00 06 * * * sudo -i -u ubuntu /opt/phoenix-importer.git/cron/ubuntu_daily_update.sh >> /home/ubuntu/phoenix_log.txt
00 06 * * * sudo -i -u vagrant /opt/phoenix-importer.git/cron/vagrant_daily_update.sh >> /home/vagrant/phoenix_log.txt
```

Right now, you can create SQL Views in GeoServer.  For example, `SELECT * FROM phoenix_data_20150917;`.  Automation using the GeoServer REST API is coming soo.

## Examples

```Shell
phoenix-importer-init-countries.sh /home/vagrant/temp/countries
phoenix-importer-collect-daily.sh /home/vagrant/temp/daily 20150917
```

## Contributing

We are accepting pull requests for this repository.

## LICENSE

Copyright (c) 2015, Patrick Dufour
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of phoenix-importer nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
