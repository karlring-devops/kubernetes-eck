# kubernetes ElasticSearch ECK Cluster

Create Full Stack ElasticSearch ECK Cluster on Kubernetes. 
(requires: [cluster-vagrant-kubernetes-nfs](https://github.com/karlring-devops/cluster-vagrant-kubernetes-nfs))

## Instructions

execute  . ./setup_eck.sh

## Notes

Assumes you have 3 x slave nodes (k8s).

Can take upto 15-20mins for all the ECK componnents to initiliase and register within the ECK Cluster.  You can get the login from the "getlogin" function in the script if you don't see it during the setup on your terminal.

## Warning - Save disk and cpu on index processing

Full stack ECK on kubernetes generates alot (i mean alot) of stream data on disk in Gib's very quickly.  I suggest after ECK Cluster is ready:

   1) Login to Kibana       (login details use [setup_eck.sh](https://github.com/karlring-devops/kubernetes-eck/blob/main/setup_eck.sh) FUNCTION: k8s_get_login_kibana)
   2) Manage -> https://192.168.7.2:your_kibana-kb-http_NodePort/app/management 
   3) Index Lifecycle Policies > change Hot /Warm 1mins /Cold 2mins and merge, readonly, re-index etc for:
  
          auditbeat, filebeat, heartbeat, jounalbeat, metricbeat, packetbeat(important)
   
  4) Index Management (foreach above beats):
  
      click on index name
      Edit Settings
      change "index.refresh_interval": "60s" to 60 seconds... default is 5s.
  
  5) Dashbboard - change your default refresh rate to 1min. defaults 5s. this will reduce CPU/RAM on over querying metadata logs etc.
  
  On iMac i7(late 2013),32Gib RAM (1600mhz), 250Gib SSD the following seems quite stable and fast with a full stack ELASTIC-ECK, JENKINS-NFS, and KUBERNETES-DASHBOARD from my other repos. The Average iMac CPU Load is 25-30%, Memory usage is 25Gib RAM, when the full k8s-ECK stack is idle but fully active.
  
 ## [Index Management] 24x hours of disk index usage 
 
For major beats installed in the basic the ECK is as below, look at packebeat 15Gib in 24hours! 
 
 
  ![Screen Shot 2021-08-27 at 2 05 04 PM](https://user-images.githubusercontent.com/56421115/131105851-1c0af0de-2b6a-4b11-8d02-0614ebe7d6fc.png)



## [Index Lufecycle Policies] Beats to "Scale Down"

Update the HOT/WALM/COLD, merge,re-indexing, readonly times and parameters of the index management of the major beats in this list:

![Screen Shot 2021-08-27 at 2 05 56 PM](https://user-images.githubusercontent.com/56421115/131106316-21bd7e3a-4780-46d0-9c96-67e75477147d.png)
