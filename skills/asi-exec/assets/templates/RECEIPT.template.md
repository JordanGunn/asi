---
description: "Execution receipt log for ${skill_name}"
timestamp: "${timestamp}"
source_plan: "${source_plan}"
source_todo: "${source_todo}"
---

# Execution Receipt: ${skill_name}

## Summary

| Metric | Value |
| ------ | ----- |
| Total tasks | ${total_tasks} |
| Completed | ${completed_tasks} |
| Failed | ${failed_tasks} |
| Blocked | ${blocked_tasks} |
| Remaining | ${remaining_tasks} |

---

## Receipts

<!-- Receipts are appended below in chronological order -->

### ${task_id} — ${task_description}

**Status:** ${status}
**Timestamp:** ${timestamp}

#### Artifacts Created

- ${artifact_path}

#### Artifacts Modified

- ${artifact_path}

#### Notes

${notes}

---
