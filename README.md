# pdm-ci

[PDM](https://github.com/pdm-project/pdm) in docker [image](https://hub.docker.com/r/seven45/pdm-ci) (versioned like official python image)

Your project's structure:
- my_project/ (workdir)
  - `src/`
    - your files and folders here
    - `__init__.py`
    - `__main__.py`
  - `tests/`
  - `Dockerfile`
  - `pdm.lock`
  - `pyproject.toml`
  - `README.md`

## Python multistage build

`Dockerfile`:

```dockerfile
ARG PYTHON_VERSION=3.10

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

## Continuous Integration

`pyproject.toml`:

```toml
...

[tool.pdm.dev-dependencies]
testing = ["pytest-cov>=5.0.0"]
linting = [
    "ruff>=0.3.4",
]

[tool.pdm.scripts]
lint = {composite = ["ruff format src tests", "ruff check src tests --fix"]}
lint_check = {composite = ["ruff format src tests --check", "ruff check src tests"]}
test = "pytest -vvv -s tests"
test_cov = "pytest --cov-branch --cov-report=xml --cov=src tests"

...
```

`gitlab-ci.yaml`:

```yaml
stages:
  - lint
  - test

ruff:
  stage: lint
  image: seven45/pdm-ci:3.10-alpine
  only: [ "merge_requests" ]
  script:
    - pdm install --no-default -G linting
    - pdm run lint_check
  cache:
    paths: [ ".venv" ]
    key:
      prefix: venv_lint
      files: [ "pdm.lock" ]
 
 pytest:
  stage: test
  image: seven45/pdm-ci:3.10-slim
  only: [ "merge_requests" ]
  script:
    - pdm install -dG testing
    - pdm run test_cov
  coverage: '/(?i)total.*? (100(?:\.0+)?\%|[1-9]?\d(?:\.\d+)?\%)$/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
  cache:
    paths: [ ".venv" ]
    key:
      prefix: venv_test
      files: [ "pdm.lock" ]
```


## Pre-commit hooks

`pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: ruff
        name: ruff format and lint
        language: system
        types: [python]
        entry: pdm run lint_check
```


## Extended usage

Dynamic versioning:

Put your version into file `src/__version__.py` with content: 
```python
__version__ = "0.1.0"

```

Put into your `pyproject.toml` file lines:

```toml
[project]
...
dynamic = ["version"]

[tool.pdm]
build = {includes = ["src"]}
version = { source = "file", path = "src/__version__.py" }
...
```
