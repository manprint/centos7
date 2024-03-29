FROM centos:7

ENV container docker
ENV DEBIAN_FRONTEND noninteractive

ENV DEBIAN_FRONTEND noninteractive
ENV ROOT_PWD root
ENV USER_UID 1000
ENV USER_GID 1000
ENV USER_NAME centos
ENV USER_GROUP centos
ENV USER_PWD centos
ENV USER_HOME /home/centos
ENV NOTVISIBLE "in users profile"
ENV TZ=Europe/Rome

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum update -y; \
    yum install -y sudo nano curl wget \
        openssl bash-completion bash-completion-extras \
        openssh-server cronie python3-pip net-tools epel-release; \
    yum clean all; \
    rm -rf /var/cache/yum

RUN yum update -y; \
    yum install -y htop; \
    yum clean all; \
    rm -rf /var/cache/yum

RUN pip3 install webssh

# craete group and user

RUN set -xev; \
	groupadd -g $USER_GID $USER_GROUP

RUN set -xev; \
   useradd -rm \
	-d $USER_HOME \
	-s /bin/bash \
	-p "$(openssl passwd -1 $USER_PWD)" \
	-g $USER_GROUP \
	-G root \
	-u $USER_UID \
	$USER_NAME

# set password for root

RUN echo root:"${ROOT_PWD}" | chpasswd

# enable user to execute sudo without password

RUN echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN rm -f /etc/bashrc
COPY ./bashrc /etc/bashrc
RUN chown root:root /etc/bashrc

RUN rm -f /etc/profile
COPY ./bashrc /etc/profile
RUN chown root:root /etc/profile

ENV TZ=Europe/Rome

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
     && echo $TZ > /etc/timezone

RUN localedef -i it_IT -f UTF-8 it_IT.UTF-8

ENV LANG it_IT.UTF-8
ENV LANGUAGE it_IT.UTF-8
ENV LC_ALL it_IT.UTF-8

RUN set -xev; \
    echo "export LC_ALL=it_IT.UTF-8" >> /etc/bashrc; \
    echo "export LANG=it_IT.UTF-8" >> /etc/bashrc; \
    echo "export LANGUAGE=it_IT.UTF-8" >> /etc/bashrc;

COPY ./webssh.service /etc/systemd/system/webssh.service
RUN chown root:root /etc/systemd/system/webssh.service

RUN systemctl enable sshd.service
RUN systemctl enable crond.service
RUN systemctl enable webssh.service

EXPOSE 22 8888

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
