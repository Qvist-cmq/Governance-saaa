# Deployment Guide

## Prerequisites
- Docker & docker-compose
- Node.js 20.x
- Terraform >= 1.5
- Access to cloud account (AWS example)

## Local Development
1. Copy `.env.example` (to be created) with secrets.
2. Run `docker-compose up --build` to start Postgres, Redis, API, worker, and web UI.
3. Apply migrations:
   ```bash
   docker compose exec api npm run prisma:migrate
   ```
4. Seed reference data (tenants, roles, controls):
   ```bash
   docker compose exec api npm run seed
   ```
5. Access UI at `http://localhost:8080` (default credentials seeded).

## Docker Images
- **API**: `Dockerfile.api` builds Node/Express service. Build via `docker build -f Dockerfile.api -t gov-saas-api .`.
- **Web**: `Dockerfile.web` builds React SPA served by NGINX. Build via `docker build -f Dockerfile.web -t gov-saas-web .`.
- **Worker**: Shares API image with alternate command `node dist/worker.js`.

## Environment Variables (excerpt)
| Variable | Description |
| --- | --- |
| `DATABASE_URL` | Postgres connection string |
| `REDIS_URL` | Redis connection |
| `JWT_SECRET` | JWT signing secret |
| `FILE_STORAGE_BUCKET` | S3 bucket name |
| `SHAREPOINT_CLIENT_ID` / `SECRET` | Tenant-specific integration credentials |
| `SMTP_HOST` | Email server |

## Terraform Deployment
1. Configure AWS credentials via environment (e.g., `AWS_PROFILE`).
2. Initialize Terraform:
   ```bash
   cd infra
   terraform init
   ```
3. Provide variables (e.g., `terraform apply -var db_password=StrongPass123!`).
4. Terraform provisions VPC, subnets, Aurora Postgres, Redis, ECS cluster, and security groups. Add ECS service definitions referencing ECR images (not included for brevity).

## CI/CD Pipeline (Recommended)
1. **Build Stage**: Run lint/test, build Docker images, push to ECR.
2. **Deploy Stage**: Terraform plan & apply, update ECS services, run database migrations via task.
3. **Post-Deploy**: Smoke tests (API health, login), broadcast release notes.

## Backup & Restore
- **Database**: Automated daily snapshots (RPO: 4 hours), stored 7 days. Manual point-in-time restore using Aurora.
- **Object Storage**: Versioning enabled, lifecycle rules to Glacier after 180 days.
- **Redis**: Not persisted; rely on warm-up tasks.
- **Restore Procedure**:
  1. Identify incident via monitoring alerts.
  2. Initiate DB point-in-time restore to new cluster.
  3. Update ECS service environment `DATABASE_URL` to restored endpoint.
  4. Rehydrate object storage via version restore if required.
  5. Validate workflow operations, audit logs, and document exports.
  6. Document incident in DR runbook.

## Disaster Recovery Runbook (Excerpt)
- Trigger: Region outage >30 minutes.
- RTO: 8 hours, RPO: 4 hours.
- Steps:
  1. Activate secondary region Terraform workspace.
  2. Restore latest DB snapshot to standby region.
  3. Sync S3 bucket via Cross-Region Replication.
  4. Deploy services using ECS/EKS with updated DNS (Route53 failover).
  5. Validate authentication (MFA + SSO), run smoke tests, inform customers.

## SharePoint Integration Deployment
- Use Azure AD app registration per tenant, store credentials encrypted in integration config.
- Worker job polls `integration_configs` table and executes Microsoft Graph sync for selected folders.

## Monitoring & Alerts
- Enable AWS CloudWatch metrics & alarms (CPU, memory, queue depth, job failures).
- Forward logs to SIEM (e.g., via FireLens) tagged with tenant IDs.
- Synthetic uptime checks hitting `/health/ready` endpoint every minute.
