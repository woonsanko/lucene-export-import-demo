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

if [ "$#" -lt 2 ]; then
  echo
  echo "  Usage: $0 <repository_directory_path> <index_export_download_URI> [<index_export_download_URI> ...]" >&2
  echo
  echo "  Examples:"
  echo "    > $0 repository sftp://user:pass@fileserver1.example.com:/data/index-export-latest.zip"
  echo "    > $0 /usr/local/tomcat/repository http://user:pass@fileserver1.example.com/data/index-export-latest.zip http://user:pass@fileserver2.example.com/data/index-export-latest.zip"
  echo "    > $0 /usr/local/tomcat/storage file:///data/index-export-latest.zip"
  echo "    > $0 /usr/local/tomcat/storage file:/data/index-export-latest.zip"
  echo "    > $0 /usr/local/tomcat/storage /data/index-export-latest.zip"
  echo
  exit 1
fi

# The base repository directory (e.g, "storage").
REPO_PATH="${1}"

shift
INDEX_DOWNLOAD_URIS="$@"

##########################################################################
# Configuration Parameters
##########################################################################

# Local index exported zip file name to be downloaded in a temporary directory.
LOCAL_INDEX_ZIP="index-export-latest.zip"

TEMP_DOWNLOAD_DIR="/tmp"

if [ ! -z "${CATALINA_BASE}" ]; then
  TEMP_DOWNLOAD_DIR="${CATALINA_BASE}/temp"
fi

##########################################################################
# Internal Backup Flow from here.
##########################################################################

LOCAL_INDEX_DIR="$REPO_PATH/workspaces/default/index"
TEMP_DOWNLOAD_INDEX_ZIP="${TEMP_DOWNLOAD_DIR}/${LOCAL_INDEX_ZIP}"

if [ -d "${LOCAL_INDEX_DIR}" ]; then
  echo "No need to initialize the index as it already exists at ${LOCAL_INDEX_DIR} ..."
  exit 0
fi

# If there's any local download file, remove it first before downloading.
if [ -f "${TEMP_DOWNLOAD_INDEX_ZIP}" ]; then
  rm ${TEMP_DOWNLOAD_INDEX_ZIP}
fi

# Make temp directory if not existing.
mkdir -p ${TEMP_DOWNLOAD_DIR}

LOCAL_INDEX_ZIP_DOWNLOADED="false"

# Loop each index export download URL and break the loop when successful.
for INDEX_URI in $INDEX_DOWNLOAD_URIS; do
  # Download the latest index export zip file.
  case "${INDEX_URI}" in
    sftp://*)
      sftp ${INDEX_URI:7} ${TEMP_DOWNLOAD_INDEX_ZIP}
      if [ $? -eq 0 ]; then
        LOCAL_INDEX_ZIP_DOWNLOADED="true"
        break
      fi
      ;;
    http://*)
      curl -f ${INDEX_URI} -o ${TEMP_DOWNLOAD_INDEX_ZIP}
      if [ $? -eq 0 ]; then
        LOCAL_INDEX_ZIP_DOWNLOADED="true"
        break
      fi
      ;;
    https://*)
      curl -f ${INDEX_URI} -o ${TEMP_DOWNLOAD_INDEX_ZIP}
      if [ $? -eq 0 ]; then
        LOCAL_INDEX_ZIP_DOWNLOADED="true"
        break
      fi
      ;;
    file://*)
      cp ${INDEX_URI:7} ${TEMP_DOWNLOAD_INDEX_ZIP}
      if [ $? -eq 0 ]; then
        LOCAL_INDEX_ZIP_DOWNLOADED="true"
        break
      fi
      ;;
    file:*)
      cp ${INDEX_URI:5} ${TEMP_DOWNLOAD_INDEX_ZIP}
      if [ $? -eq 0 ]; then
        LOCAL_INDEX_ZIP_DOWNLOADED="true"
        break
      fi
      ;;
    *)
      cp ${INDEX_URI} ${TEMP_DOWNLOAD_INDEX_ZIP}
      if [ $? -eq 0 ]; then
        LOCAL_INDEX_ZIP_DOWNLOADED="true"
        break
      fi
      ;;
  esac
done

# Fail if it failed to download index export zip file.
if [ "${LOCAL_INDEX_ZIP_DOWNLOADED}" != "true" ]; then
  echo "Failed to download index export zip file."
  exit 1
fi

# Make the lucene index directory under the repository directory path if not existing.
mkdir -p ${LOCAL_INDEX_DIR}
# Unzip the index export zip to the index directory.
unzip ${TEMP_DOWNLOAD_INDEX_ZIP} -d ${LOCAL_INDEX_DIR}

# Remove the temporary index export zip file
rm ${TEMP_DOWNLOAD_INDEX_ZIP}
