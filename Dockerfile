ARG OS_VER=18.04
ARG DPDK_VER=19.05
FROM ubuntu:${OS_VER}
MAINTAINER Amir Zeidner

WORKDIR /

# Install prerequisite packages
RUN apt-get update && apt-get install -y \
libibverbs-dev \
libmnl-dev \
libnuma-dev \
numactl \
libnuma1 \
unzip \
wget \
make \
gcc \
ethtool \
net-tools \
linux-headers-$(uname -r) \
&& rm -rf /var/lib/apt/lists/* 

# Download and compile DPDK
ARG DPDK_VER
RUN cd /usr/src/ &&  wget http://git.dpdk.org/dpdk/snapshot/dpdk-${DPDK_VER}.zip && unzip dpdk-${DPDK_VER}.zip 
ENV DPDK_DIR=/usr/src/dpdk-${DPDK_VER}  DPDK_TARGET=x86_64-native-linuxapp-gcc DPDK_BUILD=$DPDK_DIR/$DPDK_TARGET
RUN cd $DPDK_DIR && sed -i 's/\(CONFIG_RTE_LIBRTE_MLX5_PMD=\)n/\1y/g' $DPDK_DIR/config/common_base
RUN cd $DPDK_DIR && make install T=$DPDK_TARGET DESTDIR=install

# Remove unnecessary packages and files
RUN apt-get -y remove gcc unzip wget make
RUN apt-get -y autoremove
RUN apt-get -y clean

