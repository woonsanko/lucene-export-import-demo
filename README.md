# lucene-export-import-demo

Simple project to test a basic scenario of the feature of [Lucene Index Export add-on](https://www.onehippo.org/library/enterprise/enterprise-features/lucene-index-export/lucene-index-export.html).

## Basic Test Scenario

### Steps

  1. Build the Lucene Index initially using ```mvn -P cargo.run -Drepo.path=storage```
     (```./storage/``` folder doesn't exist yet). Watch related logs.
  1. Stop and restart with ```mvn -P cargo.run -Drepo.path=storage```. See differences in Lucene Indexing when ```storage``` folder exists.
  1. Export Lucene Index and backup through ```curl --user admin:admin http://localhost:8080/cms/ws/indexexport -o lucene-index-backup.zip```.
  1. Stop and remove ```storage``` folder.
  1. Restore the Lucene Index backup zip file in ```storage/workspaces/default/index``` folder (which should be created manually): ```mkdir -p storage/workspaces/default/index && unzip lucene-index-backup.zip -d storage/workspaces/default/index```
  1. Restart with ```mvn -P cargo.run -Drepo.path=storage```. Note the lucene index is not wholly recreated.
     Check if ```storage/workspaces/default/index/indexRevision.properties``` file was removed. If so, it worked correctly.

## Lucene Index Logging

Add the following in ```conf/log4j*.xml```:

```xml
    <!-- Lucene indexing -->
    <Logger name="org.apache.jackrabbit.core.query.lucene.SearchIndex" level="info" />
    <Logger name="org.apache.jackrabbit.core.query.lucene.MultiIndex" level="debug" />

```

## Example Logs

### When Lucene Index is built from the scratch

```
...
INFO [localhost-startStop-1] org.apache.catalina.startup.HostConfig.deployWAR Deploying web application archive [/tmp/lucene-export-import-demo/target/tomcat8x/webapps/cms.war]
DEBUG localhost-startStop-1 [MultiIndex.createInitialIndex:390] Created initial index for 1 nodes
DEBUG localhost-startStop-1 [MultiIndex.commitVolatileIndex:1194] Committed in-memory index containing 1 documents in 128ms.
INFO  localhost-startStop-1 [SearchIndex.doInit:659] Index initialized: /tmp/lucene-export-import-demo/storage/workspaces/default/index Version: 3
DEBUG localhost-startStop-1 [MultiIndex.commitVolatileIndex:1194] Committed in-memory index containing 1001 documents in 187ms.
DEBUG localhost-startStop-1 [MultiIndex.commitVolatileIndex:1194] Committed in-memory index containing 1577 documents in 95ms.
...
```

### When Lucene Index already exists

```
...
INFO [localhost-startStop-1] org.apache.catalina.startup.HostConfig.deployWAR Deploying web application archive [/tmp/lucene-export-import-demo/target/tomcat8x/webapps/cms.war]
INFO  localhost-startStop-1 [SearchIndex.doInit:659] Index initialized: /tmp/lucene-export-import-demo/storage/workspaces/default/index Version: 3
DEBUG localhost-startStop-1 [MultiIndex.commitVolatileIndex:1194] Committed in-memory index containing 650 documents in 129ms.
...
DEBUG jackrabbit-pool-10 [MultiIndex.checkIndexingQueue:1346] updating index with 1 nodes from indexing queue.
...
```

### When Lucene Index was restored from a backup zip

```
INFO [localhost-startStop-1] org.apache.catalina.startup.HostConfig.deployWAR Deploying web application archive [/tmp/lucene-export-import-demo/target/tomcat8x/webapps/cms.war]
INFO  localhost-startStop-1 [SearchIndex.doInit:659] Index initialized: /tmp/lucene-export-import-demo/storage/workspaces/default/index Version: 3
DEBUG localhost-startStop-1 [MultiIndex.commitVolatileIndex:1194] Committed in-memory index containing 1001 documents in 150ms.
DEBUG localhost-startStop-1 [MultiIndex.commitVolatileIndex:1194] Committed in-memory index containing 1577 documents in 91ms.
...
DEBUG jackrabbit-pool-16 [MultiIndex.checkIndexingQueue:1346] updating index with 1 nodes from indexing queue.
...
```

## Possible Applications

### Nodes

- **Lucene Index Backup Repository Server** with an SFTP directory which can be accessed by CMS Server nodes.
- **CMS Server node (N)** 

### Flow

- A cron job is configured at the **Lucene Index Backup Repository Server**, and the job simply download the latest
  Lucene Index backup zip file (e.g, "lucene-index-backup-20180106.zip") to an SFTP directory
  and create a symbolic link to it (e.g, "lucene-index-backup-latest.zip") in the SFTP directory.
- When a **CMS Server node (N)** is started, whether it's new or existing node, it checks if its repository folder
  contains a non-empty ```index``` directory (e.g, ```storage/workspaces/default/index```).
  This kind of checking can be done in ```$CATALINA_BASE/bin/index-init.sh``` which can be invoked by ```$CATALINA_BASE/bin/setenv.sh```, for example.
- If there's no non-empty ```index``` directory, it downloads "lucene-index-backup-latest.zip" file from the SFTP directory.
  Extracts the zip file into the ```index``` directory.
- This way, even when a new **CMS Server node (N)** is just added and started, the lucene index won't be created
  from the scratch, but initialized fast enough. 

### Example Script on Lucene Index Backup Repository Server

You might want to execute [index-backup.sh](https://github.com/woonsanko/recipe-for-dockerizing-hippo-cms/blob/master/examples/index-backup.sh) periodically (perhaps by configuring as a CRON job). The script can be put anywhere on the **Lucene Index Backup Repository Server**.
The script can download the latest index export zip file and create a symbolic link for downloads from a **Example Script on CMS Server node (N)**.

Reference about CRON: https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/

### Example Script on CMS Server node (N)

You might want to add the following line in ```$CATALINA_BASE/bin/setenv.sh``` file:

```bash
# Check for index specific configurations at startup...
if [ -r "$CATALINA_BASE/bin/index-init.sh" ]; then
  . "$CATALINA_BASE/bin/index-init.sh" "$REPO_PATH" $INDEX_EXPORT_ZIP_URIS
fi
```

to execute [index-init.sh](https://github.com/woonsanko/recipe-for-dockerizing-hippo-cms/blob/master/examples/index-init.sh) optionally.
