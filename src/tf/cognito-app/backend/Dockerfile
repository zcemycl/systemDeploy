FROM python:3.11.3-bullseye AS builder
RUN pip install poetry==1.8.2

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app
COPY pyproject.toml poetry.lock ./
COPY src ./src
RUN touch README.md

RUN poetry install --without dev && rm -rf $POETRY_CACHE_DIR

FROM python:3.11-slim-buster AS runtime
ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
WORKDIR /app
COPY --from=builder /app/src ./src
COPY app ./app
# COPY alembic.ini ./alembic.ini
# COPY alembic ./alembic

EXPOSE 80
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
