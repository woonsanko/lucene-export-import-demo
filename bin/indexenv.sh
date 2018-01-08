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

REPO_PATH="${CATALINA_BASE}/repository"

INDEX_ZIP="index-export-latest.zip"
INDEX_URL="sftp://user:pass@fileserver.example.com:/data/index-export-latest.zip"
#INDEX_URL="http://user:pass@fileserver.example.com:/data/index-export-latest.zip"
#INDEX_URL="file:///data/index-export-latest.zip"

if [ ! -d "$REPO_PATH/workspaces/default/index" ]; then
  # If there's any local download file, remove it first before downloading.
  if [ -f "${CATALINA_BASE}/temp/${INDEX_ZIP}" ]; then
    rm ${CATALINA_BASE}/temp/${INDEX_ZIP}
  fi

  mkdir -p ${CATALINA_BASE}/temp

  # Download the latest index export zip file.
  case "$INDEX_URL" in
    sftp://*)
      sftp ${INDEX_URL:7} ${CATALINA_BASE}/temp/${INDEX_ZIP};;
    http://*)
      curl ${INDEX_URL:7} -o ${CATALINA_BASE}/temp/${INDEX_ZIP};;
    https://*)
      curl ${INDEX_URL:8} -o ${CATALINA_BASE}/temp/${INDEX_ZIP};;
    file://*)
      cp ${INDEX_URL:7} ${CATALINA_BASE}/temp/${INDEX_ZIP};;
    *)
      echo "Invalid index download URL that must be either sftp or http(s): '$INDEX_URL'"; exit 1;;
  esac

  # Fail if it fails to download index export zip file.
  if [ ! -f "${CATALINA_BASE}/temp/${INDEX_ZIP}" ]; then
    echo "Failed to download index export zip file."
    exit 1
  fi

  # Unzip the index export zip to the index directory.
  mkdir -p $REPO_PATH/workspaces/default/index
  unzip ${CATALINA_BASE}/temp/${INDEX_ZIP} -d $REPO_PATH/workspaces/default/index

  # Remove the temporary index export zip file
  rm ${CATALINA_BASE}/temp/${INDEX_ZIP}
fi
