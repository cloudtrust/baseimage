FROM centos:7


# Update, Supervisord & basic tools
RUN yum -y update && \
    yum -y install git net-tools procps iputils bind-utils nmap tcpdump vim wget python-setuptools && \
    yum clean all 

RUN easy_install supervisor

# bash shortcuts
RUN printf '%s\n%s\n%s\n%s\n' \
'"\e[A":history-search-backward' \
'"\e[B":history-search-forward' \
'"\e[1;5D":backward-word' \
'"\e[1;5C":forward-word' >> /root/.inputrc

# Supervisord configuration
RUN echo_supervisord_conf > /etc/supervisord.conf

RUN sed -i 's/nodaemon=false/nodaemon=true/g' /etc/supervisord.conf

RUN printf '%s\n%s\n\n%s\n%s\n' \
'[program:foo]' \
'command=/bin/cat' \
'[program:bar]' \
'command=/bin/cat' >> /etc/supervisord.conf

RUN chown 777 /etc/supervisord.conf

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
