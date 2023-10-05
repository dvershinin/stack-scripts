#!/bin/bash
# Wrapper script to run any command in a cron-friendly way.

# Usage: cronify.sh [-l LOG_FILE] [-n] COMMAND

# It redirects stdout to a log file, and stderr to both the log file and
# stdout.
# Thus, cron will send emails upon errors only, and the log file will contain
# both stdout and stderr.

# Initialize variables
LOG_FILE=""
APPEND=1

MAX_SIZE=$(( 64 * 1024 * 1024 ))  # Default 64MB

# Argument parsing
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--no-append)
      APPEND=0
      shift
      ;;
    -s|--max-size)
      MAX_SIZE="$2"
      # Convert to bytes from suffixes
      MAX_SIZE=$(numfmt --from=iec "$MAX_SIZE")
      shift 2
      ;;
    -l|--log-file)
      LOG_FILE="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

# Remaining arguments is the command to run

if [ -n "$LOG_FILE" ]; then
  if [ "$APPEND" -eq 1 ]; then
    # shellcheck disable=SC2094
    eval "$@" >> "$LOG_FILE" 2> >(tee -a "$LOG_FILE" >&2)
  else
    # shellcheck disable=SC2094
    eval "$@" > "$LOG_FILE" 2> >(tee "$LOG_FILE" >&2)
  fi
  # Check if log file size exceeds MAX_SIZE and truncate if necessary
  if [ "$MAX_SIZE" -gt 0 ] && [ -f "$LOG_FILE" ]; then
    actual_size=$(wc -c <"$LOG_FILE")
    if [ "$actual_size" -gt "$MAX_SIZE" ]; then
      # Create unique temporary file
      temp_file=$(mktemp --tmpdir cronify.XXXXXXXXXX)
      tail -c "$MAX_SIZE" "$LOG_FILE" > "$temp_file"
      mv "$temp_file" "$LOG_FILE"
      echo "Log file size exceeded. Truncated." >> "$LOG_FILE"
    fi
  fi
else
  # shellcheck disable=SC2069
  eval "$@" 2>&1 >/dev/null
fi
