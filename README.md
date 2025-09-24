## Python Environment Setup

Follow the steps below to create and activate a virtual environment for Python.

---

## Windows (PowerShell)

### Create virtual environment in folder 'env'
```powershell
python -m venv env
```

### Automatically set the environment
```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Activate the virtual environment
```powershell
.\env\Scripts\Activate.ps1
```
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force; & .\env\Scripts\Activate.ps1
```

### Packages

```powershell
pip install aiohappyeyeballs aiohttp aiosignal alembic annotated-types anyio attrs cachetools certifi charset-normalizer circuitbreaker click colorama distlib fastapi filelock frozenlist google-api-core google-auth google-cloud-core google-cloud-spanner googleapis-common-protos greenlet grpc-google-iam-v1 grpc-interceptor grpcio grpcio-status h11 httpcore httpx idna inflection iniconfig Jinja2 Mako MarkupSafe multidict mypy_extensions packaging pipenv platformdirs pluggy propcache proto-plus protobuf pyasn1 pyasn1_modules pydantic pydantic_core Pygments pytest pytest-asyncio python-dotenv requests rsa setuptools sniffio SQLAlchemy sqlalchemy-spanner sqlparse starlette tenacity typing_extensions typing-inspect typing-inspection urllib3 uvicorn virtualenv xmltodict yarl requests
```
