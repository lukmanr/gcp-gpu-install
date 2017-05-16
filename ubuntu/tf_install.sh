#!/bin/bash

# Install Tensorflow environment (optionally w/ GPU support)
#
# This is designed to run on Ubuntu 16.04.  Should work on 16.10.
#
# usage:  tf_install.sh [--gpu]
#


# update system packages
sudo apt-get update 
sudo apt-get -y upgrade 

# install pip, devel tools, and git
sudo apt-get install -y python-pip python-dev git

#
#  GCP ONLY:  BEGIN
#

#
# update gcloud sdk:  see https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu
#

# Create an environment variable for the correct distribution
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

# Add the Cloud SDK distribution URI as a package source
echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get -y install google-cloud-sdk


# gcloud sdk config
# pick the default service account
gcloud init

# download repo
gcloud source repos clone <repo> --project=<project>

#
#  GCP ONLY:  END
#

# load git submodules
pushd <repo>
git submodule update --init --recursive
popd

# install miniconda
wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
bash Miniconda2-latest-Linux-x86_64.sh -b
export PATH=~/miniconda2/bin:$PATH
cat >> ~/.bashrc <<EOL
export PATH=~/miniconda2/bin:$PATH
EOL

# install cuda 8 (GPU ONLY)
if [[ $# > 0 && $1 == "--gpu" ]] ; then
  sudo bash cuda_install.sh
fi

# OPTIONAL: install cudnn 5.1 (requires login to NVidia developer, download of cudnn-8.0-linux-x64-v5.1.tgz)
tar xzf cudnn-8.0-linux-x64-v5.1.tgz
sudo cp cuda/lib64/* /usr/lib/x86_64-linux-gnu/

# create and activate conda environment
conda create -y -n tf
source activate tf

# install packages
conda install -y --file <repo>/requirements.txt

if [[ $# > 0 && $1 == "--gpu" ]] ; then
  pip install tensorflow==1.0.1
else
  pip install tensorflow-gpu==1.0.1
fi

# install packages with pip that we can't install via conda
pip install ipdb
pip install -U crcmod

#
#  GCP ONLY:  BEGIN
#

# install google-compute-engine package (needed for gsutil)
pip install google_compute_engine

# download data file
mkdir <repo>/data
gsutil cp gs://<data path> <repo>/data

#
#  GCP ONLY:  END
#

# GPU: useful test that everything installed okay
if [[ $# > 0 && $1 == "--gpu" ]] ; then
  python -c "import tensorflow as tf; print(tf.test.gpu_device_name())"
fi
