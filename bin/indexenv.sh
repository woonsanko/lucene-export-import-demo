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

# The base repository directory (e.g, "storage").
REPO_PATH="${CATALINA_BASE}/repository"

# Space separated (multiple) index export/download URLs. Each URL is tried as ordered.
INDEX_URLS="sftp://user:pass@fileserver.example.com:/data/index-export-latest.zip"
#INDEX_URLS="http://user:pass@fileserver.example.com:/data/index-export-latest.zip"
#INDEX_URLS="file:///data/index-export-latest.zip"

# Local index exported zip file name to be downloaded in a temporary directory.
LOCAL_INDEX_ZIP="index-export-latest.zip"

# Should try to download index export zip only when the index directory doesn't exist (e.g, on a clean cluster node).
if [ ! -d "$REPO_PATH/workspaces/default/index" ]; then
  # If there's any local download file, remove it first before downloading.
  if [ -f "${CATALINA_BASE}/temp/${LOCAL_INDEX_ZIP}" ]; then
    rm ${CATALINA_BASE}/temp/${LOCAL_INDEX_ZIP}
  fi

  # Make temp directory if not existing.
  mkdir -p ${CATALINA_BASE}/temp

  LOCAL_INDEX_ZIP_DOWNLOADED="false"

  # Loop each index export download URL and break the loop when successful.
  for INDEX_URL in $INDEX_URLS; do
    # Download the latest index export zip file.
    case "$INDEX_URL" in
      sftp://*)
        sftp ${INDEX_URL:7} ${CATALINA_BASE}/temp/${LOCAL_INDEX_ZIP}
        if [ $? -eq 0 ]; then
          LOCAL_INDEX_ZIP_DOWNLOADED="true"
          break
        fi
        ;;
      http://*)
        curl ${INDEX_URL:7} -o ${CATALINA_BASE}/temp/${LOCAL_INDEX_ZIP}
        if [ $? -eq 0 ]; then
          LOCAL_INDEX_ZIP_DOWNLOADED="true"
          break
        fi
        ;;
      https://*)
        curl ${INDEX_URL:8} -o ${CATALINA_BASE}/temp/${LOCAL_INDEX_ZIP}
        if [ $? -eq 0 ]; then
          LOCAL_INDEX_ZIP_DOWNLOADED="true"
          break
        fi
        ;;
      file://*)
        cp ${INDEX_URL:7} ${CATALINA_BASE}/temp/${LOCAL_INDEX_ZIP}
        if [ $? -eq 0 ]; then
          LOCAL_INDEX_ZIP_DOWNLOADED="true"
          break
        fi
        ;;
      *)
        echo "Invalid index download URL that must be either sftp or http(s): '$INDEX_URL'"; exit 1;;
    esac
  done

  # Fail if it failed to download index export zip file.
  if [ "${LOCAL_INDEX_ZIP_DOWNLOADED}" != "true" ]; then
    echo "Failed to download index export zip file."
    exit 1
  fi

  # Make the lucene index directory under the repository directory path if not existing.
  mkdir -p $REPO_PATH/workspaces/default/index
  # Unzip the index export zip to the index directory.
  unzip ${CATALINA_BASE}/temp/${LOCAL_INDEX_ZIP} -d $REPO_PATH/workspaces/default/index

  # Remove the temporary index export zip file
  rm ${CATALINA_BASE}/temp/${LOCAL_INDEX_ZIP}
fi
