# -----------------------------------------------------------------------------
# Stage 1: build production-optimized Python (PGO+LTO) and install deps
# -----------------------------------------------------------------------------
FROM ubuntu:25.10 AS builder

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHON_VERSION=3.13 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHON_CONFIGURE_OPTS="--enable-optimizations --with-lto" \
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

RUN git clone --depth=1 https://github.com/pyenv/pyenv.git /.pyenv \
    && pyenv install --verbose ${PYTHON_VERSION} \
    && pyenv global ${PYTHON_VERSION}

# Purge download tools and all build deps; keep only runtime libs for Python.
RUN apt-get update \
    && apt-get purge -y \
        curl wget \
        build-essential gcc g++ make git llvm \
        libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
        libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN pip install --no-cache-dir --upgrade pip \
    && pip install uv \
    && pyenv rehash \
    && uv sync --no-dev --no-install-project

# -----------------------------------------------------------------------------
# Stage 2: minimal runtime
# -----------------------------------------------------------------------------
FROM ubuntu:25.10-slim

ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Only ca-certificates for SSL; no build tools.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy built Python and symlink for a stable path.
COPY --from=builder /.pyenv/versions /.pyenv/versions
RUN ln -s /.pyenv/versions/$(ls /.pyenv/versions | head -1) /opt/python

# Copy app and venv from builder.
COPY --from=builder /app /app
COPY python_template /app/python_template

ENV PATH="/opt/python/bin:/app/.venv/bin:$PATH"

WORKDIR /app

RUN adduser --disabled-password --gecos "" appuser \
    && chown -R appuser:appuser /app
USER appuser

CMD ["uv", "run", "python"]
