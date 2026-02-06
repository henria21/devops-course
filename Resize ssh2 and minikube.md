## Resize CPU and Memory for ssh2 and minikube:

If you are running minikube on 16 gb windows computer running docker thru wsl2
and you current usage is like this:

#### in powershell


`minikube ssh -- free -h`
               total        used        free      shared  buff/cache   available
```
Mem:           7.4Gi       1.2Gi       3.7Gi        13Mi       2.5Gi       6.1Gi
Swap:          2.0Gi          0B       2.0Gi
```

here you see used 7.4 gb memory in total but only used 1.2 gb from it

if you wish it do drop down the usage to be out of 4 gb than:

`wsl --shutdown`

create under C:\Users\<YourUsername> folder
a new file if missing(it was missing for me) :
**.wslconfig**

**Edit it and put:**
[wsl2]
memory=4GB
processors=2

`(where 4gb is what i set for it as well as 2 cores)`

### now we will set the minikube config:

#### delete current configuration of minikube and stopping it minikube delete
```
minikube config set memory 4096
minikube config set cpus 2

minikube start
```

**run:**
`minikube ssh -- free -h`

now it should be like this:
```
Mem:           3.8Gi       1.0Gi       850Mi        13Mi       2.0Gi       2.7Gi
Swap:          1.0Gi          0B       1.0Gi
```
