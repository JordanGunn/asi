---
description: Canonical execution path for this skill.
index:
  - Step 1: Initialize Session
  - Step 2: Record Symptoms
  - Step 3: Surface Scan
  - Step 4: Parameterized Evidence Gathering
  - Step 5: Form Hypotheses
  - Step 6: Iterate
  - Step 7: Diagnose
  - Step 8: Generate Treatment
  - Step 9: Handoff
---

# Procedure

Canonical execution path for the doctor skill.

## Step 1: Initialize Session

```bash
./skill.sh init --patient "system-name"
./skill.sh status
```

Creates `.doctor/session.yaml` with `status: investigating`.

## Step 2: Record Symptoms

For each symptom the user describes:

```bash
./skill.sh symptom "API returns 500 error" --category error --evidence "logs show timeout"
```

## Step 3: Surface Scan

Identify relevant file landscape:

```bash
./skill.sh surface --patterns "*.py" "*.yaml" --path src/
```

## Step 4: Parameterized Evidence Gathering

Agent chooses search terms based on symptoms:

```bash
./skill.sh grep "connection timeout" --save
./skill.sh grep "database pool" --type py --save
```

**Key pattern:** Agent provides subjective terms → Script returns deterministic matches.

## Step 5: Form Hypotheses

Based on evidence, record hypotheses with confidence:

```bash
./skill.sh hypothesize "Database connection pool exhaustion" --confidence 65 --falsifiable "Pool metrics show available connections"
```

## Step 6: Iterate

Repeat Steps 4-5 until one hypothesis reaches sufficient confidence (typically >80%).

Check status:

```bash
./skill.sh status
```

## Step 7: Diagnose

When confident, set diagnosis:

```bash
./skill.sh diagnose "Connection pool exhaustion under load" --confidence 85 --cause "Pool size too small for traffic"
```

## Step 8: Generate Treatment

Produce schema-based treatment plan:

```bash
./skill.sh treat --option "Increase pool size:Set pool_size=50:low" --option "Add connection retry:Implement exponential backoff:medium" --recommend "Increase pool size"
```

Generates `.doctor/treatment.md`.

## Step 9: Handoff

Present treatment plan to user. Skill complete.

To clean up after treatment is accepted:

```bash
./skill.sh clean
```
