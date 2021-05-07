FROM python:3.5.10-slim-buster

RUN apt-get update && \
      apt-get install -y \
        curl \
        libgl1 \
        libglib2.0-0 \
        && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash user
USER user
ENV PATH $PATH:/home/user/.local/bin

WORKDIR /phormatics
COPY poetry.lock pyproject.toml ./
RUN pip install --upgrade --no-cache pip setuptools wheel && \
      pip install --no-cache poetry && \
      poetry install --no-dev --no-ansi --no-interaction
COPY ./ ./


WORKDIR /phormatics/server
CMD ["poetry", "run", "python", "app.py"]
