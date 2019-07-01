FROM alpine

RUN apk update

RUN apk add \
    gcc	\
    musl-dev \
    py2-pip \
    python \
    python-dev 

RUN pip install --upgrade pip

RUN pip install \
    RPi.GPIO \
    ipython \
    readchar

WORKDIR /root/blink

COPY src/* src/

CMD ["python", "src/blink2.py"]
