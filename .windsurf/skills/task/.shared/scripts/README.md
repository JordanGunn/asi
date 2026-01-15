# Task CLI Scripts

## Usage

```bash
./skill.sh help
./skill.sh validate
./skill.sh create my-task --title "My Task" --kind feature --risk low --select
./skill.sh list
./skill.sh select my-task
./skill.sh close my-task --reason completed
./skill.sh clean
```

## Structure

```
scripts/
  skill.sh          # CLI entrypoint (Unix)
  skill.ps1         # CLI entrypoint (Windows)
  include/          # Implementation
    pyproject.toml
    task_cli.py
    task_hash.py
    task_parse.py
    task_time.py
```
