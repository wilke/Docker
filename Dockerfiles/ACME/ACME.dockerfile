FROM centos:7
MAINTAINER Andreas Wilke <wilke@mcs.anl.gov>
#LABEL maintainer "Andreas Wilke <wilke@mcs.anl.gov>"
RUN yum -y update && yum -y upgrade && yum -y install \
  cmake \
  gcc \
  gcc-c++ \
  gcc-fortran \
  gcc-gfortran \
  git \
  kernel-devel \
  less \
  m4 \
  make \
  wget \
  which \
  zlib-devel
WORKDIR /Downloads
# MPICH
RUN wget http://www.mpich.org/static/downloads/3.1.4/mpich-3.1.4.tar.gz && \
    tar -xvf mpich-3.1.4.tar.gz && \
    mkdir /mpich3
ENV LD_LIBRARY_PATH /mpich3/lib/
# OPENMPI
RUN wget https://www.open-mpi.org/software/ompi/v2.0/downloads/openmpi-2.0.2.tar.gz && \
    tar -xvf openmpi-2.0.2.tar.gz && \
    mkdir /openmpi2
# netCDF    
RUN wget https://support.hdfgroup.org/ftp/HDF5/current18/src/hdf5-1.8.18.tar && \
    tar -xvf hdf5-1.8.18.tar && \
    mkdir /hdf5 
RUN wget https://support.hdfgroup.org/ftp/HDF5/current18/src/CMake-hdf5-1.8.18.tar.gz
# netCDF
RUN wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.4.1.1.tar.gz &&\
    tar -xvf netcdf-4.4.1.1.tar.gz && \
    mkdir /netcdf4
# PnetCDF
RUN wget http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.8.1.tar.gz && \
    tar -xvf parallel-netcdf-1.8.1.tar.gz && \
    mkdir /parallel-netcdf 
# pFUnit
RUN git clone git://git.code.sf.net/p/pfunit/code pFUnit
# CMAKE
RUN wget https://cmake.org/files/v3.7/cmake-3.7.1.tar.gz && \
 tar -xvf cmake-3.7.1.tar.gz
# Build newer cmake 
RUN cd cmake-3.7.1 && \
 cmake . && \
 make && \
 make install
# Build mpich 
WORKDIR /Downloads/mpich-3.1.4
RUN ./configure --prefix=/mpich3 && make && make install
ENV PATH /Downloads/cmake-3.7.1.bin:$PATH:/mpich3/bin
# Build openmpi
WORKDIR /Downloads/openmpi-2.0.2
RUN ./configure --prefix=/openmpi2
RUN make all install

# Build pFUnit
WORKDIR /Downloads
# RUN git clone git://git.code.sf.net/p/pfunit/code pFUnit
ENV F90_VENDOR=GNU F90=gfortran MPIF90=mpif90 PFUNIT=/pfUnit
RUN mkdir pFUnit/build /pfUnit && \
  cd pFUnit/build &&\
  cmake -DMPI=YES -DOPENMP=NO -DINSTALL_PATH=/pfUnit -DCMAKE_INSTALL_PREFIX=/pfUnit ../ &&\
  make tests
RUN cd pFUnit/build && make install INSTALL_DIR=/pfUnit
ENV PATH /pfUnit/bin:$PATH 

# Build hdf5
WORKDIR /Downloads
#RUN wget https://support.hdfgroup.org/ftp/HDF5/current18/src/hdf5-1.8.18.tar && tar -xvf hdf5-1.8.18.tar && mkdir /hdf5 
#RUN wget https://support.hdfgroup.org/ftp/HDF5/current18/src/CMake-hdf5-1.8.18.tar.gz
WORKDIR /Downloads/hdf5-1.8.18
RUN ./configure --prefix=/hdf5 --enable-fortran && \
  make && make check && \
  make install && make check-install

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/hdf5/lib 
ENV PATH $PATH:/hdf5/bin

# Build netcdf
WORKDIR /Downloads/netcdf-4.4.1.1
RUN yum -y install m4 zlib-devel
RUN CPPFLAGS=-I/hdf5/include LDFLAGS=-L/hdf5/lib ./configure --prefix=/netcdf4
RUN make all check
RUN make install


# ACME
WORKDIR /ACME
RUN mkdir scratch
# ACME directory has to be in build context
COPY . .
RUN mkdir -p cime/utils/git
WORKDIR /ACME/cime/utils/git
RUN wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
RUN wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
WORKDIR /ACME
# # RUN git clone git@github.com:ACME-Climate/ACME.git

