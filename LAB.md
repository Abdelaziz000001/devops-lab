# Fix the Belt — student lab

**Work in pairs. Everything happens in the github.com web editor — no terminal, no local Git, no installs.**

## Brief

This repo is the club site `ingeniums.club`. Someone set it up in a hurry and the belt is broken in four different ways — plus one problem the belt can never see.

First: open your fork, go to the **Actions** tab, and watch the last run. **What did the belt do that it should never do?**

Then fix the five missions below, in order.

---

## Mission 1 — the wiring

A belt must be an assembly line: `build` → `test` → `deploy`, in order. Right now the deploy gate isn't chained to anything.

Fix `.github/workflows/belt.yml` so that `deploy` waits for `test`, and `test` waits for `build`. Push and watch the next run: with a failing test, `deploy` must be **skipped**, never green.

<details><summary>HINTS — read only if stuck</summary>

1. Open `.github/workflows/belt.yml`. Which job is missing a `needs:` line?
2. Jobs chain with `needs:` — the value is the job they wait for.
3. Check the other jobs too: is `test` chained to `build`?

</details>

## Mission 2 — the missing truth

The test failure names a file. The site needs it. Create `config.js` in the web editor (**+ → New file**) with exactly:

```js
const CHECKIN_TIME = "09:30";
document.title = "ingeniums.club — check-in " + CHECKIN_TIME;
```

Push. The belt should go green. The repo is the truth, not your folder.

<details><summary>HINTS — read only if stuck</summary>

1. Read the red test log. What file does it name?
2. Create the file in the web UI with exactly that name.
3. Paste the content from the mission brief above.

</details>

## Mission 3 — the lying gate

The belt is green now — but look at the live page: `Check-in opens at 25:00`. The test never checks the time.

Open `tests/check_site.sh`, find the `TODO` comment, and add a check that the time after "opens at" is a valid `HH:MM` (hours 00–23, minutes 00–59). Push — **watch it fail**. Then fix the app (the time in `index.html`), push again, and confirm true green. The tab title should update too.

Green means *your checks* passed. Not that your app works.

<details><summary>HINTS — read only if stuck</summary>

1. The `TODO` comment in `tests/check_site.sh` marks the exact spot.
2. Extract the time with `grep -oE '[0-9]{2}:[0-9]{2}' index.html`, then compare hours ≤ 23 and minutes ≤ 59.
3. When the new check fails, the fix is in `index.html` — not in the test.

</details>

## Mission 4 — the invisible one

Everything is green. Inspect what is actually shipping: open the deployed `app.js` in your browser (`https://<you>.github.io/fix-the-belt/app.js`). Delete what you find. Then answer in your pair: **why did no gate catch this? What would a gate have to check to catch it?**

<details><summary>HINTS — read only if stuck</summary>

1. The deploy uploads the whole repo — open `app.js` on the live site.
2. Search the file for `PASSWORD`.
3. Delete the whole line, commit, and check the live URL again.

</details>

## Mission 5 — the slow death (observability)

Users report the site has been getting **slower since noon**. Nothing failed. The belt is green. The app ships with its own dashboard — click the **📊 status** link in the footer of the live site.

Watch the LIVE panel for a minute: what is the red counter doing? What is the response-time curve doing? Open the **latest error** panel — it names a file and a line. Go kill it in `app.js`, then come back and watch the counter freeze.

Note: the belt never turned red for this — and it never will. Some problems only exist in the running world.

<details><summary>HINTS — read only if stuck</summary>

1. Open 📊 status. Watch the red counter for 30 seconds. How fast is it growing?
2. The *latest error* panel names the file and the line. Open it.
3. Search `app.js` for `setInterval`.

</details>

---

## Completion checklist

- [ ] Belt green
- [ ] Deploy visibly chained after test in the Actions UI
- [ ] Live page shows a valid time
- [ ] Tab title updates (`ingeniums.club — check-in 09:30`)
- [ ] `app.js` on the live site contains no password
- [ ] LIVE error counter on the dashboard stops climbing after the fix (response-time curve flattens)

## Final reflection questions

1. Which mistake was the pipeline's fault, and which were the humans'?
2. Why can a green belt still ship a disaster?
3. Who should catch a secret: build, test, or deploy?
4. Mistake 5 was invisible to the belt — what did the dashboard show you that the belt could never show? Why did you need to read the **trend** and not just a red alert?
5. The dashboard lives *inside* the app. What happens to your eyes when the app dies completely — and where must the dashboard live in real production?
