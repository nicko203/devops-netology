ARG OS_VERSION=7
ARG ES_VERSION=8.0.1

FROM centos:$OS_VERSION

ENV ES_VER=8.0.1
ENV ES_HOME=/opt/elasticsearch-${ES_VER}
ENV ES_JAVA_HOME=/opt/elasticsearch-${ES_VER}/jdk
ENV ES_JAVA_OPTS="-Xms128m -Xmx128m"
ENV PATH=$PATH:/opt/elasticsearch-${ES_VER}/bin

RUN yum update -y --setopt=tsflags=nodocs && \
yum install -y perl-Digest-SHA && \
yum install -y wget && \
rm -rf /var/cache/yum && \
groupadd elastic && \
useradd elastic -g elastic -p elasticsearch && \
mkdir -p /var/lib/elasticsearch/logs && \
mkdir -p /var/lib/elasticsearch/snapshots && \
mkdir -p /var/lib/elasticsearch/data

WORKDIR /opt

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VER}-linux-x86_64.tar.gz && \
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VER}-linux-x86_64.tar.gz.sha512 && \
shasum -a 512 -c elasticsearch-${ES_VER}-linux-x86_64.tar.gz.sha512 && \
tar -xzf elasticsearch-${ES_VER}-linux-x86_64.tar.gz && \
rm elasticsearch-${ES_VER}-linux-x86_64.tar.gz && \
chown -R elastic:elastic ${ES_HOME} && chown -R elastic:elastic /var/lib/elasticsearch

ADD elasticsearch.yml ${ES_HOME}/config/elasticsearch.yml

EXPOSE 9200 9300

WORKDIR ${ES_HOME}

USER elastic

CMD ["elasticsearch"]