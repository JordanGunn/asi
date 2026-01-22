# Observability Report Template

ASI-compliant observability reporting for prompt skills.

## Required Report Fields

### Execution Context
- Skill name and version
- Execution timestamp (RFC3339)
- User identifier (if available)
- Working directory

### Scope
- Effective scope boundaries considered
- Any scope limitations or filters applied
- Rationale for scope decisions

### Inputs
- Files read (with paths and sizes)
- Parameters provided
- Environment variables used
- User prompts or commands

### Operations
- Deterministic operations performed
- Validation results
- Schema checks performed
- Transformations applied

### Outputs
- Files written (with paths and sizes)
- Artifacts created/modified
- State changes performed
- Side effects (should be none outside declared scope)

### Validation Status
- Schema validation results
- Constraint checks
- Quality metrics
- Pass/fail status with reasons

### Errors and Warnings
- Any errors encountered
- Warnings issued
- Remediation suggestions
- Error recovery attempts

## Report Format

```yaml
observability_report:
  skill: prompt-forge
  version: "0.1.0"
  executed_at: "2026-01-16T18:45:00Z"
  
  scope:
    considered: [".prompt/active.yaml"]
    constraints: ["schema_validation", "integrity_checks"]
    
  inputs:
    files_read:
      - path: ".prompt/active.yaml"
        size: 1024
        hash: "sha256:abc123..."
    parameters:
      - "--mark-ready"
      
  operations:
    - type: "schema_validation"
      status: "pass"
    - type: "artifact_update"
      status: "success"
      
  outputs:
    files_written:
      - path: ".prompt/active.yaml"
        size: 1156
        hash: "sha256:def456..."
        
  validation:
    schema_check: "pass"
    integrity_check: "pass"
    overall_status: "success"
    
  errors: []
  warnings: []
```
