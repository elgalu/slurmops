# SlurmOps

[![Python](docs/img/badges/language.svg)](https://devdocs.io/python/)

NVIDIA/DeepOps on AWS EC2.

## Usage

```sh
# Bootstrap this repo (download dependencies, etc.)
curl -sL https://raw.github.com/elgalu/ensure/main/setup.sh | bash
source .venv/bin/activate

invoke ansible-checks

# Start the Slurm virtual test cluster
VAGRANT_VAGRANTFILE=Vagrantfile-single
vagrant up

# Test connectivity
ansible all -v -m raw -a "hostname" --inventory "./config/inventory-vagrant-single"
#=> stdout ... slurm-single

# Bootstrap/Install the Slurm Cluster
#
# Limit to a subset of nodes (--limit or -l) or group of nodes
# Use: `--limit "aws"` so it grabs `config/group_vars/aws.yml`
# Use: `--limit "vagrant"` so it grabs `config/group_vars/vagrant.yml`
invoke ansible-clear-facts
ansible-playbook -vv \
    --inventory "./config/inventory-vagrant-single" \
    --limit "vagrant" \
    "./playbooks/slurm-cluster.yml"

# Verify Pyxis and Enroot can run GPU jobs across all nodes.
# --forks specify number of parallel processes to use, see ansible.cfg for the default.
ansible-playbook -vv \
    --inventory "./config/inventory-vagrant-single" \
    --limit "vagrant" \
    --forks "1" \
    -e '{num_gpus: 1}' \
    "./playbooks/slurm-cluster/slurm-validation.yml"

# Un-drain nodes
# TODO: is this doing something else besides undrain?
# --tags only run plays and tasks tagged with these values
ansible-playbook -vv \
    --inventory "./config/inventory-vagrant-single" \
    --limit "vagrant" \
    --tags "undrain" \
    "./playbooks/slurm-cluster/slurm.yml"
```

### How to debug

Apply changes only to host `slurm-head01` and only a specific file.
You can also further filter with `--start-at-task "debug1"` .

```sh
ansible-playbook -vv \
    --inventory "./config/inventory-vagrant-single" \
    --limit "slurm-head01" \
    --forks "1" \
    "./playbooks/nvidia-software/nvidia-driver.yml"
```

### GPU Smoke Test

Newer version like `nvcr.io/nvidia/tensorflow:21.06-tf2-py3` don't have `--layers` and
the file is located at `/workspace/nvidia-examples/cnn/resnet.py`

```sh
VAGRANT_VAGRANTFILE=Vagrantfile-single
vagrant ssh a100-8-100
# docker gpu test
sudo docker run \
  --gpus=all \
  --rm \
  --tty \
  "nvcr.io/nvidia/tensorflow:18.07-py3" \
      mpiexec --allow-run-as-root --bind-to socket -np 1 \
          python "/opt/tensorflow/nvidia-examples/cnn/resnet.py" \
            --layers=18 \
            --precision=fp16 \
            --batch_size=32
# enroot import will not work from dockerd at the moment:
enroot import "dockerd://nvcr.io/nvidia/tensorflow:18.07-py3"
#=> Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
# srun enroot gpu test
srun -p a100 -c1 -N1 -G1 --container-image="nvcr.io/nvidia/tensorflow:18.07-py3" \
  mpiexec --allow-run-as-root --bind-to socket -np 1 \
    python "/opt/tensorflow/nvidia-examples/cnn/resnet.py" \
      --layers=18 \
      --precision=fp16 \
      --batch_size=32
# srun enroot experiment on a basic cuda image
# https://developer.download.nvidia.com/compute/cuda/opensource/image/11.2.2/
srun -p a100 -c1 -N1 -G1 --container-image="nvcr.io#nvidia/cuda:11.2.2-base-ubuntu20.04" --pty /bin/bash
srun -p a100 -c1 -N1 -G1 --container-image="nvcr.io#nvidia/cuda:11.2.2-base-ubuntu20.04" nvidia-smi -L
```

### Show all variables

```sh
ansible-playbook --inventory "./config/inventory-vagrant-single" "./playbooks/debug.yml"
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

### TODO

* Check *.pin files, e.g. `nvidia-cuda/files/cuda-ubuntu.pin`

* Test vagrant on Github Actions
<https://github.com/jonashackt/vagrant-github-actions>
<https://stackoverflow.com/questions/66261101/using-vagrant-on-github-actions-ideally-incl-virtualbox>
<https://stackoverflow.com/a/60380518/511069>

* Integrate code quality tools like <https://lgtm.com/>
