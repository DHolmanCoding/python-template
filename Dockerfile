# -----------------------------------------------------------------------------
# Fast path (default): prebuilt Python, no compile
# -----------------------------------------------------------------------------
FROM python:3.13-slim AS builder-fast

ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN pip install --no-cache-dir uv \
    && uv sync --no-dev --no-install-project

# -----------------------------------------------------------------------------
# Production path: PGO+LTO Python from source
# -----------------------------------------------------------------------------
FROM ubuntu:25.10 AS builder-prod

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

# Drop download tools and all build deps; keep only runtime libs for Python.
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
# Production runtime (--target runtime-prod)
# -----------------------------------------------------------------------------
FROM debian:bookworm-slim AS runtime-prod

ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates adduser \
    && rm -rf /var/lib/apt/lists/* /var/cache/debconf/* /var/lib/dpkg/*

RUN adduser --disabled-password --gecos "" appuser

COPY --from=builder-prod /.pyenv/versions /.pyenv/versions
# Trim: drop stdlib test/ and build config (static lib); keep bytecode
RUN PYDIR=/.pyenv/versions/$(ls /.pyenv/versions | head -1) \
    && rm -rf "$PYDIR/lib/python3.13/test" \
    && rm -rf "$PYDIR/lib/python3.13"/config-*
RUN ln -s /.pyenv/versions/$(ls /.pyenv/versions | head -1) /opt/python

COPY --from=builder-prod --chown=appuser:appuser /app /app
COPY --chown=appuser:appuser python_template /app/python_template

ENV PATH="/opt/python/bin:/app/.venv/bin:$PATH"
WORKDIR /app
USER appuser

CMD ["uv", "run", "python"]

# -----------------------------------------------------------------------------
# Fast runtime (default target)
# -----------------------------------------------------------------------------
FROM debian:bookworm-slim AS runtime-fast

ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates adduser \
    && rm -rf /var/lib/apt/lists/* /var/cache/debconf/* /var/lib/dpkg/*

RUN adduser --disabled-password --gecos "" appuser

COPY --from=builder-fast /usr/local /usr/local
COPY --from=builder-fast --chown=appuser:appuser /app /app
COPY --chown=appuser:appuser python_template /app/python_template

ENV PATH="/usr/local/bin:/app/.venv/bin:$PATH"
WORKDIR /app
USER appuser

CMD ["uv", "run", "python"]
