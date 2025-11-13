"""GeniusTechSpace Core API Contracts.

This package provides core API contracts for tenant management,
multitenancy, and common types.
"""

__version__ = "0.1.0"

# Re-export commonly used types for convenience
from .v1 import tenant_pb2, tenant_pb2_grpc

__all__ = [
    "tenant_pb2",
    "tenant_pb2_grpc",
]
