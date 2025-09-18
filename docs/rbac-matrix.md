# RBAC Matrix

| Module / Action | Super Admin | Customer Admin | Editor | Approver | Viewer | External Auditor |
| --- | --- | --- | --- | --- | --- | --- |
| Tenants: create/update/delete | ✅ (all tenants) | ❌ | ❌ | ❌ | ❌ | ❌ |
| Tenants: impersonate | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Tenant settings: configure branding, taxonomies | ✅ (support) | ✅ | ❌ | ❌ | ❌ | ❌ |
| Authentication: configure SSO/MFA | ✅ (support) | ✅ | ❌ | ❌ | ❌ | ❌ |
| Users: invite/manage | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Documents: create draft | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Documents: edit draft | ✅ | ✅ | ✅ (own/assigned) | ✅ | ❌ | ❌ |
| Documents: submit for review | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Documents: approve/publish | ✅ | ✅ | ❌ | ✅ (assigned scope) | ❌ | ❌ |
| Documents: view published | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (scoped) |
| Documents: delete/retire | ✅ | ✅ | ❌ | ✅ (with justification) | ❌ | ❌ |
| Version history & diff | ✅ | ✅ | ✅ | ✅ | ✅ (read-only) | ✅ |
| Questionnaires: create/edit | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Questionnaires: assign | ✅ | ✅ | ✅ (if permitted) | ✅ | ❌ | ❌ |
| Questionnaire response submit | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ (if invited) |
| Questionnaire review/approve | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| Controls catalogue: manage | ✅ | ✅ | ✅ (propose) | ✅ (approve changes) | ❌ | ❌ |
| Controls catalogue: view | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Mappings: edit | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Dashboards & reports: view | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (scoped) |
| Reports: schedule/export | ✅ | ✅ | ✅ (create) | ✅ (publish) | ❌ | ❌ |
| Tasks: create/assign | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Tasks: complete | ✅ | ✅ | ✅ (assigned) | ✅ | ❌ | ❌ |
| Workflows: configure | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Data admin: import/export | ✅ | ✅ | ✅ (import drafts) | ✅ (approve imports) | ❌ | ❌ |
| Audit log: view | ✅ (all tenants) | ✅ (own tenant) | ❌ | ✅ (own actions) | ❌ | ❌ |
| Audit log: export | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Integration config (SharePoint) | ✅ (support) | ✅ | ❌ | ❌ | ❌ | ❌ |
| API keys / service accounts | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
