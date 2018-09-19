# Karafka Example

A dockerized example on how to use Apache Kafka message broker with Ruby Karafka gem to publish/subscribe events between systems.

## Usage
1. Start the docker container by executing the below in the terminal (you need to install docker if not installed)
`docker-compose up --build`
Now Apache Kafka and Zookeeper are up and running, also our example-app is running Karafka server.

2. Attach shell to the container `example-app_app01` and send some messages by executing the following:
`rake waterdrop:send`
This will execute a `rake` task in the example code which publish some messages using `waterdrop` gem.

3. Now you should see logs indicates that the karafka server consumed the messages and a ping pong messaging is working.

Please note that the example used here is the same official example provided by Karafka, I made this repo to make it easy to get things (kafka, zookeeper, karafka server) up and running quickly so anybody can play with the example smoothly to get a simple POC of what we can acieve with kafka.

Also you can implement your local message producers/consumers and use the kafka instance running in this example on `kafka://localhost:9092`
