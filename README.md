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
