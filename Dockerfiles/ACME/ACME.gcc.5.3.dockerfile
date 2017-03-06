FROM centos:7
MAINTAINER Andreas Wilke <wilke@mcs.anl.gov>
LABEL maintainer "Andreas Wilke <wilke@mcs.anl.gov>"
RUN yum -y update && yum -y upgrade &&  yum -y install \
  bzip2 \
  cmake \
  gcc \
  gcc-c++ \
  gcc-fortran \
  gcc-gfortran \
  git \
  kernel-devel \
  less \
  libmpc-devel.x86_64 \
  m4 \
  make \
  mpfr-devel.x86 \
  wget \
  which \
  zlib-devel

# Build and download directory, clean up  
WORKDIR /Downloads

# Build GCC 5.3
# get from:
# wget http://mirrors.concertpass.com/gcc/releases/gcc-5.3.0/gcc-5.3.0.tar.gz
# wget http://mirrors-usa.go-parts.com/gcc/releases/gcc-5.3.0/gcc-5.3.0.tar.gz
RUN wget http://mirrors.concertpass.com/gcc/releases/gcc-5.3.0/gcc-5.3.0.tar.gz && \
  tar -xf gcc-5.3.0.tar.gz && \
  mkdir -p /gcc && \
  mkdir tmp && \
  cd tmp && \
  /Downloads/gcc-5.3.0/configure \
  --prefix /gcc \
  --enable-languages=c,fortran \
  --disable-multilib && \
  make && \
  make install && \
  cd /Downloads && \
  rm -rf *
ENV PATH /gcc:/gcc/bin:$PATH

# CMAKE 3.7.1
WORKDIR /
RUN wget https://cmake.org/files/v3.7/cmake-3.7.1.tar.gz && \
 tar -xvf cmake-3.7.1.tar.gz && \
 cd cmake-3.7.1 && \
 cmake . && \
 make && \
 make install && \
 cd / && \
 rm cmake-3.7.1.tar.gz
ENV PATH /cmake-3.7.1.bin:$PATH

# MPICH 3.1.4
WORKDIR /Downloads
RUN wget http://www.mpich.org/static/downloads/3.1.4/mpich-3.1.4.tar.gz && \
    tar -xvf mpich-3.1.4.tar.gz && \
    mkdir /mpich3 && \
    cd mpich-3.1.4 && \
    ./configure --prefix=/mpich3 && \
    make && \
    make install && \
    cd /Downloads && rm -rf *
ENV PATH $PATH:/mpich3/bin        
ENV LD_LIBRARY_PATH /mpich3/lib/

# OPENMPI 2.0.2
RUN wget https://www.open-mpi.org/software/ompi/v2.0/downloads/openmpi-2.0.2.tar.gz && \
    tar -xvf openmpi-2.0.2.tar.gz && \
    mkdir /openmpi2 && \
    cd openmpi-2.0.2 && \
    ./configure --prefix=/openmpi2 && \
    make all install && \
    cd /Downloads && rm -rf *  

# HDF5 1.8.18    
RUN wget https://support.hdfgroup.org/ftp/HDF5/current18/src/hdf5-1.8.18.tar && \
    tar -xvf hdf5-1.8.18.tar && \
    mkdir /hdf5 && \
    cd /Downloads/hdf5-1.8.18 && \
    ./configure --prefix=/hdf5 --enable-fortran && \
    make && make check && \
    make install && make check-install && \
    cd /Downloads && rm -rf * 
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/hdf5/lib
ENV PATH $PATH:/hdf5/bin

# netCDF 4.4.1.1
RUN wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.4.1.1.tar.gz && \
    tar -xvf netcdf-4.4.1.1.tar.gz && \
    mkdir /netcdf4 && \
    cd /Downloads/netcdf-4.4.1.1 && \
    CPPFLAGS=-I/hdf5/include LDFLAGS=-L/hdf5/lib ./configure --prefix=/netcdf4 && \
    make all check && \
    make install && \
    cd /Downloads && rm -rf *
    
# PnetCDF 1.8.1
# RUN wget http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.8.1.tar.gz && \
#     tar -xvf parallel-netcdf-1.8.1.tar.gz && \
#     mkdir /parallel-netcdf

# pFUnit git:master
ENV F90_VENDOR=GNU F90=gfortran MPIF90=mpif90 PFUNIT=/pfUnit
RUN git clone git://git.code.sf.net/p/pfunit/code pFUnit && \
  mkdir -p pFUnit/build /pfUnit && \
  cd pFUnit/build && \
  cmake -DMPI=YES -DOPENMP=NO -DINSTALL_PATH=/pfUnit -DCMAKE_INSTALL_PREFIX=/pfUnit ../ && \
  make tests && \
  make install INSTALL_DIR=/pfUnit && \
  cd /Downloads && rm -rf *
ENV PATH /pfUnit/bin:$PATH

# ACME
WORKDIR /ACME
RUN mkdir scratch && \
  mkdir -p cime/utils/git && \
  wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh && \
  wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
