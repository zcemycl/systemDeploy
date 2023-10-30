FROM jupyter/datascience-notebook

ENV JUPYTER_TOKEN="easy"
ENV PASSWORD="password"
ENV JUPYTER_ENABLE_LAB=yes

EXPOSE 8888
COPY requirements.txt ./
RUN pip install -U pip
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=${NB_UID}:${NB_GID} . /home/leo/work
WORKDIR /home/leo/work

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--notebook-dir=/home/leo/work", "--allow-root", "--user=root"]
