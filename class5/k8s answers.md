
# K8s (Kubernetes) - 2

## 🧩 Part 1 – Namespace (Logical Separation)
 ### Explain:
 #### 1. What a namespace is
Used for isolating groups of resources within a single cluster
Functioning as "virtual clusters" within the physical cluster. They are necessary for organization, security, and management, especially in multi-user or multi-team environments.
 -   **Resource Name Scoping**: Resource names must be unique within a namespace, but not across namespaces. This prevents naming conflicts, allowing different teams to use the same common resource names (e.g., a "database" service) without issues.
 -   **Isolation of Environments**: Namespaces are used to logically separate different stages of the application lifecycle (e.g.,  `development`,  `staging`, and  `production`) within the same physical cluster. This ensures that changes in one environment do not affect others.
 -   **Access Control (RBAC)**: Namespaces enable  Role-Based Access Control (RBAC). Administrators can define specific roles and permissions for users or teams at the namespace level, ensuring that users only have access to the resources they need for their jobs.
 -   **Resource Management and Quotas**: You can set resource quotas (limits on CPU, memory, and storage consumption) on a per-namespace basis. This prevents any single team or application from over spending cluster resources and ensures fair distribution.
 -   **Performance and Organization**: By organizing resources into smaller, logical groups, the Kubernetes API has fewer items to search through when performing operations, which can improve performance in large clusters.
 -   **Network Policies**: Network policies can be applied at the namespace level to control the flow of network traffic between pods, enhancing security by limiting potential lateral movement of threats.
#### 2. Why it is considered logical (not physical) separation
A namespace is considered a  **logical** separation because it is an administrative boundary managed by the software (the Kubernetes API), rather than a physical one enforced by hardware or infrastructure
It uses same resources as the other namespaces in the cluster.
`kubectl get namespaces`
```
NAME                   STATUS   AGE
backend                Active   12d
default                Active   12d
dev                    Active   107s
kube-node-lease        Active   12d
kube-public            Active   12d
kube-system            Active   12d
kubernetes-dashboard   Active   12d
```
## 🧩 Part 2 – Pod (Ephemeral Workload)
#### What happens if you delete this Pod? Who recreates it?
`pod/demo-pod created`
```
kubectl get pods -n dev
NAME       READY   STATUS    RESTARTS   AGE
demo-pod   1/1     Running   0          18s
```
`kubectl delete pod demo-pod -n dev`
```
kubectl get pods -n dev
No resources found in dev namespace.
```

It will not be rebirth , Since it is **not** managed through a controller: Deployment/ReplicaSet.
It will be created if you run the YAML again.
## 🧩 Part 3 – Deployment (Desired State)
```
kubectl apply -f deployment.yaml
deployment.apps/app-deployment created
```
```
kubectl get deployments,rs,pods -n dev
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app-deployment   3/3     3            3           12s

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/app-deployment-5d879fb8d9   3         3         3       12s

NAME                                  READY   STATUS    RESTARTS   AGE
pod/app-deployment-5d879fb8d9-6c9tb   1/1     Running   0          12s
pod/app-deployment-5d879fb8d9-tb7kt   1/1     Running   0          12s
pod/app-deployment-5d879fb8d9-wxpkr   1/1     Running   0          12s
pod/demo-pod                          1/1     Running   0          2m46s
```
#### Which object ensures the number of Pods?
spec:
replicas: 3 (ensures there will be 3 copies of the pod)
#### Why should Pods not be managed directly?
 - **Self-Healing** The Controller notices the Pod is gone and immediately schedules a new one on a healthy Node.
 - **Automated Scaling** You simply change the `replicas` count.
 - **Downtime During Updates** A Deployment performs a **Rolling Update**. It starts a new Pod, waits for it to be "Ready," and only then terminates the old one. Zero downtime.
 - **Easy Rollbacks** You can run revert to previous stable state.
 - **Service Discovery** Pods are  **ephemeral**  (temporary). Every time a Pod restarts, it gets a new IP address. Controllers work with  **Services**  to ensure that even if Pods are replaced, the load balancer always knows where to send traffic.
## 🧩 Part 4 – Deployment → ReplicaSet → Pod Relationship
`kubectl scale deployment app-deployment --replicas=5 -n dev`
```
kubectl get deployments -n dev
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
app-deployment   5/5     5            5           15m 
```
`kubectl set image deployment/app-deployment app=nginx:latest -n dev`
```
kubectl get rs -n dev
NAME                        DESIRED   CURRENT   READY   AGE
app-deployment-5d879fb8d9   0         0         0       24m
app-deployment-77cf88dc74   5         5         5       3m54s
```
#### How many ReplicaSets exist after the update?
2 ReplicaSets now exist.
#### Why does Kubernetes create a new ReplicaSet?
Kubernetes creates a new  **ReplicaSet**  during a Deployment update  to manage the  **Rolling Update**  process safely and enable  **Rollbacks**.
 - **Rolling Update Mechanism**
 A Deployment doesn't just "swap" images. It orchestrates a transition:

	-   The  **Old ReplicaSet**  is instructed to scale down (e.g., from 3 to 2 pods).
	-   The  **New ReplicaSet**  is instructed to scale up (e.g., from 0 to 1 pod).
	-   This continues until the new one is at full capacity and the old one is at zero. Having two separate ReplicaSets allows Kubernetes to track exactly how many "new version" and "old version" pods are running at any given second.
 - **History and Rollbacks** Kubernetes keeps the old, scaled-down ReplicaSets in the system (by default, the last 10).

 - **Immutable Infrastructure** a ReplicaSet is considered **immutable**. Instead of trying to "patch" the existing ReplicaSet, Kubernetes creates a clean new one to reflect the new desired state.
 - **Traffic Management** By using two ReplicaSets, the **Service** (load balancer) can seamlessly send traffic to both old and new pods simultaneously during the transition. Once the new ReplicaSet is fully ready, all traffic naturally flows to the new pods.
## 🧩 Part 5 – Service Types
`ClusterIP, NodePort, LoadBalancer`
#### Which Service is internal only?
ClusterIP - Accessible **only inside** the cluster. It provides a stable IP for pods to talk to each other

#### Which Service is best for production?
LoadBalancer 
 - This is the best way to expose a single service directly to the internet.
 - It provides a single, stable **Public IP** or DNS name provided by your cloud provider (AWS, GCP, Azure).
 - Easy to set up; cloud-integrated.
 
 ## 🧩 Part 6 – Ingress (HTTP Routing)
 ```
kubectl apply -f ingress.yaml
ingress.networking.k8s.io/app-ingress created
```
 #### Does Ingress work without an Ingress Controller?
 No, an Ingress  **does not work**  without an Ingress Controller.
In Kubernetes, there is a strict separation between the "plan" and the "worker".
**if you deploy an Ingress without a Controller**
 -   **Dormant Rules:**  The Ingress resource will be accepted by the API server and sit in your cluster, but it will remain dormant.
- **No Entry Point:**  No external IP will be assigned to the Ingress (the  `ADDRESS`  field in  `kubectl get ingress`  will stay empty).
- **No Routing:**  No traffic will ever reach your services through that Ingress.
#### Why not expose every Service directly?
While you technically can expose every Service directly using the `LoadBalancer` type, it is considered poor practice for several critical reasons::
1. **High Infrastructure Costs**: Ingress can use one LoadBalancer for multiple services instead of multiple LoadBalancers. Each `LoadBalancer` service typically provisions a dedicated, billable cloud resource.
2. **Management Complexity**: Exposing everything directly leaves you with a "messy" architecture
	-   **DNS Fatigue:**  Every service gets its own unique external IP address. You would have to manually create and manage separate DNS records for every single microservice.
	-   **Lack of Routing:**  Standard Load Balancers operate at  **Layer 4**  (TCP/UDP). They cannot handle "smart" routing.

3. **Increased Attack Surface (Security)**

	Direct exposure increases your risk profile significantly:

-   **Wider Doorway:**  Every public IP is a potential entry point for attackers.
-   **Decentralized Security:**  Applying security policies (like Web Application Firewalls (WAF), IP whitelisting, or rate limiting) becomes a nightmare because you have to configure them individually for every service.
-   **No Centralized SSL:**  With direct exposure, you often have to manage SSL/TLS certificates for each service individually rather than terminating them at a single, centralized gateway.

4. **Limited Features**

	Most cloud load balancers are "dumb" pipes. By using an  **Ingress Controller**  (like NGINX or Traefik), you gain advanced production features that standard  `LoadBalancer`  services don't offer out of the box:

-   **URL Rewriting:**  Changing paths before they hit your app.
-   **Canary Deployments:**  Sending 5% of traffic to a new version to test it.
-   **Virtual Hosting:**  Running multiple domains on a single IP.
## 🧩 Part 7 – ConfigMap & Secret
```
kubectl apply -f configmap.yaml
configmap/app-config created

kubectl apply -f secret.yaml
secret/app-secret created
```
#### Why separate config from images?
1. **Reusability (The "Golden Image")**
	If you bake your config (like a database URL) into the image, you have to build a  **new image**  for every environment.
-   **Bad way:**  `my-app:dev`,  `my-app:staging`,  `my-app:prod`.
-   **K8s way:**  One single image (`my-app:v1.0`) that behaves differently based on the  **ConfigMap**  or  **Secret**  injected into it.

2. **Security**
	Images are often stored in  **Registries**  (like Docker Hub or ECR). If you bake passwords, API keys, or certificates into the image:
-   Anyone with pull access can see your secrets.
-   The secrets are stored in the image history layers forever.  
    By separating them, you use Kubernetes  **Secrets**, which are stored encrypted and only mounted into the Pod at runtime.
3. **Agility and Speed**
	Changing a configuration should be a fast operation.
-   **Hardcoded:**  Change code → Commit → CI/CD Build (5-10 mins) → Push → Deploy.
-   **Separated:**  Update ConfigMap → Restart Pod (seconds). You don't need to rebuild the entire application just to change a log level or a timeout value.
4. **Compliance and "Secret Sprawl"**
	In large organizations, developers often build the images, but only the  **DevOps/SRE**  team knows the production credentials. Separating config allows for "Separation of Duties"—the image contains the logic, while the environment provides the sensitive data.
5. **Immutability**
	Container images should be  **immutable artifacts**. Once a version (e.g.,  `v1.2.3`) is tested and verified in Staging, you want the exact same bytes to run in Production. If you have to rebuild the image to change a config, you are technically running a "new" unverified artifact.
#### Why should Secrets be protected with RBAC?
In Kubernetes, **Secrets**  are the "crown jewels" of your cluster, containing sensitive data like database passwords, API keys, and TLS certificates.  Because these objects are only  **Base64-encoded**  by default (not encrypted), anyone who can "get" or "list" them can instantly read their plain-text values.

Protecting Secrets with  **Role-Based Access Control (RBAC)**  is critical for the following reasons:
1. **Enforcing the Principle of Least Privilege**
	RBAC allows you to grant the absolute minimum access required for a user or service to function.
-   **The Risk:**  Without RBAC, any compromised pod or user could potentially access every secret in a namespace, leading to a cluster-wide takeover.
-   **The Protection:**  You can define a  **Role**  that only allows a specific application to  `get`  one specific Secret by name, rather than  `list`  all secrets in the entire namespace.
2. **Reducing the "Blast Radius" of a Breach**
	If an attacker steals a user's credentials or compromises a container, RBAC limits what they can do.
-   **Prevention of Lateral Movement:**  Strict RBAC prevents attackers from moving from a non-critical application to sensitive infrastructure secrets (like cloud provider keys).

3. **Preventing Privilege Escalation**
	Unauthorized access to Secrets is a primary method for  **privilege escalation**.
-   **Service Account Tokens:**  Pods use special secrets called  `service-account-tokens` to talk to the  Kubernetes API. If an attacker can read a token with high privileges (like  `cluster-admin`), they can effectively control the entire cluster.

4. **Compliance and Auditing**
	Many regulatory standards (like  **GDPR, HIPAA, and PCI DSS**) mandate strict control over who can access sensitive data.
-   **Audit Trails:**  RBAC works with Kubernetes audit logs to provide a clear record of exactly who accessed which Secret and when.

5. **Separation of Duties**
	RBAC ensures that different teams (e.g., Developers vs. DevOps) have access only to what they need. For example, a developer might need to deploy code but should not be able to view production database passwords.
## Part 8 – RBAC & Namespace Isolation
```
kubectl apply -f configmap.yaml
configmap/app-config created

kubectl apply -f secret.yaml
secret/app-secret created

kubectl apply -f serviceaccount.yaml
serviceaccount/app-sa created
```
`kubectl auth can-i get pods --as=system:serviceaccount:dev:app-sa -n dev`
`yes`
#### Why is RBAC namespace-scoped?
In Kubernetes, RBAC is designed with  **Namespace-scoping**  to enforce  **security isolation**  and  **organizational structure**.
1. **Multi-Tenancy (The "Neighbor" Problem)**

	In a shared cluster, you might have  **Team A**  in  `namespace-a`  and  **Team B**  in  `namespace-b`.

-   **The Goal:**  Team A should be able to restart their own Pods but should never be able to see or delete Team B’s secrets.
-   **The Mechanism:**  By scoping a  **RoleBinding**  to a specific namespace, you ensure that even if a developer has "Admin" rights, those rights stop at the namespace boundary.

2. **Reduced "Blast Radius"**
	If a specific application is compromised (e.g., a hacker gains access to a Pod's ServiceAccount):

-   **If RBAC were global:**  The hacker could potentially access resources across the entire cluster.
-   **Because RBAC is scoped:**  The hacker is trapped within that single namespace. They cannot "jump" to other namespaces to steal production data.

3. **Simplified Delegation**
Namespace-scoped RBAC allows  **Cluster Admins**  to delegate power without giving up full control:

-   A manager can be an "Admin" of the  `dev`  namespace (allowing them to manage their team's resources) without needing any permissions on the  **Nodes**  or  **System**  components.
#### What security principle does RBAC enforce?
RBAC primarily enforces  the  **Principle of Least Privilege** **(PoLP)**.

1. **Principle of Least Privilege (PoLP)**

	This is the practice of granting a user, program, or process  **only the minimum permissions**  necessary to perform its specific task—and nothing more.

-   **How it looks in K8s:**  Instead of giving a developer "admin" access, you give them a Role that only allows  `get`,  `list`, and  `watch`  on Pods in the  `dev`  namespace.

2. **Separation of Duties**
RBAC ensures that critical tasks are divided among different people or service accounts.
-   **Example:**  The person who  **deploys**  the app (the CI/CD service account) shouldn't necessarily be the same person who can  **read**  the production database secrets.

3. **Need-to-Know**
By using namespace-scoping, RBAC ensures that users can only see resources they are authorized to interact with. If you don't have permissions in the  `finance`  namespace, those resources effectively "don't exist" for you.

4. **Defense in Depth**
RBAC acts as a layer of security. Even if a container is compromised, the  **Service Account**  attached to it limits what the attacker can do. If the RBAC is tight, the attacker is "stuck" inside a box with very few tools.
## 🧩 Part 9 – Production Thinking
```
resources:
	limits:
		cpu: "500m"
		memory: "256Mi"
replicas: 3
strategy:
	type: RollingUpdate
```
#### What changes between dev and prod? 
for given example: CPU, memory and number of replicas.
in Dev you may need only one replica and less memory and CPU.
In Production the values for all 3 might be bigger for availability and scalability.
#### Why are limits mandatory in production?
In production, limits are mandatory to prevent a single malfunctioning or greedy container from causing a  **cluster-wide meltdown**.

Think of limits as the "enforced walls" between your applications.
1. **Preventing "Noisy Neighbors"**
Without limits, a Pod with a memory leak or an infinite CPU loop will consume  **all**  available resources on its Node.

-   **Result:**  Other critical Pods on the same Node (like your database or API) will be starved of resources and crash. Limits ensure that one "noisy neighbor" stays in its box.

2. **Ensuring Predictability**
Kubernetes uses  **Limits**  to manage the lifecycle of containers:

-   **CPU:**  If a Pod hits its CPU limit, Kubernetes  **throttles**  it (slows it down) but doesn't kill it.
-   **Memory:**  If a Pod hits its memory limit, Kubernetes  **kills it immediately (OOMKilled)**.  
    In production, it is better for one specific Pod to restart (due to a memory limit) than for the entire physical server to freeze and crash because it ran out of RAM.

3. **Stability of the Control Plane**
	If your applications consume 100% of a Node's resources, the  **Kubelet**  (the K8s agent on the node) might not have enough CPU/RAM to "check in" with the Master.

-   **Result:**  The Control Plane will think the Node is dead (NotReady) and start moving hundreds of Pods to other Nodes, potentially creating a  **domino effect**  that crashes the entire cluster.
4. **Cost Control and Autoscaling**
If you use **Cluster Autoscaler**, it needs to know when to add new servers. If your Pods have no limits, they will eat up all resources, making the Autoscaler think it needs to buy more servers from AWS/GCP, leading to massive, unnecessary bills

