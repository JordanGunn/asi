"""Deterministic time utilities for task management."""

from datetime import datetime, timezone


def now_utc() -> datetime:
    """Return current UTC time."""
    return datetime.now(timezone.utc)


def to_rfc3339(dt: datetime) -> str:
    """Convert datetime to RFC3339 UTC string."""
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def from_rfc3339(s: str) -> datetime:
    """Parse RFC3339 UTC string to datetime."""
    s = s.rstrip("Z") + "+00:00"
    return datetime.fromisoformat(s)


def days_since(dt: datetime) -> int:
    """Return number of days since the given datetime."""
    now = now_utc()
    delta = now - dt
    return delta.days


def is_stale(
    last_reviewed_at: str | None,
    updated_at: str | None,
    created_at: str,
    threshold_days: int = 21,
) -> tuple[bool, str]:
    """
    Determine if a task is stale based on timestamps.
    
    Returns (is_stale, reason).
    """
    reference_str = last_reviewed_at or updated_at or created_at
    reference_dt = from_rfc3339(reference_str)
    age = days_since(reference_dt)
    
    if age >= threshold_days:
        source = "last_reviewed_at" if last_reviewed_at else ("updated_at" if updated_at else "created_at")
        return True, f"{age}d since {source}"
    return False, ""
