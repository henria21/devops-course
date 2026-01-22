# K8s (Kubernetes)

# Part 1 – Setup Minikube
 ## Task 1: Install Tools
**📌 Deliverable:**

**kubectl version --client**
Client Version: v1.34.1
Kustomize Version: v5.7.1

**minikube version**
minikube version: v1.37.0
commit: 65318f4cfff9c12cc87ec9eb8f4cdd57b25047f3

 # 🚀 Part 2 – Start & Explore the Cluster
## Task 2: Start Minikube

**minikube start**
```
* minikube v1.37.0 on Microsoft Windows 11 Home 10.0.26100.7623 Build 26100.7623
* Using the docker driver based on existing profile
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.48 ...
* Restarting existing docker container for "minikube" ...
! Failing to connect to https://registry.k8s.io/ from both inside the minikube container and host machine
* To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
* Preparing Kubernetes v1.34.0 on Docker 28.4.0 ...
* Verifying Kubernetes components...
  - Using image docker.io/kubernetesui/dashboard:v2.7.0
  - Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Some dashboard features require the metrics-server addon. To enable all features please run:

        minikube addons enable metrics-server

* Enabled addons: storage-provisioner, default-storageclass, dashboard
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
## Task 3: Inspect the Cluster
**kubectl cluster-info**
```
Kubernetes control plane is running at https://127.0.0.1:61744
CoreDNS is running at https://127.0.0.1:61744/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```
**kubectl get nodes**
```
NAME       STATUS   ROLES           AGE     VERSION
minikube   Ready    control-plane   2d16h   v1.34.0
```
**kubectl get namespaces**
```
NAME                   STATUS   AGE
backend                Active   2d15h
default                Active   2d16h
kube-node-lease        Active   2d16h
kube-public            Active   2d16h
kube-system            Active   2d16h
kubernetes-dashboard   Active   2d16h
```
**kubectl get pods -n kube-system**
```
NAME                               READY   STATUS    RESTARTS      AGE
coredns-66bc5c9577-97lcc           1/1     Running   3 (15m ago)   2d16h
etcd-minikube                      1/1     Running   3 (15m ago)   2d16h
kube-apiserver-minikube            1/1     Running   3 (15m ago)   2d16h
kube-controller-manager-minikube   1/1     Running   3 (16m ago)   2d16h
kube-proxy-j64ct                   1/1     Running   3 (16m ago)   2d16h
kube-scheduler-minikube            1/1     Running   3 (16m ago)   2d16h
storage-provisioner                1/1     Running   8 (14m ago)   2d16h
```

#  🔍 Part 3 – Explore Services
## Task 4: View Running Services

**kubectl get services -A**
```
NAMESPACE              NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default                kubernetes                  ClusterIP   10.96.0.1        <none>        443/TCP                  2d16h
kube-system            kube-dns                    ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   2d16h
kubernetes-dashboard   dashboard-metrics-scraper   ClusterIP   10.97.70.20      <none>        8000/TCP                 2d16h
kubernetes-dashboard   kubernetes-dashboard        ClusterIP   10.111.225.224   <none>        80/TCP                   2d16h
```
**Short explanation:**
list of all Kubernetes Services across every namespace in the cluster
# 📦 Part 4 – Deploy the Applications
## Task 5: Apply the YAML Files
**kubectl apply -f .**
```
deployment.apps/backend created
service/backend created
deployment.apps/frontend created
service/frontend created
```
# 🔎 Part 5 – Verify Deployment
## Task 6: Verify Resources
**kubectl get deployments**
```
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
backend          1/1     1            1           2m29s
frontend         1/1     1            1           2m29s
hello-minikube   1/1     1            1           2d15h
```
**kubectl get pods **
** proof backend/frontend running **
```
NAME                             READY   STATUS    RESTARTS      AGE
backend-576ccdb8d-4zm9z          1/1     Running   0             3m25s
frontend-7b9bcbbfc4-nc679        1/1     Running   0             3m25s
hello-minikube-bbcb89c6c-ggzk6   1/1     Running   2 (34m ago)   2d15h
```
**kubectl get services**
```
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
backend      ClusterIP   10.109.32.167   <none>        80/TCP         4m41s
frontend     NodePort    10.110.217.55   <none>        80:32489/TCP   4m41s
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        2d16h
```
# 🌐 Part 6 – Access the Application
## Task 7: Open the Frontend in a Browser

**minikube service frontend**
```
┌───────────┬──────────┬─────────────┬───────────────────────────┐
│ NAMESPACE │   NAME   │ TARGET PORT │            URL            │
├───────────┼──────────┼─────────────┼───────────────────────────┤
│ default   │ frontend │ 80          │ http://192.168.49.2:32489 │
└───────────┴──────────┴─────────────┴───────────────────────────┘
* Starting tunnel for service frontend./┌───────────┬──────────┬─────────────┬────────────────────────┐
│ NAMESPACE │   NAME   │ TARGET PORT │          URL           │
├───────────┼──────────┼─────────────┼────────────────────────┤
│ default   │ frontend │             │ http://127.0.0.1:63077 │
└───────────┴──────────┴─────────────┴────────────────────────┘
* Starting tunnel for service frontend.
* Opening service default/frontend in default browser...
! Because you are using a Docker driver on windows, the terminal needs to be open to run it.
```
**Output frontend browser:**
**Welcome to nginx!**

If you see this page, the nginx web server is successfully installed and working. Further configuration is required.

For online documentation and support please refer to  [nginx.org](http://nginx.org/).  
Commercial support is available at  [nginx.com](http://nginx.com/).

_Thank you for using nginx._
# 📄 Part 7 – Inspect Resources
## Task 8: Describe and Logs
**kubectl describe deployment frontend**
```
Name:                   frontend
Namespace:              default
CreationTimestamp:      Thu, 22 Jan 2026 12:03:44 +0200
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=frontend
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=frontend
  Containers:
   frontend:
    Image:         nginx:alpine
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   frontend-7b9bcbbfc4 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  27m   deployment-controller  Scaled up replica set frontend-7b9bcbbfc4 from 0 to 1
```
**kubectl describe pod frontend-7b9bcbbfc4-nc679**
```
Name:             frontend-7b9bcbbfc4-nc679
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Thu, 22 Jan 2026 12:03:44 +0200
Labels:           app=frontend
                  pod-template-hash=7b9bcbbfc4
Annotations:      <none>
Status:           Running
IP:               10.244.0.20
IPs:
  IP:           10.244.0.20
Controlled By:  ReplicaSet/frontend-7b9bcbbfc4
Containers:
  frontend:
    Container ID:   docker://92261e77e0f5b714129024b9685357584eacf74347cf9d84c98f633b77058b6e
    Image:          nginx:alpine
    Image ID:       docker-pullable://nginx@sha256:b0f7830b6bfaa1258f45d94c240ab668ced1b3651c8a222aefe6683447c7bf55
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Thu, 22 Jan 2026 12:03:59 +0200
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ct5nn (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-ct5nn:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  29m   default-scheduler  Successfully assigned default/frontend-7b9bcbbfc4-nc679 to minikube
  Normal  Pulling    29m   kubelet            Pulling image "nginx:alpine"
  Normal  Pulled     29m   kubelet            Successfully pulled image "nginx:alpine" in 8.381s (16.61s including waiting). Image size: 61898857 bytes.
  Normal  Created    29m   kubelet            Created container: frontend
  Normal  Started    29m   kubelet            Started container frontend
```
**kubectl logs frontend-7b9bcbbfc4-nc679**
```
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/01/22 10:03:59 [notice] 1#1: using the "epoll" event method
2026/01/22 10:03:59 [notice] 1#1: nginx/1.29.4
2026/01/22 10:03:59 [notice] 1#1: built by gcc 15.2.0 (Alpine 15.2.0)
2026/01/22 10:03:59 [notice] 1#1: OS: Linux 6.6.87.2-microsoft-standard-WSL2
2026/01/22 10:03:59 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2026/01/22 10:03:59 [notice] 1#1: start worker processes
2026/01/22 10:03:59 [notice] 1#1: start worker process 30
2026/01/22 10:03:59 [notice] 1#1: start worker process 31
2026/01/22 10:03:59 [notice] 1#1: start worker process 32
2026/01/22 10:03:59 [notice] 1#1: start worker process 33
2026/01/22 10:03:59 [notice] 1#1: start worker process 34
2026/01/22 10:03:59 [notice] 1#1: start worker process 35
2026/01/22 10:03:59 [notice] 1#1: start worker process 36
2026/01/22 10:03:59 [notice] 1#1: start worker process 37
2026/01/22 10:03:59 [notice] 1#1: start worker process 38
2026/01/22 10:03:59 [notice] 1#1: start worker process 39
2026/01/22 10:03:59 [notice] 1#1: start worker process 40
2026/01/22 10:03:59 [notice] 1#1: start worker process 41
2026/01/22 10:03:59 [notice] 1#1: start worker process 42
2026/01/22 10:03:59 [notice] 1#1: start worker process 43
2026/01/22 10:03:59 [notice] 1#1: start worker process 44
2026/01/22 10:03:59 [notice] 1#1: start worker process 45
10.244.0.1 - - [22/Jan/2026:10:18:37 +0000] "GET / HTTP/1.1" 200 615 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36" "-"
2026/01/22 10:18:37 [error] 31#31: *1 open() "/usr/share/nginx/html/favicon.ico" failed (2: No such file or directory), client: 10.244.0.1, server: localhost, request: "GET /favicon.ico HTTP/1.1", host: "127.0.0.1:63077", referrer: "http://127.0.0.1:63077/"
10.244.0.1 - - [22/Jan/2026:10:18:37 +0000] "GET /favicon.ico HTTP/1.1" 404 555 "http://127.0.0.1:63077/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36" "-"
```
# 🧹 Part 8 – Undeploy the Applications
## Task 9: Remove All Resources
**kubectl delete -f .**
```
deployment.apps "backend" deleted from default namespace
service "backend" deleted from default namespace
deployment.apps "frontend" deleted from default namespace
service "frontend" deleted from default namespace
```
# ✅ Part 9 – Verify Cleanup
## Task 10: Confirm Everything Is Gon
**kubectl get pods**
```
NAME                             READY   STATUS    RESTARTS      AGE
hello-minikube-bbcb89c6c-ggzk6   1/1     Running   2 (69m ago)   2d16h
```
**kubectl get deployments**
```
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
hello-minikube   1/1     1            1           2d16h
```
