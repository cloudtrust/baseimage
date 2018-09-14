# docker-baseimage
Repository for cloudtrust base image

Where `$GIT_TAG` is the tag for the current release
```Bash
# Prepare the environment
git clone git@github.com:cloudtrust/baseimage.git
cd baseimage

# Build image
docker build -t cloudtrust-baseimage:$GIT_TAG --build-arg baseimage_git_tag=$GIT_TAG -f cloudtrust-baseimage.dockerfile -t cloudtrust-baseimage:latest .

## test
docker create --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name test cloudtrust-baseimage
docker start test
docker exec -ti test /bin/bash
systemctl status
```

Versionning components has been performed in the following way:
1. Enter a container in the version used by cloudtrust.
2. Clean the repo cache.
3. Search for the existing versions of a package.
4. Use the latest versions in the dockerfile.

       docker run -it fedora:27 /bin/bash
       dnf clean all
       dnf list --showduplicates systemd

