import json

from aiokafka import AIOKafkaConsumer, AIOKafkaProducer


class KafkaPubSub:
    def __init__(self, topic: str, bootstrap_servers: str = "localhost:9092"):
        self.topic = topic
        self.bootstrap_servers = bootstrap_servers
        self.producer: AIOKafkaProducer | None = None
        self.consumer: AIOKafkaConsumer | None = None

    async def start_producer(self):
        self.producer = AIOKafkaProducer(
            bootstrap_servers=self.bootstrap_servers,
            value_serializer=lambda v: json.dumps(v).encode("utf-8")
        )
        await self.producer.start()

    async def publish(self, message: dict):
        if not self.producer:
            await self.start_producer()
        await self.producer.send_and_wait(self.topic, message)

    async def subscribe(self):
        self.consumer = AIOKafkaConsumer(
            self.topic,
            bootstrap_servers=self.bootstrap_servers,
            value_deserializer=lambda v: json.loads(v.decode("utf-8")),
            auto_offset_reset="latest",
            group_id="graphql-subscriber",
        )
        await self.consumer.start()
        try:
            async for msg in self.consumer:
                yield msg.value
        finally:
            await self.consumer.stop()
