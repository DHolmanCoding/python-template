FROM ubuntu:24.04

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHON_VERSION=3.13 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBTYECODE=1 \
    PYENV_ROOT="/.pyenv" \
    PATH="/.pyenv/bin:/.pyenv/shims:${PATH}"

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

RUN git clone --depth=1 https://github.com/pyenv/pyenv.git /.pyenv && \
    pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION}

ADD pyproject.toml uv.lock ./
RUN pip install --no-cache-dir --upgrade pip && \
    pip install uv && \
    uv sync --no-dev

COPY python_template ./python-template

CMD ["/bin/bash"]
