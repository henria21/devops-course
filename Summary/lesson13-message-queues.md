# Class 13 — Message Queues
> Source: course PowerPoint (29 slides) — *Message Queues: Kafka · NATS · RabbitMQ*

---

## Why Message Queues Exist

**The problem with direct (synchronous) HTTP calls:**
- Service A waits for B to respond → if B is down, A fails; if B is slow, A is slow
- Tight coupling — A must know B's address
- Traffic spikes can overwhelm B

**With a message queue:**
- A drops a message and moves on
- B processes when ready; can be down without losing messages
- Add more B workers to scale; queue absorbs traffic spikes
- A and B never know each other

---

## Core Vocabulary

| Term | Meaning |
|---|---|
| Producer | Service that sends messages |
| Consumer | Service that reads & processes messages |
| Broker | Server that stores & routes messages (RabbitMQ / Kafka / NATS) |
| Queue | Ordered buffer — messages wait here (RabbitMQ) |
| Topic | Named channel for publishing (Kafka, NATS) |
| Acknowledgment (ack) | Consumer's signal that a message was handled |
| Exchange | RabbitMQ router — decides which queues get each message |
| Binding | Rule linking a queue to an exchange |
| Offset | Consumer's position in a Kafka partition |

---

## Four Messaging Patterns

| Pattern | Description |
|---|---|
| **Point-to-Point** | 1 producer → 1 queue → 1 consumer |
| **Work Queue** | 1 queue → N competing workers; each message → exactly 1 worker |
| **Pub/Sub** | 1 event → all subscribers each get a copy |
| **Request/Reply (RPC)** | Producer sends request, waits for reply on a return queue |

```
WORK QUEUE  → each message goes to ONE worker  (load balancing)
PUB/SUB     → each message goes to ALL subs    (broadcast)
```

---

## Why DevOps Loves Message Queues

| Benefit | Explanation |
|---|---|
| Decoupling | Services evolve independently — change one without breaking others |
| Async processing | Long jobs (video, email) move off the request path |
| Reliability | Messages persist even if a consumer crashes — replay later |
| Scalability | Add/remove consumer workers based on queue depth |
| Buffering | Absorb traffic spikes — protect downstream from overload |
| Fan-out | One event → analytics + audit + notifications simultaneously |

---

## RabbitMQ

- Born 2007 · Open source · Built on **Erlang/OTP**
- Protocol: **AMQP 0-9-1**
- **Smart broker, dumb consumer** — broker handles all routing logic
- **Push model** — broker pushes messages to consumers
- Per-message ACKs and re-delivery
- Management UI on port **15672**

### Architecture
```
Producer → Exchange → [Binding] → Queue → Consumer
```

### Exchange Types
| Type | Routing logic |
|---|---|
| **Direct** | Routing key must exactly match binding key |
| **Fanout** | Broadcasts to ALL bound queues (ignores routing key) |
| **Topic** | Pattern matching: `*` = one word, `#` = zero or more (`logs.*.error`) |
| **Headers** | Routes by message header attributes (`x-match: all/any`) |

**Best for:** task queues, complex routing, RPC, enterprise messaging

---

## Apache Kafka

- Born 2011 (LinkedIn) · Apache Foundation · **JVM-based**
- **Append-only commit log** — messages not removed by consumption
- **Pull model** — consumers fetch at their own pace
- Millions of msg/sec throughput
- Long-term retention — replay events days/weeks later

### Key Concepts
| Term | Meaning |
|---|---|
| Topic | Named log — written to and read from |
| Partition | Shard of a topic; ordered, immutable |
| Offset | Each message's position in partition; consumer tracks own offset |
| Consumer group | Workers sharing load; 1 partition → 1 consumer in the group |

**Best for:** event sourcing, log aggregation, stream processing, high-throughput pipelines

---

## NATS

- Born 2011 · **CNCF graduated** · Written in **Go** · Single binary (~20 MB)
- Subject-based routing with wildcards (`orders.*`, `sensors.>`)
- Core NATS = **at-most-once, fire-and-forget**, very fast
- **JetStream** adds persistence, replay, exactly-once semantics
- Built-in request/reply (RPC) pattern

**Best for:** microservices, IoT, edge, low-latency RPC, ephemeral pub/sub

---

## Side-by-Side Comparison

| Aspect | RabbitMQ | Kafka | NATS |
|---|---|---|---|
| Model | Smart broker / push | Distributed log / pull | Pub-sub / push |
| Protocol | AMQP 0-9-1 | Custom binary | Custom text |
| Throughput | ~50K msg/s | Millions msg/s | Millions msg/s |
| Latency | Low (ms) | Medium (10s ms) | Very low (sub-ms) |
| Persistence | Optional (durable flag) | Always (log) | JetStream only |
| Routing | 4 exchange types | Topic + partition | Subject wildcards |
| Footprint | Erlang VM ~100 MB | JVM ~500 MB+ | Go binary ~20 MB |

### When to Pick Each

| Pick RabbitMQ when… | Pick Kafka when… | Pick NATS when… |
|---|---|---|
| Background task queues | Event sourcing & CDC | Edge / IoT messaging |
| Complex routing rules | Log aggregation at scale | Sub-ms pub/sub |
| RPC over messaging | Stream processing | Tiny ops footprint |
| Need a great UI | Replay days of events | Multi-cluster / geo |

---

## Hands-On: RabbitMQ + Python (`pika`)

### Start RabbitMQ
```bash
docker run -d --name rabbit \
  -p 5672:5672 -p 15672:15672 \
  rabbitmq:3-management

pip install pika
# UI: http://localhost:15672  (guest / guest)
```

### Producer
```python
import pika, json

conn = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
ch   = conn.channel()
ch.queue_declare(queue='tasks', durable=True)

for i in range(5):
    payload = json.dumps({'id': i, 'work': f'process-{i}'})
    ch.basic_publish(
        exchange='',
        routing_key='tasks',
        body=payload,
        properties=pika.BasicProperties(delivery_mode=2)  # persistent
    )
    print(f'sent {payload}')
conn.close()
```

### Consumer / Worker
```python
import pika, json, time

conn = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
ch   = conn.channel()
ch.queue_declare(queue='tasks', durable=True)
ch.basic_qos(prefetch_count=1)  # fair dispatch

def callback(ch, method, properties, body):
    task = json.loads(body)
    print(f'received {task}')
    time.sleep(1)                                    # simulate work
    ch.basic_ack(delivery_tag=method.delivery_tag)   # manual ack

ch.basic_consume(queue='tasks', on_message_callback=callback, auto_ack=False)
print('waiting for tasks…')
ch.start_consuming()
```

### Scale out: run multiple workers
```bash
# Terminal 1: python worker.py
# Terminal 2: python worker.py   ← RabbitMQ round-robins between them
# Terminal 3: python sender.py
```

---

## Common Pitfalls

| Mistake | Consequence | Fix |
|---|---|---|
| No manual ack | Messages re-delivered forever | `ch.basic_ack()` on success |
| `auto_ack=True` | Worker crash = message lost | Always use `auto_ack=False` |
| Non-durable queue | Broker restart wipes queue | `durable=True` + `delivery_mode=2` |
| No prefetch | One worker starves others | `basic_qos(prefetch_count=1)` |
| No connection retry | Network blip kills service | Retry with exponential backoff |
| No dead-letter queue | Bad messages loop forever | Configure DLX |

---

## Home Assignment — Multi-Worker Task Queue

**Must-have (passing):**
- RabbitMQ via `docker-compose`
- Producer publishes **50 "image-resize" tasks**
- Worker processes tasks (sleep = simulated work)
- **3 workers in parallel** — show round-robin
- `durable=True` + `delivery_mode=2` + **manual ack**
- `prefetch_count=1`
- README with setup + run instructions

**Bonus:**
- Dead-letter exchange for failed tasks
- Kill a worker mid-task → show message re-queued
- Prometheus metrics (queue depth, processed/sec)
- Connection retry with exponential backoff
- Full docker-compose stack (broker + producer + 3 workers)
- **Bonus++:** Replace with NATS or Kafka — compare

---

## Key Takeaways

1. **Decouple, don't block** — queues let services scale and fail independently
2. **Pick the right broker** — RabbitMQ for tasks/routing, Kafka for streams/replay, NATS for speed/IoT
3. **Always ack manually** — `auto_ack=True` loses messages on worker crash
4. **durable + persistent + manual ack = at-least-once delivery**

---

## Assignment

**Goal:** Build a complete messaging system using RabbitMQ — producer, consumer, and queue — then observe behavior in the dashboard and answer conceptual questions.

**Setup:**
```yaml
# docker-compose.yml
version: '3'
services:
  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "5672:5672"
      - "15672:15672"
```
```bash
docker compose up -d
# Open: http://localhost:15672 (guest / guest)
```

**Tasks:**
1. **Producer (`producer.py`)** — Send 10 messages, each with `username`, `event_type`, `timestamp` fields
2. **Consumer (`consumer.py`)** — Listen to `events` queue, print each message in readable format
3. **Dashboard observation** — Observe Ready vs Unacked message counts
4. **Experiment** — Run producer alone, then start consumer; observe queue draining
5. **curl test** — Send a message via HTTP API:
```bash
curl -u guest:guest \
  -H "content-type:application/json" \
  -X POST \
  -d '{"properties":{},"routing_key":"events","payload":"Message sent via curl","payload_encoding":"string"}' \
  http://localhost:15672/api/exchanges/%2F/amq.default/publish
```
6. **Answer theory questions** (Parts A–D)
7. **Bonus** — Add 3 consumers with `time.sleep` delay; observe load distribution

---

## Student Answers

### Part A — Concepts

**1. What is the role of a message broker?**
A message broker is middleware that receives messages from producers and routes them to consumers. It decouples the sender from the receiver — they operate independently without knowing about each other.

**2. Why is RabbitMQ considered asynchronous communication?**
The producer sends a message and continues immediately — it does not wait for the consumer to process or respond. The consumer handles the message at its own pace.

**3. What is the difference between a producer and a consumer?**
A producer creates and sends messages to the queue. A consumer reads and processes messages from the queue.

**4. What happens if no consumer is running?**
Messages accumulate in the queue until a consumer connects. RabbitMQ holds them (up to capacity) — no messages are lost.

**5. Why do we use queues instead of direct API calls?**
Queues provide decoupling, resilience, and load buffering. With direct API calls, if the receiver is down the message is lost and the sender is blocked. With queues, the sender continues and the receiver processes when ready.

### Part B — RabbitMQ Behavior

**6. What happens when multiple consumers connect to the same queue?**
RabbitMQ distributes messages across all consumers using round-robin — each message is delivered to exactly one consumer.

**7. Does RabbitMQ send the same message to all consumers?**
No. Each message goes to only one consumer — the goal is work distribution, not duplication.

**8. What is "competing consumers"?**
Multiple consumer instances listening to the same queue, racing to process messages. Increases throughput and provides redundancy.

**9. What is the benefit of horizontal scaling in queues?**
Add more consumers to process messages faster without changing the producer or queue — purely elastic scaling.

### Part C — Practical Understanding

**10. Dashboard observations:**
- **Producer alone:** Messages accumulate — "Ready" count rises, nothing acknowledged
- **Consumer alone:** Queue stays at 0; consumer waits idle
- **Both together:** Messages flow through immediately — "Ready" stays near 0, throughput visible in graphs

**11. Ready vs Unacked:**
- **Ready** — messages in the queue waiting to be delivered
- **Unacked** — delivered to a consumer but not yet acknowledged (consumer still processing); RabbitMQ holds them for redelivery if the consumer crashes

### Part D — Reflection

**12. Real-world systems using queues:**
- **Order processing (e-commerce):** Order → queue → separate services for payment, inventory, shipping
- **Email/notification delivery:** User action → queue → notification service sends emails/push notifications without blocking the main app

**13. When to choose RabbitMQ over HTTP calls:**
Choose RabbitMQ when:
- Receiver might be temporarily unavailable and you can't lose the request
- Task is long-running and sender shouldn't wait (fire-and-forget)
- Need to distribute work across multiple workers (competing consumers)
- Services need to scale and deploy independently

Use direct HTTP when you need an immediate response or the operation is simple and synchronous.
