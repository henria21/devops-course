# Class 13 — RabbitMQ Answers

## Part A — Concepts

**1. What is the role of a message broker?**
A message broker is a middleware component that receives messages from producers and routes them to the appropriate consumers. It decouples the sender from the receiver, allowing them to operate independently without knowing about each other.

**2. Why is RabbitMQ considered asynchronous communication?**
Because the producer sends a message and continues immediately — it does not wait for the consumer to process or respond. The consumer handles the message at its own pace, independently of the producer.

**3. What is the difference between a producer and a consumer?**
A producer is the application that creates and sends messages to the queue. A consumer is the application that reads and processes messages from the queue.

**4. What happens if no consumer is running?**
Messages are stored in the queue and accumulate until a consumer connects. RabbitMQ holds the messages (up to the queue's capacity/limits) so no messages are lost.

**5. Why do we use queues instead of direct API calls?**
Queues provide decoupling, resilience, and load buffering. With direct API calls, if the receiver is down the message is lost and the sender is blocked. With queues, the sender continues working and the receiver processes messages when it's ready.

---

## Part B — RabbitMQ Behavior

**6. What happens when multiple consumers are connected to the same queue?**
RabbitMQ distributes messages across all connected consumers using round-robin by default — each message is delivered to exactly one consumer.

**7. Does RabbitMQ send the same message to all consumers? Why?**
No. Each message is delivered to only one consumer. This is by design for work distribution — the goal is to split the workload, not duplicate it.

**8. What is "competing consumers"?**
Competing consumers is a pattern where multiple consumer instances listen to the same queue and race to process messages. This increases throughput and provides redundancy.

**9. What is the benefit of horizontal scaling in queues?**
By adding more consumers, you can process messages faster without changing the producer or the queue. If load increases, you simply spin up more consumer instances to keep up.

---

## Part C — Practical Understanding

**10. What did you observe in the RabbitMQ dashboard when:**

- **Producer runs alone:** Messages accumulate in the queue. The "Ready" count rises with each message sent, and no messages are acknowledged.
- **Consumer runs alone:** The queue stays empty (0 ready). The consumer waits idle with no messages to process.
- **Both run together:** Messages flow through immediately. The "Ready" count stays near 0 as the consumer processes each message shortly after it arrives. Throughput is visible in the dashboard graphs.

**11. What is the difference between:**

- **Ready messages:** Messages that are in the queue and waiting to be delivered to a consumer.
- **Unacked messages:** Messages that have been delivered to a consumer but not yet acknowledged — the consumer is still processing them. RabbitMQ holds them in case the consumer crashes, so it can redeliver.

---

## Part D — Reflection

**12. Give 2 real-world systems that use queue messaging.**

- **Order processing (e-commerce):** When a user places an order, it's pushed to a queue. Separate services consume it to handle payment, inventory, and shipping independently and reliably.
- **Email/notification delivery:** When a user triggers an action (signup, purchase), a message is queued and a notification service consumes it to send emails or push notifications without blocking the main application.

**13. When would you choose RabbitMQ over direct HTTP calls?**

Choose RabbitMQ when:
- The receiver might be temporarily unavailable and you can't afford to lose the request.
- The task is long-running and you don't want the sender to wait (fire-and-forget).
- You need to distribute work across multiple workers (competing consumers).
- You want to decouple services so they can scale and deploy independently.

Use direct HTTP calls when you need an immediate response, the operation is simple and synchronous, or the overhead of a broker isn't justified.
