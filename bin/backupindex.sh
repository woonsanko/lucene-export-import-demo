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

INDEX_DIR="/data"
INDEX_SL_ZIP="index-export-latest.zip"
INDEX_TS_ZIP="index-export-$(date +'%Y%m%d-%H%M%S').zip"
INDEX_URL="http://server1.example.com:8080/cms/ws/indexexport"
#INDEX_URL="http://localhost:8080/cms/ws/indexexport"

mkdir -p INDEX_DIR
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
