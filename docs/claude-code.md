# sleepwalker + Claude Code

The best fit: Claude Code hooks tell `swk` exactly when Claude starts and stops working, and Remote Control lets you drive the session from your phone.

## 1. Install and set up

```bash
brew install marciioluucas/tap/sleepwalker
swk setup --agent claude --terminal Warp --claude-hooks   # use your terminal: iTerm, Ghostty, Terminal…
```

Using the **Claude desktop app** instead of a terminal? `swk setup --agent claude --app Claude`.

## 2. Hooks

`--claude-hooks` (or answering *yes* during `swk setup`) runs `swk integrate claude`, which merges these into `~/.claude/settings.json` — global, so every project gets them. Existing hooks are kept and a backup is written to `settings.json.bak-sleepwalker`. Running it twice is safe.

| Hook | Runs | Meaning |
|---|---|---|
| `UserPromptSubmit` | `swk hook start` | you sent a prompt — Claude is working |
| `Stop` | `swk hook stop` | Claude finished the turn — idle timer starts |
| `SessionEnd` | `swk hook stop` | session closed |

Each session is tracked by its `session_id`, so parallel sessions work fine. To see the snippet without touching your settings: `swk integrate claude --print`.

## 3. Skill: Claude reminds you before you leave

```bash
mkdir -p ~/.claude/skills/sleepwalker
cp "$(brew --prefix sleepwalker)/share/sleepwalker/skills/sleepwalker/SKILL.md" ~/.claude/skills/sleepwalker/
```

(From a git clone: `cp skills/sleepwalker/SKILL.md ~/.claude/skills/sleepwalker/`.)

Now when you say *"I'm heading out"*, *"continuing from my phone"*, *"closing the laptop"*, Claude:

1. reminds you to turn on **Remote Control** (`/remote-control`) in that session;
2. runs `swk status` and turns on battery mode if you'll be unplugged;
3. toggles swk when you ask from the phone (`swk start|stop|battery on|off` need no password).

Prefer a couple of lines over a skill? Add this to `~/.claude/CLAUDE.md`:

```markdown
## On the move (sleepwalker)
When I say I'm leaving, travelling or continuing from my phone, remind me in 1–2 lines to turn on
Remote Control (`/remote-control`) and check `swk status` (`swk battery on` if I'll be unplugged).
`swk start|stop|status|battery on|off` need no password — run them when I ask.
```

## 4. Test

```bash
swk status        # while Claude is replying: "activity  working (1 session(s))"
```

Plug in, give Claude a long task, close the lid — the Mac keeps going. Unplug with battery mode off — it sleeps within ~10 s.

**Tip:** to have every session reachable from the phone, set `"remoteControlAtStartup": true` in `~/.claude/settings.json`.

**Limitation:** work Claude leaves running in the background *after* its turn ends doesn't count as activity — the Mac may sleep `idle_min` minutes later. Raise `swk config set idle_min 60` if you often do that.
