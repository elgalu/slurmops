# Role Name: roce_backend

The Role is added to K8s cluster availability to use in POD deployment RoCE enabled
additional NIC's which based on SR-IOV Virtual function.

For full Reference Deployment Guide please look - <https://docs.mellanox.com/pages/releaseview.action?pageId=15049828>

RDMA over Converged Ethernet (RoCE) is a standard protocol which enables RDMA's efficient data transfer
over Ethernet networks allowing transport offload with hardware RDMA engine implementation, and superior performance.

RoCE is a standard protocol defined in the InfiniBand Trade Association (IBTA) standard.

## Requirements

1. SR-IOV supported server platform
2. Enable SR-IOV in the NIC firmware (For Mellanox adapters please refer to
<!-- noqa -->
<https://community.mellanox.com/s/article/howto-configure-sr-iov-for-connectx-4-connectx-5-with-kvm--ethernet-x#jive_content_id_I_Enable_SRIOV_on_the_Firmware)>
3. Kubernetes cluster is deployed by DeepOps deployment tools

If you need this, fetch the latest role at <https://github.com/NVIDIA/deepops/tree/0e667b3f2dcae12d1/roles/roce_backend>
