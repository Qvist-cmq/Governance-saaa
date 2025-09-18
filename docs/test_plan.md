# Test Plan

## Test Strategy
- **Unit Tests** (Jest + ts-jest): cover services, validators, permission checks (>80% coverage for critical modules).
- **Integration Tests** (Jest + Supertest): API endpoints for documents, questionnaires, controls with Postgres test container.
- **End-to-End Tests** (Playwright): cover key flows (login with MFA, document draft→publish, questionnaire assignment→submission, coverage report export).
- **Security Testing**:
  - Static analysis with ESLint + TypeScript strict mode.
  - Dependency scanning (npm audit, Snyk).
  - OWASP ZAP baseline scan on staging.
  - RLS enforcement tests ensuring no cross-tenant access.
- **Performance Tests**: k6 scenarios for document listing (1k items) and questionnaire submissions.
- **Accessibility Tests**: axe-core automated checks on main screens.

## Environments
- **CI**: Executes unit + integration + lint on each PR.
- **Nightly**: Full E2E, performance smoke, dependency scan.
- **Pre-release**: Manual exploratory testing with external auditor persona.

## Test Data Management
- Seed tenants: `acme-industries`, `nordic-energy` with sample roles.
- Use factories with tenant scoping, ensure cleanup after each test.

## Sample Jest Unit Test
```typescript
import { canTransitionDocument } from '../workflows/document';

describe('Document workflow guard', () => {
  const baseContext = {
    tenantId: 'tenant-1',
    document: { status: 'in_review', lastEditorId: 'user-a' },
    actor: { id: 'user-b', roles: ['approver'] },
    metadataComplete: true,
  } as const;

  it('blocks approve when actor edited last version', () => {
    const result = canTransitionDocument('approve', {
      ...baseContext,
      document: { ...baseContext.document, lastEditorId: 'user-b' },
    });
    expect(result.allowed).toBe(false);
    expect(result.reason).toContain('Segregation of duties');
  });

  it('allows approve when metadata complete and SoD satisfied', () => {
    const result = canTransitionDocument('approve', baseContext);
    expect(result.allowed).toBe(true);
  });
});
```

## Sample Integration Test (Supertest)
```typescript
import request from 'supertest';
import { app } from '../../app';

describe('POST /documents', () => {
  it('creates a document for tenant with template', async () => {
    const response = await request(app)
      .post('/v1/documents')
      .set('Authorization', 'Bearer token')
      .set('X-Tenant-ID', '11111111-1111-1111-1111-111111111111')
      .send({ title: 'Access Control Policy', type: 'policy', templateId: 'tmpl-access-control' });

    expect(response.status).toBe(201);
    expect(response.body.title).toBe('Access Control Policy');
    expect(response.body.status).toBe('draft');
  });
});
```

## Traceability Matrix (Excerpt)
| Requirement | Test Type | Coverage |
| --- | --- | --- |
| Create→Review→Approve→Publish flow | E2E | Playwright scenario `document-workflow.spec.ts` |
| ISO/NIS2 coverage heatmap | Integration | `reports.coverage.spec.ts` |
| MFA authentication | Unit & E2E | `auth.service.spec.ts`, `auth-mfa.spec.ts` |
| SharePoint export toggle | Integration | `integrations.sharepoint.spec.ts` |
| Audit log immutability | Unit | `audit-log.service.spec.ts` |
