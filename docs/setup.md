# Setup
## Prerequistes
The goal is to have configured: docker, kind, kubectl, and helm.
* Be able to run `docker ps -a` (a.k.a be in the docker group)
* Download binaries.
```
cd ~/bin
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum --check
rm kubectl.sha256

curl -Lo ./helm-v3.5.3-linux-amd64.tar.gz https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz
tar zxvf helm-v3.5.3-linux-amd64.tar.gz --strip-components 1 "linux-amd64/helm"
rm helm-v3.5.3-linux-amd64.tar.gz

chmod a+x ~/bin/kind
chmod a+x ~/bin/kubectl
chmod a+x ~/bin/helm
```

## Create the cluster
* [Create the cluster with local repository](https://kind.sigs.k8s.io/docs/user/local-registry/)
> ! Follow the guide in the _Using the Registry_ section
```bash
bin/create-cluster.sh
```

## Add helm repositories
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```