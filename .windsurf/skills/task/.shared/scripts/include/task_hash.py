"""Deterministic hashing for task canonical intent."""

import hashlib
import re


CANONICAL_SECTIONS = ["Goal", "Acceptance", "Constraints", "Dependencies"]
EXCLUDED_SECTIONS = ["Evidence"]


def normalize_content(content: str) -> str:
    """
    Normalize markdown content for hashing.
    
    - Normalize line endings to \n
    - Trim trailing whitespace from each line
    - Collapse multiple blank lines to single blank line
    """
    lines = content.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    lines = [line.rstrip() for line in lines]
    
    normalized = []
    prev_blank = False
    for line in lines:
        is_blank = line == ""
        if is_blank and prev_blank:
            continue
        normalized.append(line)
        prev_blank = is_blank
    
    return "\n".join(normalized).strip()


def extract_section(content: str, heading: str) -> str:
    """Extract content under a specific H2 heading."""
    pattern = rf"^## {re.escape(heading)}\s*\n(.*?)(?=^## |\Z)"
    match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
    if match:
        return match.group(1).strip()
    return ""


def extract_canonical_intent(content: str) -> str:
    """
    Extract canonical intent sections from task markdown.
    
    Includes: Goal, Acceptance, Constraints, Dependencies
    Excludes: Evidence
    """
    sections = []
    for heading in CANONICAL_SECTIONS:
        section_content = extract_section(content, heading)
        if section_content:
            sections.append(f"## {heading}\n\n{section_content}")
    
    return "\n\n".join(sections)


def compute_intent_hash(content: str) -> str:
    """
    Compute SHA256 hash of canonical intent sections.
    
    Returns lowercase hex string.
    """
    intent = extract_canonical_intent(content)
    normalized = normalize_content(intent)
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest()


def verify_intent_hash(content: str, stored_hash: str | None) -> tuple[bool, str]:
    """
    Verify stored hash matches computed hash.
    
    Returns (matches, computed_hash).
    """
    computed = compute_intent_hash(content)
    if stored_hash is None:
        return False, computed
    return stored_hash == computed, computed
