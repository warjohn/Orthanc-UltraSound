FROM orthancteam/orthanc

# Установка необходимых утилит
RUN apt-get update && \
    apt-get install -y curl bzip2 wget

RUN wget https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/cuda-repo-debian12-12-8-local_12.8.1-570.124.06-1_amd64.deb && \
    dpkg -i cuda-repo-debian12-12-8-local_12.8.1-570.124.06-1_amd64.deb && \
    cp /var/cuda-repo-debian12-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get -y install cuda-toolkit-12-8

# Установка Miniconda
RUN curl -sS https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda init bash && \
    /opt/conda/bin/conda clean --all -y

# Добавление Miniconda в PATH
ENV PATH=/opt/conda/bin:$PATH

# Создание и активация конда-окружения
COPY ./src/Pipeline/environment.yml /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml && \
    conda clean --all -y

# Активация окружения и установка прав на выполнение скриптов
RUN echo "source activate orthanc-env" > ~/.bashrc
ENV PATH /opt/conda/envs/orthanc-env/bin:$PATH

# Установка модуля envsubst через pip
RUN /opt/conda/envs/orthanc-env/bin/pip install envsubst

# Копирование всех файлов проекта
COPY ./src/Pipeline /etc/orthanc/pipeline

# Установка прав на выполнение скриптов
RUN chmod +x /etc/orthanc/pipeline/*.py

# Настройка переменных окружения (если необходимо)
ENV PYTHONPATH=/etc/orthanc/pipeline