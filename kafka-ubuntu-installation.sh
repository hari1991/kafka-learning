#!/bin/bash

# Tested in Ubuntu

# Installing Apache Kafka latest version - https://kafka.apache.org/documentation/#upgrade_300_notable

#************** Installing Amazon Corretto Java 8 **************
wget https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.deb --no-check-certificate #--no-check-certificate needed in case wget not able to verify the certificate.
sudo apt-get update
sudo apt-get install java-common
sudo dpkg --install java-1.8.0-amazon-corretto-jdk_8.252.09-1_amd64.deb

#************** Setting up latest Kafka **************
wget https://dlcdn.apache.org/kafka/3.3.1/kafka_2.13-3.3.1.tgz --no-check-certificate #--no-check-certificate needed in case wget not able to verify the certificate.
tar -xzf kafka_2.13-3.3.1.tgz && rm -rf kafka_2.13-3.3.1.tgz
mv kafka_2.13-3.3.1 kafka
cd kafka/bin && chmod a+x *

#************** Starting zookeeper and kafka in daemon mode **************
./zookeeper-server-start.sh -daemon ../config/zookeeper.properties
./kafka-server-start.sh -daemon ../config/server.properties

#************** Creating a topic **************
./kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092 --partitions 2

#************** Describing a topic **************
./kafka-topics.sh --describe --topic quickstart-events --bootstrap-server localhost:9092

#************** Publishing messages via console producer to topic **************
for x in {1..100}; do echo "Test Message $x"; done | ./kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092

#************** Consuming first 100 messages via console consumer to topic **************
./kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092 --max-messages 100

#************** Stopping kafka first and zookeeper next in daemon mode **************
./kafka-server-stop.sh -daemon ../config/server.properties
./zookeeper-server-stop.sh -daemon ../config/zookeeper.properties

#************** Deleting kafka logs and zookeeper data **************
rm -rf /tmp/kafka-logs /tmp/zookeeper

echo "Single Node cluster setup installed and tested!!"
