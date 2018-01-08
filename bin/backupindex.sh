#!/bin/sh

INDEX_DIR="/data"
INDEX_SL_ZIP="index-export-latest.zip"
INDEX_TS_ZIP="index-export-$(date +'%Y%m%d-%H%M%S').zip"
INDEX_URL="http://server1.example.com:8080/cms/ws/indexexport"

curl --user admin:admin ${INDEX_URL} -o ${INDEX_DIR}/${INDEX_TS_ZIP}

if [ ! $? -eq 0 ]; then
  echo "Failed to download the latest index export zip file from '${INDEX_URL}'."
  exit 1
fi

# Remove the existing symbolic link if exists.
if [ -f "${INDEX_DIR}/${INDEX_SL_ZIP}" ]; then
  rm ${INDEX_DIR}/${INDEX_SL_ZIP}
fi

ln -s ${INDEX_DIR}/${INDEX_TS_ZIP} ${INDEX_DIR}/${INDEX_SL_ZIP}
