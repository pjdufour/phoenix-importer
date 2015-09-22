DATE=$(date)
DATE2=$(date "+%Y%m%d")
TIMESTAMP=$(date +%s)
echo "Executing daily collection of phoenix event data"
echo "Starting at $DATE"
phoenix-importer-collect-daily.sh /home/ubuntu/temp $DATE2
echo "Ending at $(date)"
