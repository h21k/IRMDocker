#############################
# Domainbed Docker Base
# 2020 Docker Version:v01
# Frank Soboczenski
# 2021, April
#############################

FROM nvidia/cuda:10.2-base-ubuntu18.04

MAINTAINER "Frank Soboczenski <frank.soboczenski@gmail.com>"

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    bash \
    gcc \
    g++ \
    git \
    bzip2 \
    libx11-6 \
 && rm -rf /var/lib/apt/lists/*

# Create a working directory
RUN mkdir /app
COPY . /app
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory

ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda and Python 3.8
ENV CONDA_AUTO_UPDATE_CONDA=false
ENV PATH=/home/user/miniconda/bin:$PATH
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh \
 && conda install -y python==3.7 \
 && conda clean -ya

# && conda install -y python==3.8.1 \

# CUDA 10.2-specific steps
PART INOPERABLE - FILE WILL BE CHANGED

# Installing neccessary libraries
RUN pip install -r requirements.txt

RUN pip install torch-scatter -f https://pytorch-geometric.com/whl/torch-1.8.0+${CUDA}.html

# Set the default command to python3
CMD ["python3"]

RUN echo "downloading domainbed"
#RUN git clone https://github.com/facebookresearch/DomainBed.git
RUN git clone https://github.com/h21k/DomainBed.git

#Downloading the data
RUN cd DomainBed && python3 -m domainbed.scripts.download \
    --data_dir=./domainbed/data

RUN sh -c 'echo -e IMAGE COMPLETED - READY TO RUN'

CMD tail -f /dev/null
