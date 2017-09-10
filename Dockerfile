ARG OS_VER=7.2.1511 
ARG DPDK_VER=17.08
FROM centos:${OS_VER}
MAINTAINER Amir Zeidner

WORKDIR /

# Install prerequisite packages
RUN yum update -y &&  yum install -y \
libnl \
numactl-devel \
numactl \
unzip \
wget \
make \
gcc \
ethtool \
net-tools \
kernel-headers.x86_64 

# Download and install Mellanox drivers
ARG OS_VER
RUN wget http://www.mellanox.com/downloads/ofed/MLNX_EN-4.1-1.0.2.0/mlnx-en-4.1-1.0.2.0-rhel${OS_VER:0:3}-x86_64.tgz && tar -xvzf /mlnx-en-4.1-1.0.2.0-rhel${OS_VER:0:3}-x86_64.tgz
RUN rpm -ivh $( ls /mlnx-en-4.1-1.0.2.0-rhel${OS_VER:0:3}-x86_64/RPMS/libibverbs* | grep -v dbg )
RUN rpm -ivh $( ls /mlnx-en-4.1-1.0.2.0-rhel${OS_VER:0:3}-x86_64/RPMS/libmlx* | grep -v dbg )

# Download and compile DPDK
ARG DPDK_VER
RUN cd /usr/src/ &&  wget http://dpdk.org/browse/dpdk/snapshot/dpdk-${DPDK_VER}.zip && unzip dpdk-${DPDK_VER}.zip 
ENV DPDK_DIR=/usr/src/dpdk-${DPDK_VER}  DPDK_TARGET=x86_64-native-linuxapp-gcc DPDK_BUILD=$DPDK_DIR/$DPDK_TARGET
RUN cd $DPDK_DIR && sed -i 's/\(CONFIG_RTE_LIBRTE_MLX5_PMD=\)n/\1y/g' $DPDK_DIR/config/common_base
RUN cd $DPDK_DIR && make install T=$DPDK_TARGET DESTDIR=install

# Remove unnecessary packages and files
RUN rm -rf /tmp/* && rm -rf /mlnx-en-4.1-1.0.2.0-rhel${OS_VER:0:3}-x86_64/ && rm /mlnx-en-4.1-1.0.2.0-rhel${OS_VER:0:3}-x86_64.tgz && rm /usr/src/dpdk-${DPDK_VER}.zip
