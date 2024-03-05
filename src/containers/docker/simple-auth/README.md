## Initialisation
```
pyenv shell 3.11.3
~/.pyenv/versions/3.11.3/bin/pip install poetry
~/.pyenv/versions/3.11.3/bin/poetry init
~/.pyenv/versions/3.11.3/bin/poetry install
touch README.md
mkdir -p src/simple_auth
touch src/simple_auth/__init__.py
mkdir tests
```

## Onboarding
```
pyenv shell 3.11.3
~/.pyenv/versions/3.11.3/bin/pip install poetry
~/.pyenv/versions/3.11.3/bin/poetry install
~/.pyenv/versions/3.11.3/bin/poetry run uvicorn app.main:app --reload
# docker
docker build -t test-simple-auth .
docker run -p 3000:80 test-simple-auth
```
