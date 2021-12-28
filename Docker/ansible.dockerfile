FROM alpine
LABEL maintainer="losenet virus14@gmail.com"
#ENV container=docker
#ENV TERM=xterm
ARG aname="routeros-host1 routeros-host2"
ARG ahost="192.168.88.1 192.168.88.2"
RUN apk add bash nano openssh ansible && mkdir -p /etc/ansible/playbooks && mkdir -p /root/.ssh \
        && echo -e '[defaults]\ninventory = /etc/ansible/hosts.yaml\nhost_key_checking = false' > /etc/ansible/ansible.cfg \
        && echo -e '#!/bin/bash' > /etc/ansible/conf.sh \
        && echo -e "aname=(${aname})" >> /etc/ansible/conf.sh \
        && echo -e "ahost=(${ahost})" >> /etc/ansible/conf.sh \
        && echo -e 'echo -e "gw:\n  host:" > /etc/ansible/hosts.yaml' >> /etc/ansible/conf.sh \
        && echo -e 'for iname in ${!aname[@]}; do vname=${aname[iname]} \' >> /etc/ansible/conf.sh \
        && echo -e '&& echo -e "    $vname:' >> /etc/ansible/conf.sh \
        && echo -e '      ansible_connection: network_cli' >> /etc/ansible/conf.sh \
        && echo -e '      ansible_network_os: routeros' >> /etc/ansible/conf.sh \
        && echo -e '      ansible_host: ${ahost[$iname]}' >> /etc/ansible/conf.sh \
        && echo -e '      ansible_user: ansible-user' >> /etc/ansible/conf.sh \
        && echo -e '      ansible_private_key_file: /root/.ssh/$vname" >> /etc/ansible/hosts.yaml; done' >> /etc/ansible/conf.sh \
        && echo -e 'cat /etc/ansible/hosts.yaml' >> /etc/ansible/conf.sh \
        && echo -e 'for i in ${aname[@]}; do ssh-keygen -t rsa -m pem -f "/root/.ssh/$i" -q -N ""; done' >> /etc/ansible/conf.sh
CMD ["/sbin/init"]
