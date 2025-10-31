"""
Auth Client - Generated gRPC client for Auth Service

Example usage:
    import grpc
    from auth_client.auth.v1 import auth_pb2, auth_pb2_grpc
    
    channel = grpc.insecure_channel('localhost:50051')
    stub = auth_pb2_grpc.AuthServiceStub(channel)
    
    request = auth_pb2.RegisterRequest(
        email='user@example.com',
        password='secure_password',
        full_name='John Doe'
    )
    
    response = stub.Register(request)
    print(f"User registered: {response.user_id}")
"""

__version__ = "0.1.0"

# Generated modules will be imported here after generation
try:
    from auth_client.auth.v1 import auth_pb2, auth_pb2_grpc
    from auth_client.common import types_pb2
    
    __all__ = [
        "auth_pb2",
        "auth_pb2_grpc",
        "types_pb2",
    ]
except ImportError:
    # Modules not yet generated
    __all__ = []
