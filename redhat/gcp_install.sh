#!/bin/bash

# This is designed to run on RedHat / Centos 6.x or 7.x
#
# usage:  gcp-install.sh [--gpu]
#

RH_VERSION=$(lsb_release -rs | cut -f1 -d.)

# update system packages
sudo yum update 
sudo yum -y upgrade 

# install pip, devel tools, and git
sudo yum install -y python-pip python-dev git

#
# update gcloud sdk:  see https://cloud.google.com/sdk/docs/quickstart-redhat-centos
#

if [[ $RH_VERSION == "6" ]] ; then

pushd ~  
wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-155.0.0-linux-x86_64.tar.gz
tar xzf google-cloud-sdk-155.0.0-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
popd

elif [[ $RH_VERSION == "7" ]] ; then
  
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

# Install the Cloud SDK
yum -y install google-cloud-sdk

fi


# gcloud sdk config
# pick the default service account, and the project "geocrawler-158117".  
gcloud init

# download source code repo from project
gcloud source repos clone <project_repo> --project=<project_id>

# install miniconda
wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
bash Miniconda2-latest-Linux-x86_64.sh -b
export PATH=~/miniconda2/bin:$PATH
cat >> ~/.bashrc <<EOL
export PATH=~/miniconda2/bin:$PATH
EOL

# install cuda 8 (GPU ONLY)
if [[ $# > 0 && $1 == "--gpu" ]] ; then
  sudo bash geocrawler/cuda_install.sh
fi

# OPTIONAL: install cudnn 5.1 (requires login to NVidia developer, download of cudnn-8.0-linux-x64-v5.1.tgz)
tar xzf cudnn-8.0-linux-x64-v5.1.tgz
sudo cp cuda/lib64/* /usr/lib/x86_64-linux-gnu/

# create and activate conda environment, named 'tf' in this example
conda create -y -n tf
source activate tf

# install packages
conda install -y --file <repo>/requirements.txt

if [[ $# > 0 && $1 == "--gpu" ]] ; then
  pip install tensorflow==1.1.0
else
  pip install tensorflow-gpu==1.1.0
fi

# install packages with pip that we can't install via conda
pip install ipdb
pip install -U crcmod

# install google-compute-engine package (needed for gsutil)
pip install google_compute_engine

# download data from GS bucket
mkdir data
gsutil cp gs://<bucket>/<file> data/<file>

# GPU: useful test that everything installed okay
if [[ $# > 0 && $1 == "--gpu" ]] ; then
  python -c "import tensorflow as tf; print(tf.test.gpu_device_name())"
fi
