# pdm-ci
PDM base-image for ci usage

# Gitlab-ci usage:

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
  image: seven45/pdm-ci:3.9
  stage: test
  script:
    - pdm install -dG testing
    - pdm run pytest -s
```
