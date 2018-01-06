# lucene-export-import-demo

Simple project to test a basic scenario of the feature of [Lucene Index Export add-on](https://www.onehippo.org/library/enterprise/enterprise-features/lucene-index-export/lucene-index-export.html).

## Basic Test Scenario

### Steps

  1. Build the Lucene Index initially using ```mvn -P cargo.run -Drepo.path=storage```
     (```./storage/``` folder doesn't exist yet). Watch related logs.
  1. Stop and restart with ```mvn -P cargo.run -Drepo.path=storage```. See differences in Lucene Indexing when ```storage``` folder exists.
  1. Export Lucene Index and backup through ```http://admin:admin@localhost:8080/cms/ws/indexexport -o lucene-index-backup.zip```.
  1. Stop and remove ```storage``` folder.
  1. Restore the Lucene Index backup zip file in ```storage/workspaces/default/index``` folder (which should be created manually): ```mkdir -p storage/workspaces/default/index && unzip lucene-index-backup.zip -d storage/workspaces/default/index```
  1. Restart with ```mvn -P cargo.run -Drepo.path=storage```. Note the lucene index is not wholly recreated.

