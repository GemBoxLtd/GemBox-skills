#!/bin/bash
# Benchmark Script — agentic runs + shim executor + random nonce

PROMPT="$1"
BENCH_NAME="${2:-noname}"
N_RUNS="${3:-1}"
[[ -z "$PROMPT" ]] && { echo "Usage: $0 <prompt> [bench_name] [n_runs]"; exit 1; }

# Timestamp-based results folder
TS_DATE=$(date +%y%m%d)
TS_TIME=$(date +%H%M)
BASE_DIR="$(pwd)/D${TS_DATE}-T${TS_TIME}-${BENCH_NAME}-bench"
mkdir -p "$BASE_DIR"
LOG="$BASE_DIR/benchmark.log"

exec > >(tee -a "$LOG") 2>&1

START_TS=$(date "+%Y-%m-%d %H:%M")
echo ""
echo "============ START $START_TS ============"

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
        cmd=(/opt/homebrew/bin/copilot --allow-all-tools -p "$prompt")
        ;;
      claude-code)
        cmd=(/opt/homebrew/bin/claude -p --verbose --debug --output-format stream-json --include-partial-messages --permission-mode bypassPermissions "$prompt")
        ;;
    esac

    # Print command + live output
    echo "+ ${cmd[*]}"
    "${cmd[@]}" 2>&1 | tee agent.log

    if [[ "$agent" == "copilot-cli" ]]; then
      extra_logs=$(find "$dir" -maxdepth 1 -type f -name "*.log" \
        ! -name "agent.log" ! -name "compile.log" ! -name "runtime.log")
      if [[ -n "$extra_logs" ]]; then
        {
          echo ""
          echo "==== copilot debug log ===="
          cat $extra_logs
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

END_TS=$(date "+%Y-%m-%d %H:%M")
echo "============ END $END_TS ============"
