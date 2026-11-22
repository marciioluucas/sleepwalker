---
name: sleepwalker
description: Use when the user says they are leaving, heading out, travelling, commuting, closing the laptop, putting the Mac in a backpack, or continuing from their phone — and whenever they ask to start/stop sleepwalker (swk), enable battery mode, change its settings, or check whether the Mac will stay awake with the lid closed.
---

# sleepwalker (`swk`)

This Mac runs `swk`: it stays awake with the lid closed **only while you (the agent) are working** or were active in the last `idle_min` minutes. Hooks already call `swk hook start|stop` — never call them yourself.

## When the user is about to leave

Reply in 1–3 short lines, before they go:

1. **Remote Control** — remind them to turn it on in this session (`/remote-control`); without it the phone can't reach the session. Skip if it's already on.
2. Run `swk status`.
   - `stopped` → `swk start`.
   - `not set up` → ask them to run `swk setup` in a terminal (needs their password once; you can't type it).
   - They'll be unplugged and battery mode is `off` → offer `swk battery on` (just run it if they already said so).
3. Hotspot only if relevant: iPhone Personal Hotspot on; the Mac hops over by itself (5 min offline tolerance).

## Commands you can run (no password)

| They ask | Run |
|---|---|
| status / will it stay awake? | `swk status` |
| start / stop | `swk start` / `swk stop` |
| backpack / battery mode | `swk battery on` / `swk battery off` |
| change a setting | `swk config set <key> <value>` (see `swk config list`) |
| slow down / stop slowing an app | `swk throttle add "<App>"` / `swk throttle remove "<App>"` |

`swk setup` and `swk uninstall` need the user's password — ask them to run those in a terminal.

## While working on the move

- Prefer light work (edits, specs, reviews). Warn before a long build or test suite on battery: a closed Mac in a bag heats up and drains fast.
- Work you leave running in the background after your turn ends doesn't count as activity; the Mac may sleep `idle_min` minutes later. For long jobs, keep the turn open or tell the user.
- If `swk status` warns that a phone is connected by USB while on battery, tell the user: charging the phone from the Mac drains it about 5× faster.
- Between your turns, with the lid closed, swk freezes chat/browser/music apps (`throttle_mode`). A browser you drive over CDP and anything you started stay untouched; if you need another app from the list, ask the user or `swk throttle remove "<App>"`.
