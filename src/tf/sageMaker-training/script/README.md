## Deployment Strategies

```mermaid
flowchart LR;
    A[script] -->|push to| B[s3];
    C[notebook] & F[lambda] -->|use| D[Sagemaker SDK];
    B -->|pull to| D;
    D -->|create| E[Sagemaker training job];
```

## How to run?
- Local
    ```
    python train.py --train ../data
    ```
- Sagemaker

## References
1. https://github.com/aws/amazon-sagemaker-examples/blob/main/sagemaker-python-sdk/tensorflow_script_mode_training_and_serving/mnist-2.py
2. https://github.com/aws/amazon-sagemaker-examples/blob/main/advanced_functionality/custom-training-containers/basic-training-container/notebook/basic_training_container.ipynb
3. https://sagemaker.readthedocs.io/en/stable/frameworks/tensorflow/using_tf.html#id1
