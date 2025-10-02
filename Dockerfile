# ====== builder ======
FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# deps do sistema mínimas
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip && pip wheel --no-deps --wheel-dir /wheels -r requirements.txt

# ====== final ======
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# criar usuário não-root (boa prática citada)
RUN adduser --disabled-password --no-create-home django-user

WORKDIR /app

# runtime libs mínimas
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# instalar via wheels do estágio builder
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/*

# copiar código
COPY . .

# preparar pastas de mídia/estáticos em /vol (conforme guia)
RUN mkdir -p /vol/web/media /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol

USER django-user

# o CMD ficará no docker-compose (boa prática do guia)
