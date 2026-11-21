# sleepwalker + other agents

`swk` needs two things from an agent: **is it running?** and **is it working?**

- *Running* — `swk config set agent <process>` (CLI) and/or `swk config set app <App>` (desktop app, as in `/Applications/<App>.app`).
- *Working* — either the agent calls `swk hook start` / `swk hook stop` (best), or swk watches the agent's CPU (`active_cpu`, set to 5% by `swk setup` for agents without hooks).

Tell swk your terminal too (`swk config set terminal iTerm`) so it's never slowed down on battery. swk already protects the agent's parent processes, so this is a belt-and-braces setting.

## Quick setups

| Agent | Command |
|---|---|
| OpenAI Codex CLI | `swk setup --agent codex --terminal <YourTerminal>` |
| Gemini CLI | `swk setup --agent gemini --terminal <YourTerminal>` |
| Aider | `swk setup --agent aider --terminal <YourTerminal>` |
| OpenCode | `swk setup --agent opencode --terminal <YourTerminal>` |
| Cursor Agent CLI | `swk setup --agent cursor-agent --terminal <YourTerminal>` |
| Goose | `swk setup --agent goose --terminal <YourTerminal>` |
| Claude desktop app | `swk setup --agent claude --app Claude` |
| ChatGPT / Codex desktop app | `swk setup --agent codex --app ChatGPT` (or `--app Codex`) |
| Cursor (editor agent) | `swk setup --agent cursor-agent --app Cursor` |

Not sure about the process name? Start the agent and run `ps -Ao comm | sort -u | grep -i <name>`; use the last path segment.

## Wiring hooks (when your agent has them)

If your tool can run a shell command when a task/turn **starts** and when it **ends**, wire:

```bash
swk hook start   # turn started
swk hook stop    # turn finished / session closed
```

Once hooks are in place, turn off CPU detection so an idle-but-open agent doesn't keep the Mac up: `swk config set active_cpu 0`.

Agents that pass a JSON payload with a `session_id` on stdin (like Claude Code) get per-session tracking for free; otherwise all calls share one "manual" session — fine for a single agent.

Hook support changes fast between tools and versions — check your agent's docs for "hooks", "notify", or "lifecycle events". If it only offers an *end-of-turn* notification, wire just `swk hook stop`: it refreshes the idle timer, and CPU detection covers the working part.

## No hooks at all

CPU detection alone works: while the agent is busy (≥ `active_cpu`%), swk counts it as activity and keeps the Mac awake; `idle_min` minutes after it calms down, sleep returns. Tune it:

```bash
swk config set active_cpu 8     # higher = less sensitive
swk config set idle_min 20
```

## Telling your agent about swk

Paste into your agent's instructions file (`AGENTS.md`, `GEMINI.md`, `.cursorrules`, …):

```markdown
## On the move (sleepwalker)
This Mac runs `swk` (sleepwalker): it stays awake with the lid closed while you work.
When I say I'm leaving or continuing from my phone, run `swk status` and offer `swk battery on`
if I'll be unplugged. `swk start|stop|status|battery on|off` need no password — run them when I ask.
Warn me before long builds on battery: a closed Mac in a bag heats up and drains fast.
```
