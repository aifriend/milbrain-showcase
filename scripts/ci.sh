#!/usr/bin/env bash
# CI gate for the milbrain showcase. Runs locally and in Actions: `bash scripts/ci.sh`
#
# This repo is the PUBLIC face of a private research project, published via GitHub Pages. Its failure modes
# are not the private repo's: nothing here executes, so there is nothing to import-smoke. What can actually
# go wrong is (1) a link that 404s for a reader, (2) malformed HTML on the served page, and (3) private
# material leaking out of the implementation repo. All three were being checked by hand on every push.
set -uo pipefail
cd "$(dirname "$0")/.."
PY="${PY:-python3}"
fail=0
step() { printf '\n=== %s ===\n' "$1"; }

step "1/3  relative links resolve (markdown + html)"
$PY - <<'PYEOF' || fail=1
import re, os, glob, sys
bad = n = 0
for f in sorted(glob.glob('**/*.md', recursive=True) + glob.glob('**/*.html', recursive=True)):
    base = os.path.dirname(f)
    src = open(f, encoding='utf-8').read()
    hrefs = ([h for _, h in re.findall(r'\[([^\]]+)\]\(([^)]+)\)', src)] if f.endswith('.md')
             else re.findall(r'(?:href|src)="([^"]+)"', src))
    for h in hrefs:
        if h.startswith(('http', '#', 'mailto', 'data:')):
            continue
        n += 1
        if not os.path.exists(os.path.normpath(os.path.join(base, h.split('#')[0]))):
            bad += 1
            print(f"  BROKEN {f} -> {h}")
print(f"  {n} relative links checked, {bad} broken")
sys.exit(1 if bad else 0)
PYEOF

step "2/3  served HTML is well-formed"
$PY - <<'PYEOF' || fail=1
from html.parser import HTMLParser
import glob, sys
VOID = {'br','img','meta','link','hr','input','source','path','circle','rect','line',
        'polyline','polygon','use','stop','feGaussianBlur','area','base','col','embed','track','wbr'}
bad = 0
class P(HTMLParser):
    def __init__(self): super().__init__(); self.stack=[]; self.err=[]
    def handle_starttag(self, t, a):
        if t not in VOID: self.stack.append(t)
    def handle_endtag(self, t):
        if t in VOID: return
        if self.stack and self.stack[-1] == t: self.stack.pop()
        elif t in self.stack:
            self.err.append(f"mismatched </{t}>, open={self.stack[-3:]}")
            while self.stack and self.stack.pop() != t: pass
        else: self.err.append(f"stray </{t}>")
for f in sorted(glob.glob('**/*.html', recursive=True)):
    p = P(); p.feed(open(f, encoding='utf-8').read())
    if p.err or p.stack:
        bad += 1
        print(f"  {f}: errors={p.err[:3]} unclosed_at_eof={p.stack[:5]}")
    else:
        print(f"  {f}: OK")
sys.exit(1 if bad else 0)
PYEOF

step "3/3  no private material leaked from the implementation repo"
# This repo states it contains theory, results and figures only — no code. These patterns are the ones that
# have actually needed checking by hand: local paths, cloud/infra identifiers, private-repo directories and
# module names, and secret-shaped strings. Kept narrow so a legitimate prose mention does not trip it.
PATTERNS='/Users/|/private/tmp|aifriend-481920|gs://|europe-west1|\.venv|scratchpad|extensions/(agency|grown_architecture)|deploy/gcp|[A-Za-z0-9_]+\.py\b|GATE_[a-z]|rung_[a-z]|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20}|BEGIN (RSA |OPENSSH )?PRIVATE KEY'
if git ls-files | xargs grep -nEI "$PATTERNS" 2>/dev/null | grep -v '^scripts/ci.sh:'; then
  echo "  LEAK: the lines above look like private-repo material in a public repo"
  fail=1
else
  echo "  clean — no local paths, infra identifiers, private module names or secret-shaped strings"
fi

printf '\n%s\n' "$([ $fail -eq 0 ] && echo 'CI PASSED' || echo 'CI FAILED')"
exit $fail
