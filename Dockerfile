FROM debian:buster AS builder

ENV DEV_ENV=/dev_environment

RUN echo "Installing required packages" && \
    apt-get update && \
    apt-get install -y \
        python3-dev \
        python3-pip \
        python3-virtualenv \
        python3-venv \
        virtualenv \
        npm \
        nodejs \
        libpq-dev && \
    pip3 install --upgrade pip && \
    mkdir -p /workspace && \
    mkdir -p ${DEV_ENV} && \
    echo "Add user" && \
    useradd -ms /bin/bash user && \
    chown -R user /workspace && \
    chown -R user ${DEV_ENV}

COPY --chown=user opensaas /workspace/

WORKDIR /workspace

USER user

RUN virtualenv -p python3 ${DEV_ENV} && \
    . ${DEV_ENV}/bin/activate && \
    pip3 install -r requirements.txt && \
    npm install && \
    npm run dev


FROM debian:buster

EXPOSE 5000

RUN echo "Installing required packages" && \
    apt-get update && \
    apt-get install -y \
        npm \
        virtualenv \
        libpq-dev \
        libexpat1 && \
    mkdir -p /workspace && \
    echo "Add user" && \
    useradd -ms /bin/bash user && \
    chown -R user /workspace

WORKDIR /workspace

VOLUME /workspace

COPY --chown=user entrypoint.sh /

COPY --chown=user --from=builder /dev_environment /dev_environment

COPY --chown=user --from=builder /workspace/node_modules /node_modules

USER user

ENTRYPOINT [ "bash", "-c" ]

CMD [ ". /entrypoint.sh" ]