# Accounts Client

Generated Python gRPC client for the Accounts Service.

## Installation

```bash
pip install accounts-client
```

## Usage

```python
import grpc
from accounts_client.accounts.v1 import accounts_pb2, accounts_pb2_grpc

# Create a channel
channel = grpc.insecure_channel('localhost:50051')
stub = accounts_pb2_grpc.AccountServiceStub(channel)

# Create an account
request = accounts_pb2.CreateAccountRequest(
    user_id='user_123',
    email='user@example.com',
    full_name='John Doe',
    type=accounts_pb2.ACCOUNT_TYPE_FREE
)

response = stub.CreateAccount(request)
print(f"Account created: {response.account.account_id}")

# Get an account
get_request = accounts_pb2.GetAccountRequest(
    account_id=response.account.account_id
)

get_response = stub.GetAccount(get_request)
print(f"Account: {get_response.account.full_name}")
```

## Development

Generate proto files:

```bash
cd ../../scripts
./generate_python.sh accounts
```

Install in development mode:

```bash
pip install -e ".[dev]"
```

## License

MIT
