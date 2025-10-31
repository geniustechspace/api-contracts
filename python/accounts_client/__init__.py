"""
Accounts Client - Generated gRPC client for Accounts Service

Example usage:
    import grpc
    from accounts_client.accounts.v1 import accounts_pb2, accounts_pb2_grpc

    channel = grpc.insecure_channel('localhost:50051')
    stub = accounts_pb2_grpc.AccountServiceStub(channel)

    request = accounts_pb2.CreateAccountRequest(
        user_id='user_123',
        email='user@example.com',
        full_name='John Doe'
    )

    response = stub.CreateAccount(request)
    print(f"Account created: {response.account.account_id}")
"""

__version__ = "0.1.0"

# Generated modules will be imported here after generation
try:
    from accounts_client.accounts.v1 import accounts_pb2, accounts_pb2_grpc
    from accounts_client.common import types_pb2

    __all__ = [
        "accounts_pb2",
        "accounts_pb2_grpc",
        "types_pb2",
    ]
except ImportError:
    # Modules not yet generated
    __all__ = []
