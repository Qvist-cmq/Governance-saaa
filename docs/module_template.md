# Module Template Skeleton

```
modules/
  example-module/
    module.json
    backend/
      index.ts
      routes.ts
      service.ts
      migrations/
        001-create-table.sql
    frontend/
      index.tsx
      routes.tsx
      pages/
        ListPage.tsx
        DetailPage.tsx
      store/
        slice.ts
```

## module.json
```json
{
  "name": "example-module",
  "version": "1.0.0",
  "navLabel": "Example",
  "description": "Starter module",
  "permissions": [
    { "key": "example.view", "defaultRoles": ["viewer", "admin"] },
    { "key": "example.manage", "defaultRoles": ["editor", "admin"] }
  ]
}
```

## Backend Bootstrap (`backend/index.ts`)
```typescript
import { Router } from 'express';
import { registerRoutes } from './routes';

export const manifest = {
  name: 'example-module',
  permissions: [
    { key: 'example.view', description: 'View example records' },
    { key: 'example.manage', description: 'Manage example records' }
  ],
  migrations: [__dirname + '/migrations/001-create-table.sql'],
  register(app, services) {
    const router = Router();
    registerRoutes(router, services);
    app.use('/example', services.auth.requireTenant, router);
  },
  onEvent(event, services) {
    if (event.type === 'document.published') {
      // optional reaction
    }
  }
};
```

## Frontend Entry (`frontend/index.tsx`)
```tsx
import { lazy } from 'react';

export const navItems = [
  {
    path: '/example',
    label: 'Example',
    icon: 'Cube',
    requiredPermission: 'example.view'
  }
];

export const routes = [
  {
    path: '/example',
    element: lazy(() => import('./pages/ListPage')),
    permission: 'example.view'
  },
  {
    path: '/example/:id',
    element: lazy(() => import('./pages/DetailPage')),
    permission: 'example.view'
  }
];
```

## Event Hooks
- Subscribe via `services.events.on('document.published', handler)`.
- Emit via `services.events.emit('example.completed', payload)` for other modules.

## Database Migration Example
```sql
CREATE TABLE example_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```
