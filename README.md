# kubernetes-eck (requires: cluster-vagrant-kubernetes-nfs)

Create Full Stack Elastic ECK Cluster on Kubernetes. 

## Instructions

execute  . ./setup_eck.sh

## Notes

Assumes you have 3 x slave nodes (k8s).

Can take upto 15-20mins for all the ECK componnents to initiliase and register within the ECK Cluster.  You can get the login from the "getlogin" function in the script if you don't see it during the setup on your terminal.

## Warning - Save disk and cpu on index processing

Full stack ECK on kubernetes generates alot (i mean alot) of stream data on disk in Gib's very quickly.  I suggest after ECK Cluster is ready:

   1) Login to Kibana
   2) Manage -> https://192.168.7.2:your_kibana-kb-http_NodePort/app/management
   3) Index Lifecycle Policies > change Hot /Warm 1mins /Cold 2mins and merge, readonly, re-index etc for:
  
          auditbeat, filebeat, heartbeat, jounalbeat, metricbeat, packetbeat(important)
   
  4) Index Management (foreach above beats):
  
      click on index name
      Edit Settings
      change "index.refresh_interval": "60s" to 60 seconds... default is 5s.
  
  5) Dashbboard - change your default refresh rate to 1min. defaults 5s. this will reduce CPU/RAM on over querying metadata logs etc.
  
  
