# GeniusTechSpace API Contracts - TypeScript Client

TypeScript/JavaScript client library for GeniusTechSpace API contracts.

## Installation

```bash
npm install @geniustechspace/api-contracts
# or
yarn add @geniustechspace/api-contracts
```

## Usage

```typescript
import * as grpc from '@grpc/grpc-js';
import { AuthServiceClient } from '@geniustechspace/api-contracts/idp/v1/auth';

// Connect to service
const client = new AuthServiceClient(
  'localhost:50051',
  grpc.credentials.createInsecure()
);

// Make request
client.signIn({
  tenantId: 'tenant-123',
  email: 'user@example.com',
  password: 'secure-password'
}, (err, response) => {
  if (err) {
    console.error('Error:', err);
    return;
  }
  console.log('Token:', response.accessToken);
});
```

### Async/Await

```typescript
import { promisify } from 'util';

const signInAsync = promisify(client.signIn).bind(client);

try {
  const response = await signInAsync({
    tenantId: 'tenant-123',
    email: 'user@example.com',
    password: 'secure-password'
  });
  console.log('Token:', response.accessToken);
} catch (err) {
  console.error('Error:', err);
}
```

## TypeScript Support

Full TypeScript definitions included for type safety and IDE support.
