#!/bin/sh

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Local index backup directory path.
LOCAL_INDEX_BACKUP_DIR="/data"

# Index export backup URLs as space separated string for optionally multiple URL(s).
INDEX_URLS="http://server1.example.com:8080/cms/ws/indexexport"
#INDEX_URLS="http://localhost:8080/cms/ws/indexexport"

# The symbolic link file name to the latest index backup zip file.
LOCAL_INDEX_SL_ZIP="index-export-latest.zip"
# Local index backup download file name with the current timestamp.
LOCAL_INDEX_TS_ZIP="index-export-$(date +'%Y%m%d-%H%M%S').zip"

mkdir -p LOCAL_INDEX_BACKUP_DIR

# Loop each index export download URL and break the loop when successful.
for INDEX_URL in $INDEX_URLS; do
  curl --user admin:admin ${INDEX_URL} -o ${LOCAL_INDEX_BACKUP_DIR}/${LOCAL_INDEX_TS_ZIP}
  if [ $? -eq 0 ]; then
    break
  fi
done

# Fail if it failed to download index export zip file.
if [ ! -f "${LOCAL_INDEX_BACKUP_DIR}/${LOCAL_INDEX_TS_ZIP}" ]; then
  echo "Failed to download index export zip file."
  exit 1
fi

# Remove the existing symbolic link if exists.
if [ -f "${LOCAL_INDEX_BACKUP_DIR}/${LOCAL_INDEX_SL_ZIP}" ]; then
  rm ${LOCAL_INDEX_BACKUP_DIR}/${LOCAL_INDEX_SL_ZIP}
fi

ln -s ${LOCAL_INDEX_BACKUP_DIR}/${LOCAL_INDEX_TS_ZIP} ${LOCAL_INDEX_BACKUP_DIR}/${LOCAL_INDEX_SL_ZIP}
