FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

RUN apt-get update && apt-get install -y python3.11 python3.11-dev python3-pip git && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

COPY requirements.txt /opt/requirements.txt
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r /opt/requirements.txt && \
    pip install --no-deps git+https://github.com/aniskhan25/hmsc-hpc
