# pdm-ci
[PDM](https://github.com/pdm-project/pdm) in docker [image](https://hub.docker.com/r/seven45/pdm-ci) (versioned like official python image)

# Python multistage build

```dockerfile
ARG PYTHON_VERSION=3.9

FROM seven45/pdm-ci:$PYTHON_VERSION as pdm
WORKDIR /project
COPY pyproject.toml pdm.lock /project/
RUN python -m venv --copies .venv
RUN pdm install --prod --no-self --no-lock --no-editable

FROM python:$PYTHON_VERSION
WORKDIR /project
COPY --from=pdm /project/.venv /project/.venv
ENV PATH="/project/.venv/bin:$PATH"
COPY src /project/src
CMD ["python", "src/__main__.py"]
```

# Continuous Integration

pyproject.toml
```toml
...
[tool.pdm.dev-dependencies]
testing = ["pytest>=1.5.0"]
linting = [
    "setuptools>=65.6.3",
    "black>=22.12.0",
    "isort>=5.11.4",
    "flake8-pyproject>=1.2.2"
]

[tool.pdm.scripts]
lint = {composite = ["black src", "isort src", "flake8 src"]}
...
```

gitlab-ci.yaml
```yaml
stages:
  - lint
  - test

linters:
  stage: lint
  image: seven45/pdm-ci:3.9-alpine
  script:
    - pdm install --no-default -G linting
    - pdm run lint
 
 unit-tests:
  image: seven45/pdm-ci:3.9-slim
  stage: test
  script:
    - pdm install -dG testing
    - pdm run pytest -s
```
