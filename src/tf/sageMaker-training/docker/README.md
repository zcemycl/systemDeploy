```mermaid
flowchart LR;
    A[container image] -->|push to| B[ecr];
    C[notebook] & F[lambda] -->|use| D[Sagemaker SDK];
    B -->|pull to| D;
    D -->|create| E[Sagemaker training job];
```
