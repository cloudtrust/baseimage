# docker-baseimage
Repository for cloudtrust base image

To build this image, you will have to do some configuration changes:
- In `keys/id_ssh`, you must specify the private SSH key of a GitHub account. This key is used to clone the CloudTrust repositories from GitHub.
- In `keys/id_ssh.pub`, you must specify the corresponding public SSH key.
- In `keys/known_hosts`, you can specify the public key of a repository. This allows to clone from private repositories.

Where `$GIT_TAG` is the tag for the current release
```Bash
# Prepare the environment
git clone git@github.com:cloudtrust/baseimage.git
cd baseimage

# We run systemd in containers, which requires the following:
setsebool container_manage_cgroup on

# Build image
docker build -t cloudtrust-baseimage:manual --build-arg baseimage_git_tag=master --build-arg ssh_key_name=id_ssh --build-arg known_hosts_file=known_hosts -f dockerfiles/cloudtrust-baseimage.dockerfile .

## test
docker create --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name test cloudtrust-baseimage
docker start test
docker exec -ti test /bin/bash
systemctl status
# The expected output looks like this:
#  ● c6c1ea4389da
#      State: running
#       Jobs: 0 queued
#     Failed: 0 units
#      Since: Tue 2018-09-04 14:16:38 UTC; 12s ago
#     CGroup: /system.slice/docker-c6c1ea4389da1636dec4517f1cb288336b93c10cbece8a313d3afc591f1c990a.scope
#             ├─init.scope
#             │ └─1 /sbin/init
#             └─system.slice
#               ├─systemd-journald.service
#               │ └─18 /usr/lib/systemd/systemd-journald
#               └─monit.service
#                 └─19 /usr/bin/monit -I
```

Versionning components has been performed in the following way:
1. Enter a container in the version used by cloudtrust.
2. Clean the repo cache.
3. Search for the existing versions of a package.
4. Use the latest versions in the dockerfile.

       docker run -it fedora:27 /bin/bash
       dnf clean all
       dnf list --showduplicates systemd

