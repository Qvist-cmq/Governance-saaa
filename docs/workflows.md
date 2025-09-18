# Workflow Definitions

## Document Lifecycle Workflow
- **States**: Draft → In Review → Approved → Published → Archived
- **Transitions**:
  - Draft → In Review (`submit`): Guard requires Editor or Admin role, mandatory change summary.
  - In Review → Draft (`request_changes`): Guard requires Approver; comment required; notifies editor.
  - In Review → Approved (`approve`): Guard requires Approver, verifies SoD (approver ≠ last editor), ensures all mandatory metadata present.
  - Approved → Published (`publish`): Guard requires Approver or Admin, triggers watermark PDF generation + notifications.
  - Published → Archived (`retire`): Guard requires Admin; requires replacement version reference.
- **Automations**:
  - On `submit`: create review task for approvers, lock editing.
  - On `publish`: emit `document.published` event, update effective date, schedule review reminder based on cadence.

## Questionnaire Workflow
- **States**: Draft → Active → Closed → Archived
- **Transitions**:
  - Draft → Active (`activate`): Guard requires Admin or Editor with approval; ensures assignments exist and due dates set.
  - Active → Closed (`close`): Guard requires Approver; ensures all responses submitted or forcibly closed with justification.
  - Closed → Archived (`archive`): Guard requires Admin; locks future edits.
- **Automations**:
  - On `activate`: send invitations, queue reminders.
  - On `close`: generate summary report, link to audit log.

## Control Update Workflow
- **States**: Draft → Review → Approved
- **Transitions**:
  - Draft → Review (`submit_update`): Guard requires control owner.
  - Review → Approved (`approve_update`): Guard requires Approver; verifies test results attached.
- **Automations**:
  - On `approve_update`: update effectiveness, append to control history, notify stakeholders.

## Task Workflow
- **States**: Open → In Progress → Blocked/On Hold → Completed → Verified
- **Transitions**:
  - Open → In Progress (`start`): Guard requires assignee.
  - In Progress → Blocked (`block`): Assignee sets blocker reason.
  - Blocked → In Progress (`unblock`): Assignee clears blocker.
  - In Progress → Completed (`complete`): Assignee attaches evidence if required.
  - Completed → Verified (`verify`): Guard requires approver or creator; ensures acceptance comment.

## Workflow Guards Summary
- **Segregation of Duties** enforced by verifying `last_editor_id != approver_id` and `role in {Approver, Admin}`.
- **External Auditor** cannot change workflow state; view-only.
- All transitions recorded in audit log with before/after state and comment.
