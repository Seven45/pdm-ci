# pdm-ci
[PDM](https://github.com/pdm-project/pdm) in docker [image](https://hub.docker.com/r/seven45/pdm-ci) (versioned like official python image)

# Usage:

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
