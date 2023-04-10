# pdm-ci
[PDM](https://github.com/pdm-project/pdm) in docker [image](https://hub.docker.com/r/seven45/pdm-ci) (versioned like official python image)

Your project's structure:
- <my_project> (workdir)
  - `src`
  - `tests`
  - `Dockerfile`
  - `pdm.lock`
  - `pyproject.toml`
  - `README.md`

# Python multistage build

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

# Continuous Integration

`pyproject.toml`:

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
lint = {composite = ["black src tests", "isort src tests", "flake8p src tests"]}
lint_check = {composite = ["black src tests --check", "isort src tests --check-only", "flake8p src tests"]}
test = "pytest -vvv -s tests"
test_cov = "pytest --cov-branch --cov-report=xml --cov=src tests"
test_file = "pytest -s -vv ./{args}"
test_all = {composite = ["test", "lint_check"]}
...
```

`gitlab-ci.yaml`

```yaml
stages:
  - lint
  - test

linters:
  stage: lint
  image: seven45/pdm-ci:3.10-alpine
  script:
    - pdm install --no-default -G linting
    - pdm run lint
 
 pytest:
  image: seven45/pdm-ci:3.10-slim
  stage: test
  script:
    - pdm install -dG testing
    - pdm run test_cov
```
