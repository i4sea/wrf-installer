#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# 
# This file is part of the wrf-installer distribution (https://github.com/i4sea/wrf-installer).
# Copyright (c) 2023 i4sea.
# 
# This program is free software: you can redistribute it and/or modify  
# it under the terms of the GNU General Public License as published by  
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <http://www.gnu.org/licenses/>.
# 
# shellcheck disable=SC2164

BASE_INSTALL_DIR=/opt/wrf;
WRF_INSTALL_DIR=$BASE_INSTALL_DIR/wrf;
WPS_INSTALL_DIR=$BASE_INSTALL_DIR/wps;
LIB_INSTALL_DIR=$BASE_INSTALL_DIR/library;

TMP_BUILD_DIR=$(mktemp -d -t wrf-XXXXXXXXXX);
TMP_DOWNLOAD_DIR=$TMP_BUILD_DIR/downloads;

export CC=gcc;
export CXX=g++;
export FC=gfortran;
export F77=gfortran;

export LD_LIBRARY_PATH=$LIB_INSTALL_DIR/lib:$LD_LIBRARY_PATH;
export CPPFLAGS=-I$LIB_INSTALL_DIR/include;
export LDFLAGS=-L$LIB_INSTALL_DIR/lib;
export PATH=$LIB_INSTALL_DIR/bin:$PATH;


enter_temporary_download_folder() {
    mkdir -p "$TMP_DOWNLOAD_DIR";
    cd "$TMP_DOWNLOAD_DIR";
}

install_base_dependencies() {
    export DEBIAN_FRONTEND=noninteractive;

    sudo apt update;
    sudo apt install -y --no-install-recommends \
        gcc gfortran g++ libtool automake autoconf build-essential \
        curl make m4 grads default-jre csh libc6-dev;
}

install_zlib() {
    enter_temporary_download_folder;

    curl -L -O "https://zlib.net/zlib-1.2.13.tar.gz";
    tar -xvzf zlib-1.2.13.tar.gz;
    cd zlib-1.2.13;

    ./configure --prefix=$LIB_INSTALL_DIR;
    make;
    make install;
}

install_hdf5() {
    enter_temporary_download_folder;

    curl -L -O "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/hdf5-1.10.5.tar.gz";
    tar -xvzf hdf5-1.10.5.tar.gz;
    cd hdf5-1.10.5;

    ./configure \
        --prefix=$LIB_INSTALL_DIR \
        --with-zlib=$LIB_INSTALL_DIR \
        --enable-hl \
        --enable-fortran;

    make check;
    make install;

    export HDF5=$LIB_INSTALL_DIR;
}

install_netcdf_c_library() {
    enter_temporary_download_folder;

    curl -L -O https://downloads.unidata.ucar.edu/netcdf-c/4.9.0/netcdf-c-4.9.0.tar.gz;
    tar -xvzf netcdf-c-4.9.0.tar.gz;
    cd netcdf-c-4.9.0;

    ./configure \
        --prefix=$LIB_INSTALL_DIR \
        --disable-dap;

    make check;
    make install;

    export NETCDF=$LIB_INSTALL_DIR;
}

install_netcdf_fortran_library() {
    enter_temporary_download_folder;

    curl -L -O https://downloads.unidata.ucar.edu/netcdf-fortran/4.6.0/netcdf-fortran-4.6.0.tar.gz;
    tar -xvzf netcdf-fortran-4.6.0.tar.gz;
    cd netcdf-fortran-4.6.0;

    export LIBS="-lnetcdf -lhdf5_hl -lhdf5 -lz";

    ./configure \
        --prefix=$LIB_INSTALL_DIR \
        --disable-shared;

    make check;
    make install;
}

install_mpich() {
    enter_temporary_download_folder;

    curl -L -O https://www.mpich.org/static/downloads/4.1.1/mpich-4.1.1.tar.gz;
    tar -xvzf mpich-4.1.1.tar.gz;
    cd mpich-4.1.1;

    ./configure --prefix=$LIB_INSTALL_DIR;
    make;
    make install;
}

install_libpng() {
    enter_temporary_download_folder;

    curl -L -O https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz;
    tar -xvzf libpng-1.6.37.tar.gz;
    cd libpng-1.6.37;

    ./configure --prefix=$LIB_INSTALL_DIR;
    make;
    make install;
}

install_jasper() {
    enter_temporary_download_folder;

    curl -L -O https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.29.tar.gz;
    tar -xvzf jasper-1.900.29.tar.gz;
    cd jasper-1.900.29;
    
    autoreconf -i;
    ./configure --prefix=$LIB_INSTALL_DIR;
    make;
    make install;

    export JASPERLIB=$LIB_INSTALL_DIR/lib;
    export JASPERINC=$LIB_INSTALL_DIR/include;
}

install_wrf() {
    enter_temporary_download_folder;

    curl -L -O https://github.com/wrf-model/WRF/releases/download/v4.4.2/v4.4.2.tar.gz;
    tar -xvzf v4.4.2.tar.gz;
    mv WRF $WRF_INSTALL_DIR;
    cd $WRF_INSTALL_DIR;
    
    ./clean;
    echo "34" | ./configure;
    ./compile em_real;

    export WRF_DIR=$WRF_INSTALL_DIR;
}

install_wps() {
    enter_temporary_download_folder;

    curl -L -O https://github.com/wrf-model/WPS/archive/refs/tags/v4.4.tar.gz;
    tar -xvzf WPS-4.4.tar.gz;
    mv WPS-4.4 $WPS_INSTALL_DIR;
    cd $WPS_INSTALL_DIR;

    echo "3" | ./configure;
    ./compile;
}

save_environment_variables() {
    {
        echo "export PATH=$LIB_INSTALL_DIR/bin:$PATH";
        echo "export LD_LIBRARY_PATH=$LIB_INSTALL_DIR/lib:$LD_LIBRARY_PATH";
        echo "export WRF_DIR=$WRF_INSTALL_DIR";
        echo "export WPS_DIR=$WPS_INSTALL_DIR";
    }   >> ~/.bashrc;
}

delete_temporary_folder() {
    cd;
    rm -rf "$TMP_BUILD_DIR";
}

main() {
    enter_temporary_download_folder;

    install_base_dependencies \
    && install_zlib \
    && install_hdf5 \
    && install_netcdf_c_library \
    && install_netcdf_fortran_library \
    && install_mpich \
    && install_libpng \
    && install_jasper \
    && install_wrf \
    && install_wps \
    && save_environment_variables;

    delete_temporary_folder;
}

main;
