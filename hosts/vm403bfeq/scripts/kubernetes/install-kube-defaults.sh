#!/bin/sh
# Set the timeout in seconds (e.g., 180 seconds for 3 minutes)
TIMEOUT=180

prerequisite() {
    if ! command -v kubectl &> /dev/null
    then
        echo "kubectl could not be found"
        exit 1
    fi

    if ! command -v helm &> /dev/null
    then
        echo "helm could not be found"
        exit 1
    fi

    echo "Both kubectl and helm are installed"

}

# perpare() {
#   mkdir -p $HOME/.config/k0s/etc
#   mkdir -p $HOME/.config/k0s/volumes 
#   mkdir -p $HOME/.config/k0s/registry 
# }

# deploy_k0s() {
#     echo "Deploying k0s cluster to podman"
#     echo
#     podman run -d --name k0s --hostname k0s --privileged \
#     	--cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
#     	-v /var/lib/k0s \
#     	-v $HOME/.config/k0s/etc/config.yaml:/etc/k0s/config.yaml:rw \
#     	-v $HOME/.config/k0s/volumes:/var/openebs/local:z \
#     	-p 6443:6443  \
#     	docker.io/k0sproject/k0s:v1.29.2-k0s.0 k0s controller --enable-worker --no-taints --enable-dynamic-config
#     sleep 5 
# }
#
#deploy_registry() {
#    echo "Deploying local container registry to podman"
#    echo
#    podman run --privileged -d --name registry --hostname registry \
#    -p 5000:5000 \
#    -v $HOME/.config/k0s/registry:/var/lib/registry \
#    --restart=always registry:2
#    sleep 5 
#}

#Add kube config for local cluster
#create_kube_config() {
#    echo
#    echo "Updating kube config"	
#    kube_config_file="$HOME/.kube/local-k0s"
#    new_value="https://localhost:6443"
#    sed_query="s/^(\\s*    server\\s*:\\s*).*/\\1 https:\/\/localhost:6443/"
#    kubeconfig admin | sed -r "$sed_query" | sed -r "s/Default/Local-cluster/g" > $kube_config_file
#    chmod 600 $kube_config_file 
#    echo "------"
#    return
#}

# Check if nodes are ready
check_nodes_ready() {
    local start_time=$(date +%s)
    echo
    echo "Waiting for Node to be Ready"
    while true; do
	echo    
	    echo "Pod status"    
	    kubectl get pods -A
        echo "-------"
	    echo
        echo "Node status"	
        nodes_status=$(kubectl get nodes -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}')
        if [[ "$nodes_status" == *"True"* ]]; then
            echo "Nodes are ready!"
            create_kube_config
	        break
        fi
	    echo "-------"

        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: Nodes are not ready after $TIMEOUT seconds."
            echo " To monitor the pods and node status use the following commands"
	    echo "kubectl get nodes" 
            echo "kubectl get pods"
            exit 1
        fi
        echo "Waiting 10 seconds"
        sleep 10 
    done
}

add_helm_repos() {
   echo 	
   echo "Add Helm repositories"	 
   helm repo add metallb https://metallb.github.io/metallb
   helm repo add https://kubernetes.github.io/ingress-nginx 
   helm repo add openebs https://openebs.github.io/openebs
   #helm repo add openebs-internal https://openebs.github.io/charts
   helm repo add jetstack https://charts.jetstack.io
   helm repo add portainer https://portainer.github.io/k8s
   helm repo add traefik https://traefik.github.io/charts
   helm repo add longhorn https://charts.longhorn.io
   helm repo update
   echo "-------"
}


install_metallb() {
   echo 	
   echo "Extention - Installing Metallb load balancer"	 
   helm -n metallb-system install metallb metallb/metallb --create-namespace

   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(kubectl get pods -n "metallb-system" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            echo "Applying pool" 
	        kubectl apply -f $PWD/charts/metallb-pool.yaml
	        echo "-------"
            return
        fi
        
	    current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: Metallb Pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}

install_traefik_ingress() {
   echo 	
   echo "Extention - Installing Traefik proxy"	 
   helm upgrade -i --create-namespace -n ingress-traefik traefik traefik/traefik --wait

   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(kubectl get pods -n "ingress-traefik" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                break
            fi
        done <<< "$pod_statuses"
        
	    current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: Traefik Pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}

install_nginx_ingress() {
   echo 	
   echo "Extention - Installing NGINX Ingress controller"	 
   helm  upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace \
   --set controller.hostNetwork=true \
   --set rbac.create=true \
   --set controller.service.type=ClusterIP \
   --set controller.kind=DaemonSet

   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(kubectl get pods -n "ingress-nginx" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            return
        fi
        
	current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: Ingress NGINX Pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}

install_longhorn() {
   echo 	
   echo "Extention - Installing Longhorn Storage"
   helm upgrade --install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.6.2

   
   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(kubectl get pods -n "longhorn-system" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            return
        fi
        
	current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: Longhorn Pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}

install_openebs() {
   echo 	
   echo "Extention - Installing OpenEBS Storage"
   helm  install openebs openebs/openebs --namespace openebs --create-namespace --version 4.1.0 \
    --set engines.replicated.mayastor.enabled=false \
    --set engines.local.zfs.enabled=false \
    --set engines.local.lvm.enabled=false \
    --set zfs-localpv.enabled=false \
    --set lvm-localpv.enabled=false \
    --set localpv-provisioner.hostpathClass.basePath="/data/openebs/local" \
    --set localpv-provisioner.hostpathClass.isDefaultClass="true" 
#   helm  install openebs openebs-internal/openebs --namespace openebs --create-namespace --version 3.9.0 \
#    --set localprovisioner.hostpathClass.enabled="true" \
#    --set localprovisioner.hostpathClass.isDefaultClass="true" \
#    --set ndm.enabled="false"

   
   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(kubectl get pods -n "openebs" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            echo "Applying PVC" 
	    kubectl apply -f $PWD/charts/local-hostpath-pvc.yaml
            return
        fi
        
	current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: OpenEBS Pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}

install_trust_manager() {
   echo 	
   echo "Extention - Installing trust-manager"	 
   helm upgrade -i -n cert-manager trust-manager jetstack/trust-manager --wait

   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(kubectl get pods -n "cert-manager" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            return
        fi
        
	current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: trust-manager pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}

install_cert_manager() {
   echo 	
   echo "Extention - Installing cert-manager"	 
   helm upgrade --install --create-namespace -n cert-manager cert-manager jetstack/cert-manager --set installCRDs=true --set webhook.networkPolicy.enabled=true --set webhook.securePort=10260 --wait  

   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(kubectl get pods -n "cert-manager" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            install_trust_manager
            echo "Applying issuers" 
	        kubectl apply -f $PWD/charts/cert-manager-issuers.yaml
	        echo "-------"
            return
        fi
        
	current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: cert-manager pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}





install_portainer() {
   echo 	
   echo "Application - Installing Portainer"
   helm  upgrade --install --create-namespace -n portainer portainer portainer/portainer \
    --set service.type=ClusterIP \
    --set tls.force=true \
    --set ingress.enabled=true \
    --set ingress.ingressClassName=nginx \
    --set ingress.annotations."nginx\.ingress\.kubernetes\.io/backend-protocol"=HTTPS \
    --set ingress.annotations."cert-manager\.io/cluster-issuer"="letsencrypt-nginx-prod" \
    --set ingress.hosts[0].host="portainer.production.cygnus-labs.com" \
    --set ingress.hosts[0].paths[0].path="/" \
    --set ingress.tls[0].hosts[0]="portainer.production.cygnus-labs.com" \
    --set ingress.tls[0].secretName="portainer.production.cygnus-labs.com"  

   local start_time=$(date +%s)
   while true; do
        pod_statuses=$(kubectl get pods -n "openebs" --no-headers -o custom-columns=":metadata.name,:status.phase")

        all_running=true
	    while read -r pod_name pod_status; do
            if [[ "$pod_status" != "Running" ]]; then
                echo "Waiting for Pod $pod_name be in a 'Running' state."
                all_running=false
                
                break
            fi
        done <<< "$pod_statuses"

        if $all_running; then
            echo "All pods are running."
            portainer_ip=$(kubectl get svc --namespace portainer portainer --template "")
            echo "http://$portainer_ip:9000"

            return
        fi
        
	current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ $elapsed_time -ge $TIMEOUT ]]; then
            echo "Timeout: OpenEBS Pods are not running after $TIMEOUT seconds."
            exit 1
        fi
	sleep 5

   done

}
#prerequisite
#perpare
#deploy_k0s
#check_nodes_ready
#add_helm_repos
#install_openebs
#install_longhorn
#install_metallb
install_nginx_ingress
#install_traefik_ingress
#install_cert_manager
#install_portainer
