FROM    ubuntu:20.04

ENV TZ=Europe/Warsaw

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt -y update && \
    apt -y upgrade && \
    apt install -y curl gnupg lsb-release software-properties-common apt-transport-https ca-certificates git pwgen

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt install -y terraform

RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" |  tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt -y update && \
    apt install -y helm

RUN  curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" |  tee /etc/apt/sources.list.d/kubernetes.list && \
    apt -y update && \
    apt install -y kubectl

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" |  tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt -y update && \
    apt install -y google-cloud-sdk

CMD mkdir -p /home/git/ && \
    cd /home/git/ && \
    git clone https://github.com/biodatageeks/tbd-infra.git && \
    /bin/bash

RUN apt install -y wget
RUN mkdir -p /opt/tools && \
    cd /opt/ && wget https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz -O /opt/k9s_Linux_x86_64.tar.gz && \
    tar zxvf k9s_Linux_x86_64.tar.gz -C /opt/tools

ENV PATH=$PATH:/opt/tools

RUN wget https://golang.org/dl/go1.16.2.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.2.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin
WORKDIR /home/git
RUN git clone https://github.com/GoogleCloudPlatform/spark-on-k8s-operator.git && \
    cd spark-on-k8s-operator/sparkctl && \
    git checkout tags/spark-operator-chart-1.0.8 && \
    go build -o sparkctl

ENV PATH=$PATH:/home/git/spark-on-k8s-operator/sparkctl