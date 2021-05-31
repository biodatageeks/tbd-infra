# Spark 3.1.1 image with gcs-connector and hadoop 3 support
# Publish image to gcr.io - https://cloud.google.com/container-registry/docs/pushing-and-pulling#pushing_an_image_to_a_registry
ARG SPARK_IMAGE=gcr.io/spark-operator/spark:v3.1.1-hadoop3
ARG BWA_VERSION=0.7.17

FROM ${SPARK_IMAGE}

# Switch to user root so we can add additional jars and configuration files.
USER root

# Setup dependencies for Google Cloud Storage access.
RUN rm $SPARK_HOME/jars/guava-14.0.1.jar
ADD https://repo1.maven.org/maven2/com/google/guava/guava/23.0/guava-23.0.jar $SPARK_HOME/jars
RUN chmod 644 $SPARK_HOME/jars/guava-23.0.jar

ADD https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-latest.jar $SPARK_HOME/jars
RUN chmod 644 $SPARK_HOME/jars/gcs-connector-hadoop3-latest.jar

# Setup for the Prometheus JMX exporter.
# Add the Prometheus JMX exporter Java agent jar for exposing metrics sent to the JmxSink to Prometheus.
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar /prometheus/
RUN chmod 644 /prometheus/jmx_prometheus_javaagent-0.11.0.jar

# Install BWA - http://bio-bwa.sourceforge.net/
ADD http://downloads.sourceforge.net/project/bio-bwa/bwa-0.7.17.tar.bz2 /tmp/
RUN apt-get update && apt-get install -y bzip2 musl-dev libz-dev make gcc \
  && cd /tmp/ && tar xjvf bwa-0.7.17.tar.bz2 \
  && cd /tmp/bwa-0.7.17 \
  && sed -i '1i#include <stdint.h>' kthread.c \
  && sed -i[.bak] "s/u_int32_t/uint32_t/g" *.c  \
  && sed -i[.bak] "s/u_int32_t/uint32_t/g" *.h  \
  && make \
  && mv /tmp/bwa-0.7.17/bwa /usr/bin

# Install Samtools - http://samtools.sourceforge.net/
RUN apt-get update && apt-get install -y libpcre3-dev openssl libssl-dev build-essential curl bzip2 libbz2-dev liblzma-dev\
     && curl -L -o samtools-1.11.tar.bz2 \
        http://jaist.dl.sourceforge.net/project/samtools/samtools/1.11/samtools-1.11.tar.bz2 \
     && tar jxvf samtools-1.11.tar.bz2  \
     && cd samtools-1.11/ \
     && ./configure --without-curses \
     && make \
     && make install

# Install VEP - https://github.com/Ensembl/ensembl-vep
RUN apt-get update && apt-get install -y g++ perl git cpanminus libdbi-perl libarchive-zip-perl libdbd-mysql-perl  libarchive-extract-perl \
  && cd /tmp/ \
  && git clone https://github.com/Ensembl/ensembl-vep.git \
  && cd ensembl-vep/ \
  && cpanm inc::latest \
  && cpanm Module::Build \
  && git checkout release/104.3 \
  && perl INSTALL.pl -n -a a \
  && mkdir -p /opt && mv /tmp/ensembl-vep /opt/

ENV PATH=$PATH:/opt/ensembl-vep

RUN mkdir -p /mnt/data
RUN mkdir -p /etc/metrics/conf
COPY metrics.properties /etc/metrics/conf
COPY prometheus.yaml /etc/metrics/conf
COPY ref /home/ref

ENTRYPOINT ["/opt/entrypoint.sh"]
