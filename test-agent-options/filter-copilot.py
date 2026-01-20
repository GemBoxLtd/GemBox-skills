import json, re, sys

path = sys.argv[1]
s = open(path, "r", encoding="utf-8", errors="replace").read()

# 1) File operations that Copilot logs as single lines.
for m in re.finditer(r'^\d{4}-\d\d-\d\dT.*\[(DEBUG|INFO|WARN|ERROR)\] (create:|edit:|write:|delete:)\s+(.*)$', s, re.M):
    lvl, op, p = m.group(1), m.group(2)[:-1], m.group(3)
    print(f"[FILE:{op.upper()}] {p}")

# 2) Extract JSON "chat.completion" blocks and print tool_calls.
#    We find '"object": "chat.completion"' blocks and parse the surrounding JSON object.
#    This regex is tuned to Copilot's pretty-printed JSON blocks in your log.
for m in re.finditer(r'^\d{4}-\d\d-\d\dT.*\[DEBUG\] \{\n(?:.*\n)*?^\}\s*$',
                     s, re.M):
    block = m.group(0)
    # Strip the log prefix from each line that starts with timestamp + [DEBUG]
    lines = []
    for line in block.splitlines():
        line = re.sub(r'^\d{4}-\d\d-\d\dT[^\]]+\]\s+\[DEBUG\]\s+', '', line)
        lines.append(line)
    jtxt = "\n".join(lines)

    try:
        obj = json.loads(jtxt)
    except Exception:
        continue

    if obj.get("object") != "chat.completion":
        continue

    for ch in obj.get("choices", []):
        msg = (ch.get("message") or {})
        for tc in (msg.get("tool_calls") or []):
            fn = ((tc.get("function") or {}).get("name")) or tc.get("name") or "unknown"
            args = (tc.get("function") or {}).get("arguments")
            if isinstance(args, str):
                a = args.strip().replace("\n", " ")
                if len(a) > 240: a = a[:240] + "…"
                print(f"[TOOL:{fn}] {a}")
            else:
                print(f"[TOOL:{fn}]")
