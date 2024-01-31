# FROM tensorflow/tensorflow:latest-gpu-jupyter
FROM tensorflow/tensorflow:latest-jupyter

# Install Amazon SageMaker training toolkit and smdebug libraries
RUN pip install sagemaker-training
RUN pip install smdebug

COPY train.py /opt/ml/code/train.py
ENV SAGEMAKER_PROGRAM train.py
