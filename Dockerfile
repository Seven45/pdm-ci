ARG TAG
FROM python:${TAG}

MAINTAINER Semyon Dubrovin <seven45@mail.ru>

RUN python -m pip install pdm
CMD ["pdm"]
