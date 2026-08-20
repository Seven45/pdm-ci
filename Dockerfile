ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION:-3.13-slim}

LABEL org.opencontainers.image.authors="seven45@mail.ru"

ENV PDM_CHECK_UPDATE=false
RUN python -m pip install --no-cache-dir --user pdm

RUN echo '#!/bin/bash\n python -m pdm "$@"' > /usr/bin/pdm && chmod +x /usr/bin/pdm
CMD ["pdm"]
