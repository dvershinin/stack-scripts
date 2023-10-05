## stack-scripts

### `cronify.sh`

Runs a command in a cron-friendly way:
* Hide output unless there is an error
* Optionally logs to a file via `-l` option

Usage:
```bash
cronify.sh [-l /path/to/logfile] command [args...]
```
