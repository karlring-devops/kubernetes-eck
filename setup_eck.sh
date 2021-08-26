#!/bin/bash

# /**********************************************/
# /-- sources: 
# /**********************************************/
# /   https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-beat-configuration-examples.html
# /   https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-elasticsearch.html
# /   https://github.com/elastic/cloud-on-k8s
# /**********************************************/
# /  All original YAML URL's are in each file.
# /**********************************************/


  k8s_create_storageclass_standard(){	kubectl create -f k8s-default-storage-class.yaml ; }
	#/--- WARNING: have to set DEFAULT or pods remain in PENDING ------/
    k8s_patch_storageclass_default(){ kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' ; }
 k8s_create_persistentvolume_node1(){ kubectl create -f k8s-default-storage-class-volume-node1.yaml ; }
 k8s_create_persistentvolume_node2(){ kubectl create -f k8s-default-storage-class-volume-node2.yaml ; }  
 k8s_create_persistentvolume_node3(){ kubectl create -f k8s-default-storage-class-volume-node3.yaml ; }

     k8s_create_crds(){ kubectl create -f crds.yaml ; }
k8s_create_operators(){ kubectl create -f operator.yaml ; }
k8s_apply_es_default(){ kubectl apply  -f elasticsearch-es-default.yaml ; }
 k8s_apply_kibana_kb(){ kubectl apply  -f kibana-kb.yaml ; }
  k8s_edit_kibana_kb(){ kubectl edit   svc kibana-kb-http -n default ; }

k8s_get_login_kibana(){
	PASSWORD=$(kubectl get secret elasticsearch-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
	echo "Elastic Login: elastic|$PASSWORD"
	NODEPORT=$(kubectl get svc -n default  | grep kibana | cut -d':' -f 2|cut -d'/' -f1)
	echo "Elastic URL  : https://192.168.7.2:${NODEPORT}"
}

k8s_apply_metricbeat(){ kubectl apply -f metricbeat_hosts.yaml ; }
  k8s_apply_filebeat(){ kubectl apply -f filebeat_autodiscover.yaml ; }

# #Source: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-beat-configuration-examples.html
# wget https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/filebeat_autodiscover_by_metadata.yaml
# kubectl apply -f filebeat_autodiscover_by_metadata.yaml
# #Source: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-beat-configuration-examples.html
# wget https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/stack_monitoring.yaml
# kubectl apply -f stack_monitoring.yaml
# kubectl scale -n default statefulset elasticsearch-monitoring-es-default --replicas=1

  k8s_apply_heartbeat(){ kubectl apply -f heartbeat_es_kb_health.yaml ; }
k8s_apply_journalbeat(){ kubectl apply -f journalbeat_hosts.yaml ; }
 k8s_apply_packetbeat(){ kubectl apply -f packetbeat_dns_http.yaml ; }
  k8s_apply_auditbeat(){ kubectl apply -f auditbeat_hosts.yaml ; }
  k8s_apply_apmserver(){ kubectl apply -f apm-server-default.yaml ; }

main(){
		k8s_create_storageclass_standard
		k8s_patch_storageclass_default
		k8s_create_persistentvolume_node1
		k8s_create_persistentvolume_node2
		k8s_create_persistentvolume_node3
		k8s_create_crds
		k8s_create_operators
		k8s_apply_es_default
		k8s_apply_kibana_kb
		k8s_edit_kibana_kb
		k8s_get_login_kibana
		k8s_apply_metricbeat
		k8s_apply_filebeat
		k8s_apply_heartbeat
		k8s_apply_journalbeat
		k8s_apply_packetbeat
		k8s_apply_auditbeat
		k8s_apply_apmserver
}


remove_eck_all(){
	for i in `ls -1 *.yaml`
	do 
		kubectl delete -f $i
	done
}

kill_port_fwds(){
	#/---- kill port-forwards ----/
	for p in $(ps -ef | grep kubectl | grep 'port-forward' | awk '{print $2}')
	do
		kill -9 ${p}
	done
}

# /**********************************************/
# EOF
# /**********************************************/

# watch kubectl get apmservers
# kubectl get pods --selector='apm.k8s.elastic.co/name=apm-server-default'



# /**********************************************/
# METRIC BEATS ON KUBERNETES
# /**********************************************/
#
# Source: https://www.elastic.co/guide/en/beats/metricbeat/current/running-on-kubernetes.html
# #kubectl apply -f https://raw.githubusercontent.com/elastic/cloud-on-k8s/1.7/config/recipes/beats/openshift_monitoring.yaml
#
# # Source:https://www.elastic.co/guide/en/beats/metricbeat/current/running-on-kubernetes.html
# curl -L -O https://raw.githubusercontent.com/elastic/beats/7.14/deploy/kubernetes/metricbeat-kubernetes.yaml
# kubectl apply -f metricbeat-kubernetes.yaml
# /**********************************************/
# EOF
# /**********************************************/

