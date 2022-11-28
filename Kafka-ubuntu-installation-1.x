#!/bin/bash

# Tested in Ubuntu

# Installing Apache Kafka latest version - https://archive.apache.org/dist/kafka/1.0.0/RELEASE_NOTES.html

#************** Installing Amazon Corretto Java 8 **************
wget https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.deb --no-check-certificate #--no-check-certificate needed in case wget not able to verify the certificate.
sudo apt-get update
sudo apt-get install java-common
sudo dpkg --install java-1.8.0-amazon-corretto-jdk_8.252.09-1_amd64.deb

rm -rf /tmp/kafka-logs /tmp/zookeeper

#************** Setting up ZooKeeper **************
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.11/zookeeper-3.4.11.tar.gz --no-check-certificate #--no-check-certificate needed in case wget not able to verify the certificate.
tar -xzf zookeeper-3.4.11.tar.gz && rm -rf zookeeper-3.4.11.tar.gz
mv zookeeper-3.4.11 zookeeper
chmod a+x zookeeper/bin/*
touch zookeeper/conf/zoo.cfg
echo -e "tickTime=2000\ndataDir=/tmp/zookeeper\nclientPort=2181" > zookeeper/conf/zoo.cfg

#************** Setting up Kafka **************
wget https://archive.apache.org/dist/kafka/1.0.0/kafka_2.11-1.0.0.tgz --no-check-certificate #--no-check-certificate needed in case wget not able to verify the certificate.
tar -xzf kafka_2.11-1.0.0.tgz && rm -rf kafka_2.11-1.0.0.tgz
mv kafka_2.11-1.0.0 kafka
chmod a+x kafka/bin/*

#************** Starting zookeeper and kafka in daemon mode **************
zookeeper/bin/./zkServer.sh start
kafka/bin/./kafka-server-start.sh -daemon kafka/config/server.properties

#************** Creating a topic **************
kafka/bin/./kafka-topics.sh --create --topic quickstart-events --zookeeper localhost:2181 --partitions 2 --replication-factor 1

#************** Describing a topic **************
kafka/bin/./kafka-topics.sh --describe --topic quickstart-events --zookeeper localhost:2181

#************** Publishing messages via console producer to topic **************
for x in {1..100}; do echo "Test Message $x"; done | kafka/bin/./kafka-console-producer.sh --topic quickstart-events --broker-list localhost:9092

#************** Consuming first 100 messages via console consumer to topic **************
kafka/bin/./kafka-console-consumer.sh --topic quickstart-events --from-beginning --zookeeper localhost:2181 --max-messages 100


#************** Stopping kafka first and zookeeper next in daemon mode **************
kafka/bin/./kafka-server-stop.sh -daemon ../config/server.properties
zookeeper/bin/./zkServer.sh stop

#************** Deleting kafka logs and zookeeper data **************
rm -rf /tmp/kafka-logs /tmp/zookeeper

echo "Single Node cluster setup installed and tested!!"
