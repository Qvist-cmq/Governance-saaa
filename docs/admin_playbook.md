# Admin Playbook

## Onboarding a New Tenant
1. Super Admin logs into Admin Console → Tenants → **Create Tenant**.
2. Provide name, slug, timezone, primary domain, default locale (English or Danish).
3. Select starter package: ISO 27001 + NIS2 (preloads templates, questionnaires, controls).
4. Generate initial Customer Admin invite; send activation email with MFA requirement.
5. Run `Tenant Bootstrap` automation:
   - Seed roles (Customer Admin, Editor, Approver, Viewer, External Auditor).
   - Apply branding defaults (logo placeholder, color palette).
   - Schedule onboarding tasks (review templates, configure SSO, import org structure).
6. Verify tenant isolation by impersonating and confirming data scope limited.

## Enabling SSO (SAML or OIDC)
1. Customer Admin navigates to Settings → Authentication.
2. Choose SAML or OIDC.
3. Enter IdP metadata or discovery URL + client credentials.
4. Validate connection using built-in test (performs login flow in popup).
5. Enable enforcement (optional) – toggle “Require SSO” for specific roles.
6. Document change in audit log automatically; download configuration summary PDF.

## Configuring SharePoint Sync
1. Customer Admin opens Settings → Integrations → SharePoint.
2. Provide Azure AD Application ID, Tenant ID, Client Secret (stored encrypted).
3. Select SharePoint site and document library for sync.
4. Map platform folders (Policies, Procedures, Evidence) to SharePoint paths.
5. Trigger initial sync job; monitor status on Integrations dashboard.
6. Schedule recurring sync (default nightly). If disabled, system falls back to internal S3 storage.

## Setting Review Cadences
1. Navigate to Documents → Review Schedule.
2. Filter by classification or owner.
3. Bulk-select items and set review frequency (e.g., 12 months) with auto reminders (30/7/0 days).
4. Confirm calendar feed (ICS) subscription is active for owners.
5. Track upcoming reviews on Dashboard KPIs.

## Exporting Evidence for Audit
1. Go to Reports → Evidence Export.
2. Select timeframe, frameworks (ISO 27001, NIS2), and include attachments toggle.
3. Choose export format (ZIP with CSV manifest + files, or SharePoint push if enabled).
4. Approver approves export; audit log captures requester, purpose, scope, and expiry date.
5. Download link available for 7 days (auto-expiry). External auditors receive secure link with MFA requirement.

## Break-glass Access Procedure
1. Super Admin initiates emergency access from Support Console.
2. System generates time-bound token (1 hour) logged with justification.
3. After use, Super Admin submits post-event review note; system notifies tenant admin.

## Data Retention & Deletion
- Use Data Admin → Retention Policies to define durations by artifact type.
- Deletion requests queue approval workflow and generate evidence report post-execution.

## Localization Management
- Tenant Admin can switch default locale (English/Danish) and upload translations for custom fields.
- New content defaults to English but supports inline translation toggles.
