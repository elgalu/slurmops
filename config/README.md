# DeepOps configuration

This directory provides configuration for a NVIDIA/DeepOps setup.
The files in this directory will help determine the behavior of the Ansible playbooks
and other scripts that DeepOps uses to set up your systems.

For more details on how this works, see
[how to configure DeepOps](https://github.com/NVIDIA/deepops/blob/acd2e6a7d466a5e/docs/deepops/configuration.md).

## Files not included

### PXE

Configuration files in `config.example/pxe` can be included once we need to booting/installing OS from the network.

### K8s (Kubernetes)

DCGM csv config file `config.example/files/k8s-cluster/dcgm-custom-metrics.csv` (not yet used).

K8s Cluster (not yet used) `config.example/group_vars/k8s-cluster.yml` .

Dask config file `config.example/helm/rapids-dask.yml` (not yet used).

If one needs DGX Server Provisioning over PXE then use DGXie `config.example/helm/dgxie.yml` .

NetApp/Trident deploys in K8s clusters as pods to provide dynamic storage
for K8s workloads `config.example/group_vars/netapp-trident.yml` .

ELK (the Elastic Stack) can be useful to centrally hold logs and dashboards, see
`config.example/helm/elk.yml` and `config.example/helm/filebeat.yml` .

[MetalLb](https://github.com/metallb/metallb) is a software-based L2 Load Balancer `config.example/helm/metallb.yml` .

For Prometheus + Grafana monitoring see `config/helm/monitoring.yml` or `config/helm/monitoring-no-persist.yml` .

### Airgap for offline setups

When working on a very tightly secured environment, internet access can pose a major
risk, check <https://github.com/NVIDIA/deepops/pull/1012> for more details.
