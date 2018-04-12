FROM fedora:27

ARG ssh_key_name
ARG baseimage_git_tag
ARG known_hosts_file

# Systemd
ENV container=docker
RUN dnf -y update && \
    dnf -y install git net-tools procps iputils bind-utils nmap tcpdump vim systemd monit wget && \
    dnf clean all 

# Remove all the regular systemd razzle-dazzle
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done) && \
	rm -f /lib/systemd/system/multi-user.target.wants/* && \
	rm -f /etc/systemd/system/*.wants/* && \
	rm -f /lib/systemd/system/local-fs.target.wants/* && \
	rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
	rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
	rm -f /lib/systemd/system/basic.target.wants/* && \
	rm -f /lib/systemd/system/anaconda.target.wants/*

VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3

# At jdr's request, my bash shortcuts
RUN printf '%s\n%s\n%s\n%s\n' \
'"\e[A":history-search-backward' \
'"\e[B":history-search-forward' \
'"\e[1;5D":backward-word' \
'"\e[1;5C":forward-word' >> /root/.inputrc


# Prepare ssh information for git pulls
# The known_hosts file is added to allow for private repositories
RUN mkdir -p /root/.ssh
ADD keys/${ssh_key_name} keys/${ssh_key_name}.pub /root/.ssh/
ADD keys/${known_hosts_file} /root/.ssh/known_hosts

RUN	chmod 600 /root/.ssh/* && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
  	echo "IdentityFile /root/.ssh/${ssh_key_name}" >> /etc/ssh/ssh_config

# Prepare baseimage
WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/baseimage.git
WORKDIR /cloudtrust/baseimage
RUN git checkout ${baseimage_git_tag} && \
	install -v -o root -g root -m 644 deploy/etc/systemd/system/monit.service /etc/systemd/system/monit.service

RUN systemctl enable monit

CMD ["/sbin/init"]
