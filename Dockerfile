ENV PDM_CHECK_UPDATE=false
ARG PYTHON_VERSION

FROM python:${TAG}

MAINTAINER Semyon Dubrovin <seven45@mail.ru>

RUN python -m pip install pdm
CMD ["pdm"]
