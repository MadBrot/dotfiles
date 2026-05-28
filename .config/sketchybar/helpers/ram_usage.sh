#!/bin/bash
page=$(vm_stat | awk '/page size of/ { print $8 }')
used=$(vm_stat | awk '
  /Pages active/              { a = $3 + 0 }
  /Pages wired down/          { w = $4 + 0 }
  /Pages occupied by compressor/ { c = $5 + 0 }
  END { print a + w + c }
')
total=$(sysctl -n hw.memsize)
pct=$(( used * page * 100 / total ))
gb=$(echo "scale=1; $used * $page / 1073741824" | bc)
echo "$pct $gb"
