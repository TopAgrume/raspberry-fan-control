# Stage 1: Build stage
FROM python:3.9-slim-buster AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-dev \
    swig \
    make \
    gcc \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install lgpio package
RUN mkdir -p /tmp \
    && git clone https://github.com/joan2937/lg /tmp/lg \
    && cd /tmp/lg \
    && git checkout 37b1afc59a8ddbce9b1f6e14a8f81f1995cd1dc0 \
    && make \
    && make install

# Stage 2: Final stage
FROM python:3.9-slim-buster

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /usr/local/lib/liblgpio.so* /usr/local/lib/
COPY --from=builder /usr/local/lib/python3.9/site-packages/lgpio* /usr/local/lib/python3.9/site-packages/

# Install runtime packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-libgpiod \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY fan_control.py /src/fan_control.py

RUN chmod +x /src/fan_control.py

CMD ["python3", "/src/fan_control.py"]