ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}

MAINTAINER Semyon Dubrovin <seven45@mail.ru>

ENV PDM_CHECK_UPDATE=false
RUN python -m pip install pdm

CMD ["pdm"]
