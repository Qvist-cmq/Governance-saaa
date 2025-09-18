-- Governance SaaS PostgreSQL schema
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enumerations
CREATE TYPE document_type AS ENUM ('policy','standard','procedure','process','guideline','plan');
CREATE TYPE document_status AS ENUM ('draft','in_review','approved','published','archived');
CREATE TYPE version_status AS ENUM ('draft','in_review','approved','published','superseded');
CREATE TYPE questionnaire_status AS ENUM ('draft','active','closed');
CREATE TYPE questionnaire_response_status AS ENUM ('not_started','in_progress','submitted','approved');
CREATE TYPE control_status AS ENUM ('planned','in_progress','implemented','effective','needs_review');
CREATE TYPE effectiveness_rating AS ENUM ('unknown','ineffective','partially_effective','effective');
CREATE TYPE mapping_strength AS ENUM ('primary','supporting','related');

-- Core tables
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'active',
    primary_domain TEXT,
    locale TEXT NOT NULL DEFAULT 'en',
    timezone TEXT NOT NULL DEFAULT 'UTC',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    key TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    system BOOLEAN NOT NULL DEFAULT false,
    UNIQUE (tenant_id, key)
);

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL
);

CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (role_id, permission_id)
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    status TEXT NOT NULL DEFAULT 'invited',
    auth_provider TEXT NOT NULL DEFAULT 'local',
    mfa_enabled BOOLEAN NOT NULL DEFAULT false,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX users_unique_email_tenant ON users(tenant_id, lower(email));

CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    UNIQUE (user_id, role_id)
);

CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    type document_type NOT NULL,
    owner_id UUID REFERENCES users(id),
    status document_status NOT NULL DEFAULT 'draft',
    current_version_id UUID,
    effective_date DATE,
    expiry_date DATE,
    review_frequency_months INTEGER,
    classification TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE document_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    version_number TEXT NOT NULL,
    status version_status NOT NULL,
    editor_id UUID REFERENCES users(id),
    approver_id UUID REFERENCES users(id),
    content JSONB NOT NULL,
    change_summary TEXT,
    published_at TIMESTAMPTZ,
    effective_date DATE,
    expiry_date DATE,
    signature TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX document_versions_unique_version ON document_versions(document_id, version_number);

CREATE TABLE document_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_version_id UUID REFERENCES document_versions(id) ON DELETE CASCADE,
    heading TEXT NOT NULL,
    sequence INTEGER NOT NULL,
    content TEXT
);

CREATE TABLE document_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_version_id UUID REFERENCES document_versions(id) ON DELETE CASCADE,
    file_key TEXT NOT NULL,
    filename TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    size_bytes BIGINT NOT NULL,
    checksum TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE questionnaires (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    status questionnaire_status NOT NULL DEFAULT 'draft',
    due_date DATE,
    owner_id UUID REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE questionnaire_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    sequence INTEGER NOT NULL
);

CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID NOT NULL REFERENCES questionnaire_sections(id) ON DELETE CASCADE,
    prompt TEXT NOT NULL,
    help_text TEXT,
    type TEXT NOT NULL,
    required BOOLEAN NOT NULL DEFAULT false,
    allow_multiple BOOLEAN NOT NULL DEFAULT false,
    weight INTEGER DEFAULT 0,
    control_ids UUID[]
);

CREATE TABLE question_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    value TEXT NOT NULL,
    score INTEGER,
    sequence INTEGER NOT NULL
);

CREATE TABLE questionnaire_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,
    assignee_id UUID NOT NULL REFERENCES users(id),
    due_date DATE,
    UNIQUE (questionnaire_id, assignee_id)
);

CREATE TABLE questionnaire_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    questionnaire_id UUID NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,
    responder_id UUID REFERENCES users(id),
    status questionnaire_response_status NOT NULL DEFAULT 'not_started',
    started_at TIMESTAMPTZ DEFAULT now(),
    submitted_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    reviewer_id UUID REFERENCES users(id)
);

CREATE TABLE question_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    response_id UUID NOT NULL REFERENCES questionnaire_responses(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    value JSONB,
    notes TEXT,
    linked_control_ids UUID[],
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE response_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_response_id UUID NOT NULL REFERENCES question_responses(id) ON DELETE CASCADE,
    file_key TEXT NOT NULL,
    filename TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    size_bytes BIGINT NOT NULL,
    checksum TEXT,
    retention_policy_id UUID,
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE controls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    framework_refs TEXT[] NOT NULL,
    owner_id UUID REFERENCES users(id),
    status control_status NOT NULL DEFAULT 'planned',
    test_frequency TEXT,
    last_tested_at TIMESTAMPTZ,
    effectiveness effectiveness_rating NOT NULL DEFAULT 'unknown',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX controls_unique_code ON controls(tenant_id, code);

CREATE TABLE control_evidence (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    control_id UUID NOT NULL REFERENCES controls(id) ON DELETE CASCADE,
    file_key TEXT NOT NULL,
    description TEXT,
    collected_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    retention_policy_id UUID REFERENCES evidence_retention_policies(id),
    checksum TEXT,
    hash_algorithm TEXT DEFAULT 'sha256'
);

CREATE TABLE evidence_retention_policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    duration_months INTEGER NOT NULL,
    purge_action TEXT NOT NULL DEFAULT 'archive'
);

CREATE TABLE control_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    control_id UUID NOT NULL REFERENCES controls(id) ON DELETE CASCADE,
    questionnaire_item_id UUID REFERENCES questions(id),
    document_section_id UUID REFERENCES document_sections(id),
    strength mapping_strength NOT NULL DEFAULT 'primary',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date DATE,
    status TEXT NOT NULL DEFAULT 'open',
    priority TEXT NOT NULL DEFAULT 'medium',
    created_by UUID REFERENCES users(id),
    assigned_to UUID REFERENCES users(id),
    related_document_version_id UUID REFERENCES document_versions(id),
    related_questionnaire_id UUID REFERENCES questionnaires(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE task_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id),
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE task_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    file_key TEXT NOT NULL,
    filename TEXT NOT NULL,
    mime_type TEXT,
    size_bytes BIGINT,
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE workflow_definitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    key TEXT NOT NULL,
    name TEXT NOT NULL,
    module TEXT NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, key)
);

CREATE TABLE workflow_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    definition_id UUID NOT NULL REFERENCES workflow_definitions(id) ON DELETE CASCADE,
    key TEXT NOT NULL,
    name TEXT NOT NULL,
    sequence INTEGER NOT NULL,
    role_required TEXT,
    guard_expression TEXT
);

CREATE TABLE workflow_transitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    definition_id UUID NOT NULL REFERENCES workflow_definitions(id) ON DELETE CASCADE,
    from_step_id UUID NOT NULL REFERENCES workflow_steps(id) ON DELETE CASCADE,
    to_step_id UUID NOT NULL REFERENCES workflow_steps(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    guard_expression TEXT
);

CREATE TABLE workflow_instances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    definition_id UUID NOT NULL REFERENCES workflow_definitions(id) ON DELETE RESTRICT,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    current_step_id UUID REFERENCES workflow_steps(id),
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX workflow_instances_unique ON workflow_instances(entity_type, entity_id);

CREATE TABLE workflow_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    instance_id UUID NOT NULL REFERENCES workflow_instances(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    from_step_id UUID REFERENCES workflow_steps(id),
    to_step_id UUID REFERENCES workflow_steps(id),
    action TEXT NOT NULL,
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    actor_id UUID REFERENCES users(id),
    actor_role TEXT,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    before_data JSONB,
    after_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE integration_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    provider TEXT NOT NULL,
    config JSONB NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE taxonomy_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    taxonomy_type TEXT NOT NULL,
    value TEXT NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES taxonomy_items(id) ON DELETE SET NULL,
    UNIQUE (tenant_id, taxonomy_type, value)
);

CREATE TABLE document_taxonomy (
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    taxonomy_id UUID REFERENCES taxonomy_items(id) ON DELETE CASCADE,
    PRIMARY KEY (document_id, taxonomy_id)
);

CREATE TABLE control_taxonomy (
    control_id UUID REFERENCES controls(id) ON DELETE CASCADE,
    taxonomy_id UUID REFERENCES taxonomy_items(id) ON DELETE CASCADE,
    PRIMARY KEY (control_id, taxonomy_id)
);

CREATE TABLE questionnaire_taxonomy (
    questionnaire_id UUID REFERENCES questionnaires(id) ON DELETE CASCADE,
    taxonomy_id UUID REFERENCES taxonomy_items(id) ON DELETE CASCADE,
    PRIMARY KEY (questionnaire_id, taxonomy_id)
);

-- Row-level security enablement
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE questionnaires ENABLE ROW LEVEL SECURITY;
ALTER TABLE questionnaire_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE controls ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE integration_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE taxonomy_items ENABLE ROW LEVEL SECURITY;

-- Policies (sample; application will set current_setting('app.current_tenant'))
CREATE POLICY tenant_isolation ON tenants USING (id = current_setting('app.current_tenant')::uuid);
CREATE POLICY users_tenant_isolation ON users USING (tenant_id = current_setting('app.current_tenant')::uuid);
CREATE POLICY documents_tenant_isolation ON documents USING (tenant_id = current_setting('app.current_tenant')::uuid);
CREATE POLICY document_versions_tenant_isolation ON document_versions USING (
    EXISTS (SELECT 1 FROM documents d WHERE d.id = document_versions.document_id AND d.tenant_id = current_setting('app.current_tenant')::uuid)
);
CREATE POLICY questionnaires_tenant_isolation ON questionnaires USING (tenant_id = current_setting('app.current_tenant')::uuid);
CREATE POLICY questionnaire_responses_tenant_isolation ON questionnaire_responses USING (
    EXISTS (SELECT 1 FROM questionnaires q WHERE q.id = questionnaire_responses.questionnaire_id AND q.tenant_id = current_setting('app.current_tenant')::uuid)
);
CREATE POLICY controls_tenant_isolation ON controls USING (tenant_id = current_setting('app.current_tenant')::uuid);
CREATE POLICY tasks_tenant_isolation ON tasks USING (tenant_id = current_setting('app.current_tenant')::uuid);
CREATE POLICY workflow_instances_tenant_isolation ON workflow_instances USING (tenant_id = current_setting('app.current_tenant')::uuid);
CREATE POLICY audit_logs_tenant_isolation ON audit_logs USING (tenant_id = current_setting('app.current_tenant')::uuid);
CREATE POLICY integration_configs_tenant_isolation ON integration_configs USING (tenant_id = current_setting('app.current_tenant')::uuid);
CREATE POLICY taxonomy_items_tenant_isolation ON taxonomy_items USING (tenant_id = current_setting('app.current_tenant')::uuid);

-- Migration tracking
CREATE TABLE schema_migrations (
    id SERIAL PRIMARY KEY,
    version TEXT NOT NULL,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
