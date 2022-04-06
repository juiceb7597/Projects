EKS로 Airflow 배포하기
=============
---

![Alt text](./images/architecture.jpg)

---
<br/>

### 1. 아키텍쳐
   
   <br/>

   ![Alt text](./images/architecture.jpg)

   작성중이예요. 수정될 수 있어요!

   Flux로 EKS에 배포해요.

   ALB로 Airflow UI를 외부에 노출해요.

   Fluentbit로 로그를 Cloudwatch에 보내고 S3에 저장해요.

   Prometheus 지표를 Grafana로 모니터링해요. 


<br/>
<br/>
<br/>
<br/> 

###  2. EKS Cluster 만들기

   <br/>


   ```
   cluster.yaml

   apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: airflow
  region: ap-northeast-2
  version: "1.21"

managedNodeGroups:
  - name: airflow-ng
    instanceType: t3.medium
    privateNetworking: true
    minSize: 2
    maxSize: 4
    desiredCapacity: 2
    volumeSize: 20
    ssh:
      allow: true
      publicKeyName: YourClusterKeypair
    labels: { role: worker }
    tags:
      nodegroup-role: YourNodegroup
    iam:
      withAddonPolicies:
        ebs: true
        imageBuilder: true
        efs: true
        albIngress: true
        autoScaler: true
        cloudWatch: true
   ```
   
   ```
   eksctl create cluster -f cluster.yaml
   eksctl utils associate-iam-oidc-provider --cluster airflow --approve
   ```
   
   노드그룹과 함께 EKS 클러스터를 만들어요.
   
   오토스케일링과 ALB Ingress 권한도 추가해요.

   추가로 클러스터에 oidc 자격 증명 공급자를 생성해요.
  
<br/>
<br/>
<br/>
<br/> 

###  3. Cluster Autoscaler 설정
   
   <br/>
   
   ```
   https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/autoscaling.html

   curl -o cluster-autoscaler-autodiscover.yaml https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
YourClusterName
kubectl apply -f cluster-autoscaler-autodiscover.yaml
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false" 
kubectl -n kube-system edit deployment.apps/cluster-autoscaler
--balance-similar-node-groups
--skip-nodes-with-system-pods=false
kubectl set image deployment cluster-autoscaler -n kube-system cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.2
  ```
  
Pod 수에 따라 노드가 추가되게끔 오토스케일러를 설정해요.

<br/>
<br/>
<br/>
<br/> 

###  4. Flux 배포
   
   <br/>
   
```
flux check --pre
flux bootstrap github \
  --owner=yourGithubUsername \
  --repository=yourGithubRepo \
  --path=example/cluster \
  --personal
```

flux check로 실행해도 되는지 확인해요.

클러스터에 flux를 배포해요.

<br/>
<br/>
<br/>
<br/> 

###  5. Prometheus, Grafana 연동
   
   <br/>

   ```
prometheus/helm-release-prometheus.yaml

  apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: prometheus
  namespace: prometheus
spec:
  chart:
    spec:
      chart: prometheus
      sourceRef:
        kind: HelmRepository
        name: prometheus-community
      version: 15.8.0
  interval: 5m0s
   ```

  ```
  kubectl --namespace=prometheus port-forward deploy/prometheus-server 9090
  ```

   Prometheus UI에서 Targets로 지표를 확인해요.

   ![Alt text](./images/prometheus.jpg)   

   ---
<br/>

   ```
   grafana/helm-release-grafana.yaml

apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: grafana
  namespace: grafana
spec:
  chart:
    spec:
      chart: grafana
      sourceRef:
        kind: HelmRepository
        name: grafana
      version: 6.25.1
  interval: 5m0s
   ```


   ```
kubectl port-forward service/grafana 3000:80 -n grafana

configuration - datasources - prometheus - url service/prometheus-server_cluster-IP:port - save & test
create - import - 13770 load
   ```

 Grafana UI에서 데이터소스로 Prometheus를 설정해요.

   원하는 대쉬보드로 클러스터를 모니터링해요.

   ![Alt text](./images/grafana.jpg)   

<br/>
<br/>
<br/>
<br/> 

###  6. Airflow 배포
   
   <br/>

   ```
   helm install airflow apache-airflow/airflow --version 1.5.0 \
   --namespace airflow --create-namespace --values ./values.yaml
   kubectl port-forward service/airflow-webserver 8080 -n airflow
   ```

   ```
   values.yaml

   fernetKey: "mWKHnpIaV5zRMDshi6VFmtkJf5w5bVSx5GH_Ds8rYoA="
env:
  - name: "AIRFLOW__KUBERNETES__DAGS_IN_IMAGE"
    value: "True"
  - name: "AIRFLOW__KUBERNETES__NAMESPACE"
    value: "airflow"
  - name: "AIRFLOW__KUBERNETES__WORKER_CONTAINER_REPOSITORY"
    value: "apache/airflow"
  - name: "AIRFLOW__KUBERNETES__WORKER_CONTAINER_TAG"
    value: "1.10.10.1-alpha2-python3.7"
  - name: "AIRFLOW__KUBERNETES__RUN_AS_USER"
    value: "50000"
  - name: "AIRFLOW__CORE__LOAD_EXAMPLES"
    value: "False"
  - name: "AIRFLOW__CORE__REMOTE_LOGGING"
    value: "True"
  - name: "AIRFLOW__CORE__REMOTE_LOG_CONN_ID"
    value: "MyS3Conn"
  - name: "AIRFLOW__CORE__REMOTE_BASE_LOG_FOLDER"
    value: "s3://bucketName/logs"
  - name: "AIRFLOW__CORE__EXPOSE_CONFIG"
    value: "True"
executor: "KubernetesExecutor"
dags:
  persistence:
    enabled: false
  gitSync:
    enabled: true
    repo: ssh://git@github.com/username/repo.git
    branch: main
    subPath: ""
    wait: 60
    sshKeySecret: airflow-ssh-secret
extraSecrets:
  airflow-ssh-secret:
    data: |
      gitSshKey: LS0tLS~~
   ```

  helm으로 values 환경설정 값과 함께 배포해요.

  giysync로 dag를 github repo에서 가져와요.

  dag로그를 S3 버킷에 저장해요.

  Connection으로 MyS3Conn을 만들어 줘요.

  <br/>
<br/>
<br/>
<br/> 

###  7. Ingress로 Airflow UI 노출
   
   <br/>

  ```
    kubectl edit svc airflow-webserver -n airflow
    ClusterIP -> NodePort
    kubectl apply -f ingress.yaml -n airflow
  ```

  ```
  ingress.yaml

  apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: airflow
  name: airflow-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/success-codes: 200,302
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: airflow-webserver
              port:
                number: 8080
  ```

  airflow-webserver 서비스 타입을 ClusterIP에서 NodePort로 변경해요.

  ingress를 배포해서 로드밸런서를 생성해요.

  로드밸런서 DNS로 접속해서 UI를 확인해요

  ![Alt text](./images/airflowUI-alb.jpg)  


###  8. AWS RDS 연결
   
   <br/>

   ```
   postgresql:
  enabled: false
data:
  metadataConnection:
    user: RDSUsername
    pass: RDSPassword
    host: RDSEndpoint
    port: 5432
    db : ~
   ```

   ```
   helm upgrade -f values.yaml airflow apache-airflow/airflow -n airflow
   airflow create_user -r Admin -u admin -e admin@admin.com -f admin -l admin -p admin
   ```

   RDS를 생성한 뒤 values파일에 값을 추가해요.

   데이터베이스가 바뀌었으므로 airflow webserver 컨테이너에서 admin 계정을 생성해요.

   RDS는 EKS와 같은 VPC, Security Group을 사용해요.


<br/>
<br/>
<br/>
<br/> 

###  8. AWS RDS 연결
   
   <br/>

  작성중이예요.

  <br/>
<br/>
<br/>
<br/> 



참고 강의

https://www.udemy.com/course/rocking-kubernetes-with-amazon-eks-fargate-and-devops/

https://www.udemy.com/course/apache-airflow-on-aws-eks-the-hands-on-guide/

그 외 공식 Documentation


---

### 선택사항

<br/>
<br/>

1. NetworkPolicyProvider(agent) - calion

```
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/calico.html

helm repo add projectcalico https://docs.projectcalico.org/charts
helm install calico projectcalico/tigera-operator --version v3.21.4
kubectl get all -n tigera-operator
kubectl port-forward service/management-ui -n management-ui 9001
```

포드간 연결을 제어할 경우 NetworkPolicyProvider를 배포해요.

  <br/>

  2. kubecost

```
https://www.kubecost.com/install#show-instructions

kubectl create namespace kubecost
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken="ZHNhZGFzZGFkc0Bhc2RzZGE=xm343yadf98"
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

비용을 관리하고 싶을 때 kubecost를 배포해요.

![Alt text](./images/kubecost_dashboard.jpg)

  <br/>

3. Argo

```
https://argo-cd.readthedocs.io/en/stable/getting_started/

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
choco install argocd-cli
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
ID=admin, Password=decoded~~
newApp-project:defalt-RepogitoryURL:githubRepo-path:./-ClusterURL=https://kubernetes.default.svc-Namespace:default
Sync
```

Flux대신 Argo를 사용할 때 배포해요.

![Alt text](./images/argo.jpg)



