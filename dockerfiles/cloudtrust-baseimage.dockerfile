FROM fedora:27

ARG ssh_key_name
ARG baseimage_git_tag

#Systemd
ENV container=docker
RUN dnf -y update && \
    dnf -y install git net-tools procps iputils bind-utils nmap tcpdump vim systemd monit && \
    dnf clean all && \
	(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done) && \
	rm -f /lib/systemd/system/multi-user.target.wants/* && \
	rm -f /etc/systemd/system/*.wants/* && \
	rm -f /lib/systemd/system/local-fs.target.wants/* && \
	rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
	rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
	rm -f /lib/systemd/system/basic.target.wants/* && \
	rm -f /lib/systemd/system/anaconda.target.wants/*
VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3

#At jdr's request, my bash shortcuts
RUN printf '%s\n%s\n%s\n%s\n' \
'"\e[A":history-search-backward' \
'"\e[B":history-search-forward' \
'"\e[1;5D":backward-word' \
'"\e[1;5C":forward-word' >> /root/.inputrc

WORKDIR /cloudtrust
ADD keys/${ssh_key_name} keys/${ssh_key_name}.pub /cloudtrust/
RUN	mkdir /root/.ssh && \
	mv ${ssh_key_name} ${ssh_key_name}.pub /root/.ssh/ && \
	chmod 600 /root/.ssh/* && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
  	echo "IdentityFile /root/.ssh/${ssh_key_name}" >> /etc/ssh/ssh_config

RUN git clone git@github.com:cloudtrust/baseimage.git && \
    cd baseimage && \
    git checkout ${baseimage_git_tag} && \
	install -v -o root -g root -m 644 deploy/common/etc/systemd/system/monit.service /etc/systemd/system/monit.service && \
	systemctl enable monit

CMD ["/sbin/init"]
