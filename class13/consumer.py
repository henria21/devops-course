import pika
import json
from datetime import datetime

credentials = pika.PlainCredentials('guest', 'guest')

parameters = pika.ConnectionParameters(
    host='localhost',
    credentials=credentials
)

connection = pika.BlockingConnection(parameters)
channel = connection.channel()
queue_name = 'orders'
channel.queue_declare(queue=queue_name)


def callback(ch, method, properties, body):
    message = json.loads(body.decode())
    username = message["username"]
    event_type = message["event_type"]
    timestamp = datetime.fromisoformat(message["timestamp"]).strftime("%H:%M")
    print(f"User {username} triggered {event_type} at {timestamp}")
    ch.basic_ack(delivery_tag=method.delivery_tag)


channel.basic_qos(prefetch_count=1)
channel.basic_consume(queue=queue_name, on_message_callback=callback)

print("Waiting for messages. Press CTRL+C to exit.")
try:
    channel.start_consuming()
except KeyboardInterrupt:
    channel.stop_consuming()
    connection.close()
