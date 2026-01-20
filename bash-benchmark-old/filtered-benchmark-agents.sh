#!/bin/bash
# Benchmark Script — agentic runs + shim executor + random nonce

PROMPT="$1"
N_RUNS="${2:-1}"
[[ -z "$PROMPT" ]] && { echo "Usage: $0 <prompt> [n_runs]"; exit 1; }

# Timestamp-based results folder
TS=$(date +%y%m%d-%H%M)
BASE_DIR="$(pwd)/benchmark-results-$TS"
mkdir -p "$BASE_DIR"

# Generate random nonce (encourages divergent agent behavior)
NONCE=$(openssl rand -hex 6 2>/dev/null || head -c 6 /dev/urandom | xxd -p)

# Prefix prompt with nonce tag (agents see it but cannot ignore it)
PROMPT="NONCE:$NONCE — $PROMPT"

run_agent() {
  local agent=$1 run_num=$2 prompt=$3
  local dir="$BASE_DIR/$agent/run-$run_num"
  mkdir -p "$dir"

  (
    cd "$dir"

    echo ""
    echo "=== $agent / run-$run_num ==="
    echo "nonce: $NONCE"

    local start=$(date +%s)
    local cmd=()

    case $agent in
      codex-cli)
        cmd=(/opt/homebrew/bin/codex exec \
          --dangerously-bypass-approvals-and-sandbox \
          --skip-git-repo-check \
          "$prompt")
        ;;
      copilot-cli)
        cmd=(/opt/homebrew/bin/copilot --allow-all-tools --log-level debug --log-dir "$dir" -p "$prompt")
        ;;
      claude-code)
        cmd=(/opt/homebrew/bin/claude -p --verbose --output-format stream-json --include-partial-messages --permission-mode bypassPermissions "$prompt")
        ;;
    esac

    # Print command + live output
    echo "+ ${cmd[*]}"
    if [[ "$agent" == "claude-code" ]]; then
      "${cmd[@]}" 2>&1 | python3 -c 'import json,sys
def emit(text):
    if text:
        print(text, flush=True)
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        obj = json.loads(line)
    except Exception:
        continue
    event = obj.get("event", {}) if isinstance(obj.get("event", {}), dict) else {}
    if event.get("type") == "content_block_delta":
        delta = event.get("delta", {})
        if isinstance(delta, dict) and delta.get("type") == "text_delta":
            emit(delta.get("text", ""))
    msg = obj.get("message") or event.get("message")
    if isinstance(msg, dict):
        for item in msg.get("content", []):
            if item.get("type") == "text":
                emit(item.get("text", ""))
            elif item.get("type") == "tool_use":
                name = item.get("name", "tool")
                inp = item.get("input", {})
                if isinstance(inp, dict) and "command" in inp:
                    emit("[tool:%s] %s" % (name, inp.get("command")))
                else:
                    emit("[tool:%s] %s" % (name, inp))
    elif obj.get("type") == "user":
        msg = obj.get("message", {})
        for item in msg.get("content", []):
            if item.get("type") == "tool_result":
                content = item.get("content")
                if isinstance(content, str):
                    emit(content)
' | tee agent.log
    else
      "${cmd[@]}" 2>&1 | tee agent.log
    fi

    if [[ "$agent" == "copilot-cli" ]]; then
      extra_logs=$(find "$dir" -maxdepth 1 -type f -name "*.log" \
        ! -name "agent.log" ! -name "compile.log" ! -name "runtime.log")
      if [[ -n "$extra_logs" ]]; then
        {
          echo ""
          echo "==== copilot log (filtered tail) ===="
          cat $extra_logs | awk '{
            line=$0
            sub(/^[[:space:]]*/, "", line)
            first = substr(line,1,1)
            if (length($0) < 300 && line !~ /^</ && first != "{" && first != "[" && first != "\"" && first != "}" && first != "]") {
              print
            }
          }' | tail -n 600
        } >> agent.log
      fi
    fi

    echo $(($(date +%s) - start)) > elapsed.txt

    # --- shim executor (captures REAL compiler + runtime output) ---
    if ls *.csproj >/dev/null 2>&1 || ls *.cs >/dev/null 2>&1; then
      echo "+ shim: dotnet build"
      dotnet build > compile.log 2>&1 || true

      echo "+ shim: dotnet run"
      dotnet run > runtime.log 2>&1 || true

      echo $? > run_exit_code.txt
    else
      proj=$(find . -maxdepth 2 -name "*.csproj" | head -n 1)
      if [[ -n "$proj" ]]; then
        echo "+ shim: dotnet build (project)"
        dotnet build "$proj" > compile.log 2>&1 || true

        echo "+ shim: dotnet run (project)"
        dotnet run --project "$proj" > runtime.log 2>&1 || true

        echo $? > run_exit_code.txt
      fi
    fi

    if [[ "$agent" == "claude-code" ]]; then
      if [[ -f compile.log || -f runtime.log ]]; then
        {
          echo ""
          echo "==== compile log ===="
          [[ -f compile.log ]] && tail -n 200 compile.log
          echo ""
          echo "==== runtime log ===="
          [[ -f runtime.log ]] && tail -n 200 runtime.log
        } >> agent.log
      fi
    fi
  )
}

echo "Running $N_RUNS run(s) per agent..."

for ((run=1; run<=N_RUNS; run++)); do
  for agent in codex-cli copilot-cli claude-code; do
    run_agent "$agent" "$run" "$PROMPT" &
  done
  wait
done


echo ""
echo "=== SUMMARY ==="

for agent in codex-cli copilot-cli claude-code; do
  total=0 n=0
  total_xlsx=0 total_comp=0 total_run=0 total_warn=0

  for ((run=1; run<=N_RUNS; run++)); do
    run_dir="$BASE_DIR/$agent/run-$run"
    elapsed_file="$run_dir/elapsed.txt"
    [[ -f "$elapsed_file" ]] || continue

    total=$((total + $(cat "$elapsed_file")))
    n=$((n+1))

    xlsx=$(find "$run_dir" -name "*.xlsx" 2>/dev/null | wc -l)

    comp=$(grep -ciE "error CS[0-9]+|compilation failed" \
           "$run_dir/compile.log" 2>/dev/null || true)

    warn=$(grep -ciE "warning CS[0-9]+" \
           "$run_dir/compile.log" 2>/dev/null || true)

    runt=$(grep -ciE "exception|System\.[A-Za-z]+Exception" \
           "$run_dir/runtime.log" 2>/dev/null || true)

    total_xlsx=$((total_xlsx + xlsx))
    total_comp=$((total_comp + comp))
    total_run=$((total_run + runt))
    total_warn=$((total_warn + warn))
  done

  [[ $n -gt 0 ]] && echo \
    "$agent avg_time=$((total/n))s xlsx=$((total_xlsx/n)) compile_err=$((total_comp/n)) runtime_err=$((total_run/n)) warnings=$((total_warn/n))"
done
