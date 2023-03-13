# System Deployments

## Tech stack
1. AWS + Terraform
    ```mermaid
    flowchart LR;
        subgraph A[VPC];
            subgraph AA[Public Subnet]
            end
            subgraph AB[Private Subnet]
                direction LR;
                subgraph ABA[Fargate]
                    direction TB;
                    ABA1[ECS]
                    ABA2[ECS]
                    ABA3[ECS]
                end
                ABB[NLB] --> ABA;
                ABC[APIGW] --> ABB;
            end
            AC[Internet Gateway] --> AA;
            AA --> AD[NAT];
            AD --> AB;
        end;
        B[ECR] --> AC;
        C[Cognito] --> AC;
    ```
2. Azure bicep
    ```mermaid
    flowchart LR;
        subgraph B[Azure Cloud]
            direction TB;
            B1[ACR];
            B2[Key Vault];
            subgraph BA[Container Apps]
                BA1[frontend] --> BA2[backend];
            end
            subgraph BB[Serverless]
                BB1[EventGrid] --> BB2[Function Apps];
                BB2 --> BB3[OCR];
            end
            subgraph BC[Storage]
                BC1[Blob]
                BC2[CosmosDB]
            end
            B1 --> BA;
            BA --> BC;
            BC --> BA;
            BC --> BB;
            BB --> BC;
            BB --> BA2;
        end
        subgraph A[Azure Devops]
            subgraph AA[Repository]
                subgraph AAA[CICD Pipeline]
                    AAA1[CI Testings]
                end
                AAA -->|package| AAB[Artefacts]
                
            end
        end
        A -->|docker image| B1;
        A -->|iac| B;
        BA2 -->|install package| A;
        C((User)) --> BA1;
    ```
3. Dockers + Helm + Kubernetes
    ```mermaid
    flowchart LR;
        subgraph AA[Node]
            direction LR;
            subgraph A[Deployment]
                A1[Pod];
                A2[Pod];
                A3[Pod];
            end
        end
        B[NodeIP] --> AA;
    ```
4. Google Cloud Platform
5. FastAPI + Prometheus + Grafana
    ```mermaid
    flowchart LR;
        A[FastAPI] -->|/metrics| B[Prometheus];
        B --> C[Grafana]
    ```
    ![fastapi-prometheus-grafana](docs/resources/grafana_fastapi_prometheus.png)

