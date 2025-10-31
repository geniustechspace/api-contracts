# Auth Client

Generated Python gRPC client for the Auth Service.

## Installation

```bash
pip install auth-client
```

## Usage

```python
import grpc
from auth_client.auth.v1 import auth_pb2, auth_pb2_grpc

# Create a channel
channel = grpc.insecure_channel('localhost:50051')
stub = auth_pb2_grpc.AuthServiceStub(channel)

# Register a new user
request = auth_pb2.RegisterRequest(
    email='user@example.com',
    password='secure_password',
    full_name='John Doe'
)

response = stub.Register(request)
print(f"User registered: {response.user_id}")
print(f"Access token: {response.access_token}")

# Login
login_request = auth_pb2.LoginRequest(
    email='user@example.com',
    password='secure_password'
)

login_response = stub.Login(login_request)
print(f"Logged in: {login_response.user_id}")
```

## Development

Generate proto files:

```bash
cd ../../scripts
./generate_python.sh auth
```

Install in development mode:

```bash
pip install -e ".[dev]"
```

## License

MIT
