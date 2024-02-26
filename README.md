
# Python template
Python template


## Description
...

## Python setup
It's recommended to use pyenv as a Python version manager. See:
* https://github.com/pyenv/pyenv?tab=readme-ov-file#installation

Then install poetry:
```bash
# Set pyenv to 3.10
pyenv local 3.10 # pyenv install 3.10 if doesn't exist
# Install poetry if doesn't exist
curl -sSL https://install.python-poetry.org | python3 -
# Setup virtual env and python deps
make python-env
```
