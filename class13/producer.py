import pika
import json
import time
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

usernames = ["john", "jane", "alice", "bob", "charlie", "diana", "eve", "frank", "grace", "henry"]
event_types = ["user_registered", "user_login", "purchase_made", "password_changed", "profile_updated"]

for i in range(10):
    message = {
        "username": usernames[i],
        "event_type": event_types[i % len(event_types)],
        "timestamp": datetime.now().isoformat()
    }
    channel.basic_publish(
        exchange='',
        routing_key=queue_name,
        body=json.dumps(message)
    )
    print(f"Sent: {message}")
    time.sleep(1)

connection.close()