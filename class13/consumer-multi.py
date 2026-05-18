import pika 
import socket 
import time 
import uuid 

consumer_name = f"consumer-{uuid.uuid4().hex[:6]}" 
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
    print( f"[{consumer_name}] " f"Received: {body.decode()}" ) 
    time.sleep(2) 

channel.basic_consume( 
    queue=queue_name, 
    on_message_callback=callback, 
    auto_ack=True 
) 
    
print(f'Consumer started: {consumer_name}') 
channel.start_consuming()