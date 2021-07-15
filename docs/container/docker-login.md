# Docker registry logins

Many of the workloads enabled by DeepOps rely on container images distributed through registries
such as [Docker Hub](https://hub.docker.com) or [NVIDIA NGC](https://ngc.nvidia.com).

While many of these container images can be downloaded without logging in, logging in
may be required to access some images.

On Docker Hub, logging in also enables [higher rate limits](https://www.docker.com/increase-rate-limits)
for container pulls.

## Slurm jobs using private registries

The process for using private registries is different depending
on whether you are using Singularity or Enroot as your container runtime.

### Singularity

[Singularity](https://sylabs.io/singularity/) gets container pull credentials using environment variables:

```sh
export SINGULARITY_DOCKER_USERNAME=<username>
export SINGULARITY_DOCKER_PASSWORD=<password>
```

Note that because Singularity downloads the container image to a file in your local directory, you
can typically pull the container before running your Slurm job, and then make use of the downloaded file in your job.

<!-- noqa -->
The [Singularity documentation](https://sylabs.io/guides/3.7/user-guide/singularity_and_docker.html#making-use-of-private-images-from-docker-hub)
has more detail on how to use private images.

### Enroot

[Enroot](https://github.com/NVIDIA/enroot) uses credentials configured through `$ENROOT_CONFIG_PATH/.credentials` .
In most Slurm installations, `ENROOT_CONFIG_PATH` will be `$HOME/.config/enroot` .

Because Enroot pulls containers on the fly as Slurm jobs start, the credentials
file needs to be accessible in a shared filesystem which all nodes can access at job start.

The file format for the credentials file looks like this:

```sh
machine <hostname> login <username> password <password>
```

So, for example:

```sh
machine auth.docker.io login <username> password <password>
```

For more information, see the
[Enroot documentation](https://github.com/NVIDIA/enroot/blob/master/doc/cmd/import.md#description).

## System containers using private registries

DeepOps performs some container pulls as part of setting up a cluster, so many deployments
will want to enable a registry login for the root user during the setup process.

To enable this, we provide a convenience playbook
[docker-login.yml](https://github.com/NVIDIA/deepops/blob/0e667b3f2dcae12d/playbooks/container/docker-login.yml)
that you can use to log into one or more registries on each node in a cluster.

Note that we recommend registering a separate service account on the container registries for system setup, rather
than relying on the individual account of an individual person.

First, create an Ansible vars file to store your registry login information.
You can put this directly in your DeepOps [config directory](../config), but
for security, we recommend creating a separate
[Ansible Vault](https://docs.ansible.com/ansible/2.9/user_guide/vault.html) file.

```sh
ansible-vault create config/docker-login.yml
#=> New Vault password:
#=> Confirm New Vault password:
```

This will open your editor of choice, where you can enter
the login information in a `docker_login_registries` variable.

An example appears below, or in the
<!-- noqa -->
[defaults for the docker_login role](https://github.com/NVIDIA/deepops/blob/0e667b3f2dcae12d/roles/docker-login/defaults/main.yml):

```yaml
docker_login_registries:
  - registry: nvcr.io
    username: '$oauthtoken'
    password: '<api-token>'

  - registry: docker.io
    username: 'my-docker-username'
    password: 'my-docker-password'
```

Once you have created the Vault file, you can run the `docker-login.yml` playbook, entering
the password during the playbook run:

```sh
ansible-playbook -e @config/docker-login.yml --ask-vault-pass playbooks/container/docker-login.yml
#=> Vault password:
#=> PLAY [all] **************************************************
```

Once the playbook runs, subsequent docker pulls from the registries you specify will use
the credentials you used to log in.
This will enable the root user to pull containers which may require logging in, e.g.

```sh
docker pull nvcr.io/nvidia/hpc-benchmarks:20.10-hpl
#=> 20.10-hpl: Pulling from nvidia/hpc-benchmarks
#=> f52357ed8777: Pull complete
```

Note that only the root user will use these credentials.
Other users of the cluster should provide their own docker logins to use private containers.
