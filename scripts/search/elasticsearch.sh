#!/bin/bash

if ! yum list installed elasticsearch >/dev/null 2>&1; then
    echo 'Installing ElasticSearch'

    cat > /etc/yum.repos.d/elasticsearch.repo <<- CONTENT
[elasticsearch-1.5]
name=Elasticsearch repository for 1.5.x packages
baseurl=http://packages.elasticsearch.org/elasticsearch/1.5/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
CONTENT
    rpm --import https://packages.elasticsearch.org/GPG-KEY-elasticsearch >/dev/null 2>&1
    yum install -y elasticsearch java >/dev/null 2>&1
    chkconfig elasticsearch on >/dev/null 2>&1
    
    # Start service
    service elasticsearch start >/dev/null 2>&1
fi
