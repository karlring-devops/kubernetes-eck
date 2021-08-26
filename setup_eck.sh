#!/bin/bash

# /**********************************************/
# /-- sources: 
# /**********************************************/
# /   https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-beat-configuration-examples.html
# /   https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-elasticsearch.html
# /   https://github.com/elastic/cloud-on-k8s
# /**********************************************/

#/---- kill port-forwards ----/
for p in $(ps -ef | grep kubectl | grep 'port-forward' | awk '{print $2}')
do
	kill -9 ${p}
done

setup_storage(){
	kubectl create -f k8s-default-storage-class-volume-node1.yaml  
	kubectl create -f k8s-default-storage-class-volume-node2.yaml  
	kubectl create -f k8s-default-storage-class-volume-node3.yaml
	#/--- WARNING: have to set default or pods remain in PENDING ------/ 
  kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
	# setup_storage
}

rm_storage(){
	kubectl delete -f k8s-default-storage-class-volume-node1.yaml  
	kubectl delete -f k8s-default-storage-class-volume-node2.yaml  
	kubectl delete -f k8s-default-storage-class-volume-node3.yaml
	# setup_storage
}

# YAML=https://download.elastic.co/downloads/eck/1.7.0/crds.yaml
# wget ${YAML} 
kubectl create -f crds.yaml

# YAML=https://download.elastic.co/downloads/eck/1.7.0/operator.yaml
# wget ${YAML}
kubectl create -f operator.yaml


# cat <<EOF >./elasticsearch-es-default.yaml
# apiVersion: elasticsearch.k8s.elastic.co/v1
# kind: Elasticsearch
# metadata:
#   name: elasticsearch
# spec:
#   version: 7.14.0
#   nodeSets:
#   - name: default
#     count: 3
#     config:
#       node.store.allow_mmap: false
# EOF
kubectl apply -f elasticsearch-es-default.yaml

# cat <<EOF >./kibana-kb.yaml
# apiVersion: kibana.k8s.elastic.co/v1
# kind: Kibana
# metadata:
#   name: kibana
# spec:
#   version: 7.14.0
#   count: 1
#   elasticsearchRef:
#     name: elasticsearch
# EOF
kubectl apply -f kibana-kb.yaml
kubectl edit svc kibana-kb-http -n default
PASSWORD=$(kubectl get secret elasticsearch-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
echo "Elastic Login: elastic|$PASSWORD"
NODEPORT=$(kubectl get svc -n default  | grep kibana | cut -d':' -f 2|cut -d'/' -f1)
echo "Elastic URL  : https://192.168.7.2:${NODEPORT}"


#Source: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-beat-configuration-examples.html
wget https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/metricbeat_hosts.yaml
kubectl apply -f metricbeat_hosts.yaml

#Source: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-beat-configuration-examples.html
wget https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/filebeat_autodiscover.yaml
kubectl apply -f filebeat_autodiscover.yaml

# #Source: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-beat-configuration-examples.html
# wget https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/filebeat_autodiscover_by_metadata.yaml
# kubectl apply -f filebeat_autodiscover_by_metadata.yaml

# #Source: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-beat-configuration-examples.html
# wget https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/stack_monitoring.yaml
# kubectl apply -f stack_monitoring.yaml
# kubectl scale -n default statefulset elasticsearch-monitoring-es-default --replicas=1

#  daemonset.apps/filebeat-beat-filebeat

# kubectl get daemonset filebeat-beat-filebeat -n default -o yaml

# wget https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/heartbeat_es_kb_health.yaml
kubectl apply -f heartbeat_es_kb_health.yaml

# wget https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/journalbeat_hosts.yaml
kubectl apply -f journalbeat_hosts.yaml

# wget https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/packetbeat_dns_http.yaml
kubectl apply -f packetbeat_dns_http.yaml

# wget https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/auditbeat_hosts.yaml
kubectl apply -f auditbeat_hosts.yaml

# cat <<EOF >./apm-server-default.yaml
# apiVersion: apm.k8s.elastic.co/v1
# kind: ApmServer
# metadata:
#   name: apm-server-default
#   namespace: default
# spec:
#   version: 7.14.0
#   count: 3
#   elasticsearchRef:
#     name: elasticsearch
# EOF
kubectl apply -f apm-server-default.yaml
watch kubectl get apmservers
kubectl get pods --selector='apm.k8s.elastic.co/name=apm-server-default'

# /**********************************************/
# EOF
# /**********************************************/
