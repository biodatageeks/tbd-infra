FROM broadinstitute/gatk

# Switch to user root so we can add additional jars and configuration files.
USER root

# Spark installation
WORKDIR /tmp
# Using the preferred mirror to download Spark
RUN wget -q https://archive.apache.org/dist/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz
RUN tar xzf "spark-3.1.1-bin-hadoop3.2.tgz" -C /usr/local --owner root --group root --no-same-owner && \
    rm "spark-3.1.1-bin-hadoop3.2.tgz"

WORKDIR /usr/local
RUN ln -s "spark-3.1.1-bin-hadoop3.2" spark

# Configure Spark
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$SPARK_HOME/bin

RUN mkdir -p /tmp/jars

RUN cd /tmp/jars && wget https://repo1.maven.org/maven2/com/google/cloud/bigdataoss/gcs-connector/hadoop3-2.2.1/gcs-connector-hadoop3-2.2.1-shaded.jar && \
    wget https://repo1.maven.org/maven2/com/google/cloud/google-cloud-nio/0.123.2/google-cloud-nio-0.123.2-shaded.jar

COPY ref /home/ref