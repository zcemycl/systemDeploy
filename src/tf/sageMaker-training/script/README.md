```mermaid
flowchart LR;
    A[script] -->|push to| B[s3];
    C[notebook] & F[lambda] -->|use| D[Sagemaker SDK];
    B -->|pull to| D;
    D -->|create| E[Sagemaker training job];
```
