FROM ubuntu:20.04

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        make \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        curl \
        llvm \
        libncurses5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHON_VERSION=3.8.5 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBTYECODE=1 \
    PYENV_ROOT="/.pyenv" \
    PATH="/.pyenv/bin:/.pyenv/shims:${PATH}"

RUN git clone --depth=1 https://github.com/pyenv/pyenv.git /.pyenv && \
    pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION}

ADD pyproject.toml poetry.lock ./
RUN pip install --no-cache-dir --upgrade pip && \
    pip install poetry && \
    poetry install --no-dev

COPY python-template ./python-template

ENTRYPOINT ["/bin/bash"]
