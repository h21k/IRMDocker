#############################
# Domainbed Docker Base
# 2020 Docker Version:v2.79
# Frank Soboczenski
# 2021, May
#############################

FROM nvidia/cuda:11.1.1-base-ubuntu20.04

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
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py38_4.9.2-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh \
 && conda install -y python==3.8.3 \
 && conda clean -ya

# CUDA 11.1-specific steps
RUN conda install -y -c conda-forge cudatoolkit=11.1.1 \
 && conda install -y -c pytorch \
     "pytorch=1.8.1=py3.8_cuda11.1_cudnn8.0.5_0" \
     "torchvision=0.9.1=py38_cu111" \
 && conda clean -ya

# Installing neccessary libraries
RUN pip install -r requirements.txt

RUN pip install torch-sparse
RUN pip install torch-scatter

#-f https://pytorch-geometric.com/whl/torch-1.8.0+cu102.html
#RUN pip install --no-index torch-scatter==2.0.5 -f https://pytorch-geometric.com/whl/torch-1.5.0+cu102.html

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
