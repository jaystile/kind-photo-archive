#!/bin/sh
set -o errexit

reg_name='kind-registry'
reg_port='5000'


check_prerequiste() {
    tool=$1
    if ! which "${tool}" ; then
        echo "Could not find prerequiste application ${tool}. It will need to be installed"
        return 1
    fi
    return 0
}


# create registry container unless it already exists
create_local_docker_registry() {
    running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
    if [ "${running}" != 'true' ]; then
    docker run \
        -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
        registry:2
    fi
}

# create a cluster with the local registry enabled in containerd
create_kind_cluster() {
    cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_name}:${reg_port}"]
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
#   ## Custom CA certificates
#   extraMounts:
#   - hostPath: /etc/pki/ca-trust/source/anchors/SELF_SIGNED_CERT.pem
#     containerPath: /usr/local/share/ca-certificates/SELF_SIGNED_CERT.crt.pem
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
}


connect_registry_to_cluster() {
    # connect the local docker registry to the cluster network
    # (the network may already be connected)
    docker network connect "kind" "${reg_name}" || true
}



update_ca_certificates() {
    # If you added customer CA certificates, you'll need to reload.
    # Restart (https://github.com/kubernetes-sigs/kind/issues/1010)
    echo "docker exec -it kind-control-plane update-ca-certificates"
    docker exec -it kind-control-plane update-ca-certificates
    echo "docker exec -it kind-control-plane systemctl restart containerd"
    docker exec -it kind-control-plane systemctl restart containerd
}

add_to_cluster_registry_configmap() {
    # https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
}

add_to_cluster_nginx_ingress_controller() {
    # Add in the NGINX Ingress Controller
    cat <<EOF | kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml 
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
EOF
}

check_prerequiste docker
check_prerequiste kind
check_prerequiste kubectl
create_local_docker_registry
create_kind_cluster
connect_registry_to_cluster
add_to_cluster_registry_configmap
add_to_cluster_nginx_ingress_controller