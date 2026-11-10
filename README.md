# Fix the Belt — facilitator answer key

A beginner lab: students fork one public repo and fix **5 planted mistakes** in pairs, entirely in the github.com web UI. Four are pipeline/app mistakes; the fifth is invisible to the pipeline by design and is only discoverable through the observability dashboard built into the app (`status.html` + `monitor.js`).

## One-time setup

1. Create a **public** repo on github.com, e.g. `fix-the-belt`. (Public = free Actions + free Pages, no credit card.)
2. Push these files once from a terminal:

   ```bash
   git init -b main
   chmod +x tests/check_site.sh        # build checks the executable bit
   git add -A
   git commit -m "the belt (broken on purpose)"
   git remote add origin https://github.com/<you>/fix-the-belt.git
   git push -u origin main
   ```

3. **Settings → Pages → Source: GitHub Actions.** (Required on GitHub — unlike GitLab there is a toggle.)
4. Optionally mark the repo as a **Template repository** (Settings → General → Template repository) so each pair clicks "Use this template" instead of forking — cleaner, and each pair gets its own Pages site.
5. Students: create the repo from the template/fork, then **Settings → Pages → Source: GitHub Actions** in their own repo.
6. Verify the **expected first-run state** (this is the jaw-drop, check it before class):
   - `build` ✅, `test` ❌ — the FAIL line names `config.js`, `deploy` ✅ **anyway** → the broken site is live on Pages while the belt is red.
   - Site live at `https://<student>.github.io/fix-the-belt/`

Timing: ~25–35 min for pairs. Students need GitHub accounts created beforehand.
Reset between classes: students always start from a fresh template/fork — never reuse a fixed repo.

## Answer key

### Mission 1 — wiring (`.github/workflows/belt.yml`)
Add the missing chain:

```yaml
  test:
    needs: build        # already present
  deploy:
    needs: test         # <-- the fix
```

After the fix, any run with a failing test shows `deploy` as skipped. (Note: `deploy` also needs `actions/checkout@v4` before `upload-pages-artifact` — it is already in the file.)

### Mission 2 — missing truth
Create `config.js` with:

```js
const CHECKIN_TIME = "09:30";
document.title = "ingeniums.club — check-in " + CHECKIN_TIME;
```

Belt goes green; tab title becomes `ingeniums.club — check-in 09:30`.

### Mission 3 — the lying gate
Students add a time check at the `TODO` in `tests/check_site.sh`, e.g.:

```bash
time=$(grep -oE 'Check-in opens at [0-9]{2}:[0-9]{2}' index.html | grep -oE '[0-9]{2}:[0-9]{2}')
hh=${time%%:*}; mm=${time##*:}
if [ -n "$time" ] && [ "$hh" -le 23 ] && [ "$mm" -le 59 ]; then
  pass "check-in time '$time' is a valid HH:MM"
else
  fail "check-in time '$time' is not a valid HH:MM (00:00-23:59)"
fi
```

This fails on `25:00` (red belt). Then fix `index.html`: `25:00` → `09:00` (or any valid time). True green.

### Mission 4 — the secret
Delete the line `const DB_PASSWORD = "s3cret-PROD-2026!";` from `app.js`. Before the fix it is readable at the live `app.js` URL; after, it is gone. Discussion answer: no gate caught it because no check looked for it — a pipeline only catches what you teach it to check. (A real fix is a scanning step, e.g. gitleaks/trufflehog, or GitHub secret scanning — next session.)

### Mission 5 — the slow death
Delete the whole `setInterval` block in `app.js` (lines 6–8). Accept also adding the missing `live-visitor-counter` element, but the debrief must say it: **the code was dead — deleting beats repairing.**
The dashboard's latest-error panel points at `app.js:7` (`document.getElementById("live-visitor-counter")...` → `TypeError: Cannot set properties of null`). After the fix the LIVE counter freezes and the response-time curve flattens — and the belt was green the entire time.

Debrief line: *"This is the incident game in miniature: dashboard trend + latest-error signpost + code reading. The belt had nothing to say about it — the belt ends at production. The lights begin where the belt ends."*

Reflection Q5 follow-up: the in-app dashboard dies with the app — in real production the watcher reports to a **separate** collector. That is exactly why Sentry, Prometheus and Datadog exist as independent products.

## Verification checklist (run once before class, in a scratch fork)

- [ ] First push: `build` ✅, `test` ❌ (names `config.js`), `deploy` ✅ anyway — broken version live while the belt is red
- [ ] Adding `needs: test` to `deploy`: a failing-test run shows `deploy` skipped
- [ ] Creating `config.js` → belt green → live page still shows `25:00`
- [ ] Adding the time check → red on `25:00`; fixing the time → true green, tab title updates
- [ ] `app.js` password readable at the live URL before mission 4, gone after
- [ ] `status.html` reachable from the footer link; HISTORY chart is a curve starting at the 11:58 marker, footer says "simulated snapshot"
- [ ] Before the mission-5 fix: LIVE counter climbs ~1/second, response-time curve visibly rising within 2 min, latest error names `app.js:7`
- [ ] After the fix: counter freezes, curve flattens, and the belt never turned red for mistake 5
- [ ] No external services/CDNs/accounts anywhere; all 5 fixes doable in the web UI only
- [ ] Fake password is obviously fake; no real secrets anywhere
- [ ] LAB.md hints never give the answer outright — the last hint stops one step short
- [ ] Total pipeline runtime under ~3 minutes per push
