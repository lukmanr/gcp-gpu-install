#!/bin/bash

echo "Checking for CUDA and installing."

RH_VERSION=$(lsb_release -rs | cut -f1 -d.)

if [[ $RH_VERSION == "6" ]] ; then

  # Check for CUDA and try to install.
  if ! rpm -q  cuda; then
    curl -O http://developer.download.nvidia.com/compute/cuda/repos/rhel6/x86_64/cuda-repo-rhel6-8.0.61-1.x86_64.rpm
    rpm -i --force ./cuda-repo-rhel6-8.0.61-1.x86_64.rpm
    curl -O https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
    rpm -i --force ./epel-release-latest-6.noarch.rpm
    yum clean all
    yum update -y
    yum install cuda -y
  fi
  # Verify that CUDA installed; retry if not.
  if ! rpm -q  cuda; then
    yum install cuda -y
  fi

elif [[ $RH_VERSION == "7" ]] ; then

  # Check for CUDA and try to install.
  if ! rpm -q  cuda; then
    curl -O http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm
    rpm -i --force ./cuda-repo-rhel7-8.0.61-1.x86_64.rpm
    curl -O https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm -i --force ./epel-release-latest-7.noarch.rpm
    yum clean all
    yum update -y
    yum install cuda -y
  fi
  # Verify that CUDA installed; retry if not.
  if ! rpm -q  cuda; then
    yum install cuda -y
  fi
  
fi