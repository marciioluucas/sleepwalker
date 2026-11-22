# 🌙 sleepwalker

**Close the lid. Your Mac keeps coding.**

`swk` keeps your MacBook awake — lid closed, in your backpack — **only while your AI coding agent is working**. You drive the agent from your phone while you're on the move; when it goes idle, sleep comes back on its own.

Built for people who use **Claude Code with Remote Control** and need to keep working from the phone on the bus, in the Uber, in the airport line. Works with Codex, Gemini CLI, Aider, OpenCode, desktop apps and more.

```
📱 you ──► agent (Claude Code + Remote Control) ──► 💻 Mac, lid closed, in the backpack
                                                     └─ swk: "agent is working — don't sleep"
```

## Why

macOS puts a closed MacBook to sleep, period. `caffeinate` doesn't beat lid-close sleep, and keep-awake apps hold the Mac up whether or not anything useful is happening — hello, hot Mac and dead battery at the bottom of the bag.

sleepwalker is wired to the agent itself:

| Situation | What happens |
|---|---|
| Agent working, or active in the last 30 min — on AC | stays awake, lid open or closed |
| Same, on battery, with battery mode on | stays awake **and saves power**: Low Power Mode; chat/browser/music apps frozen between turns (lid closed), heavy processes slowed down. Whatever the agent started — and a browser it drives over CDP — runs at full speed |
| Agent idle for 30 min | normal sleep returns; lid closed → sleeps right away |
| Battery ≤ 15%, offline > 5 min, battery ≥ 45 °C, macOS thermal warning | lets the Mac sleep |
| External display attached (desk, clamshell) | hands off — macOS decides, as usual |
| You plug in / agent stops | every tweak is undone automatically |

## Install

```bash
brew install marciioluucas/tap/sleepwalker
swk setup
```

<details><summary>Without Homebrew</summary>

```bash
git clone https://github.com/marciioluucas/sleepwalker ~/.sleepwalker
~/.sleepwalker/install.sh      # links swk into ~/.local/bin
swk setup
```
</details>

`swk setup` asks which agent you use, which terminal (or desktop app) it runs in, and whether to stay awake on battery. Then it asks for your password **once**: it installs a small root daemon and a sudoers rule that allows exactly `sleepwalker-root start|stop` without a password, so the agent — and therefore your phone — can toggle it. Nothing else gets root.

Non-interactive:

```bash
swk setup --agent claude --terminal Warp --battery on --claude-hooks
swk setup --agent codex --terminal iTerm --yes
swk setup --agent claude --app Claude --yes          # Claude desktop app
```

Agent guides: **[Claude Code](docs/claude-code.md)** · **[Codex, Gemini, Aider, OpenCode, desktop apps…](docs/other-agents.md)**

## Usage

```
swk status [--json]          what's happening right now
swk start | stop | restart   no password after setup
swk battery on|off           stay awake on battery too (backpack mode)
swk config list              every setting, with its current value
swk config set <key> <value>
swk throttle add "Some App"  slow this app down on battery
swk --help                   (also: swk <command> --help)
```

From your phone, just ask your agent: *"turn on swk battery mode"*, *"swk status"*, *"stop sleepwalker"*.

### Settings

All set from the command line (`swk config set <key> <value>`), stored in `~/.config/sleepwalker/config`, read live by the daemon — no restart needed.

| Key | Default | |
|---|---|---|
| `agent` | `claude` | agent CLI process name |
| `app` | — | desktop app the agent runs in (`Claude`, `ChatGPT`, `Codex`, `Cursor`…) |
| `terminal` | — | terminal the agent runs in; never slowed down |
| `battery` | `off` | stay awake on battery too |
| `low_power` | `on` | Low Power Mode while held awake on battery (turn it off by hand and swk respects it until the session ends) |
| `throttle` | `on` | slow down other apps / heavy processes on battery |
| `throttle_mode` | `suspend` | `suspend`: freeze the apps in the throttle list while the lid is closed and the agent is between turns (VMs like OrbStack/Docker are only slowed); `nice`: background priority only |
| `idle_min` | `30` | minutes without activity before sleep comes back |
| `battery_min` | `15` | never hold awake at or below this % |
| `offline_grace` | `5` | minutes offline tolerated (time to hop to a hotspot) |
| `cpu_throttle` | `20` | on battery, slow down other processes above this % CPU |
| `active_cpu` | `0` | agent CPU % that counts as activity — for agents without hooks (`setup` sets 5 for them) |
| `temp_max` | `45` | let the Mac sleep when the battery reaches this °C (`0` = off) |
| `wake_grace` | `3` | minutes after a wake before swk may put a closed Mac back to sleep — lets a message from your phone land |

### On-the-move checklist

1. Turn on **Remote Control** in the session you'll use (Claude Code: `/remote-control`).
2. `swk battery on` if you'll be unplugged.
3. iPhone **Personal Hotspot** on. On the Mac, once: *System Settings → Wi-Fi → Ask to join hotspots → Automatic*. swk tolerates 5 min offline while it hops over.
4. Close the lid. Go.

## How it works

- A root `launchd` daemon runs every 10 s and flips `pmset disablesleep` — the only switch that beats lid-close sleep.
- **Activity** comes from agent hooks (`swk hook start` / `swk hook stop`) or, for agents without hooks, from the agent's own CPU use.
- **Battery saver**: Low Power Mode; the apps in your throttle list are frozen (`SIGSTOP`, whole app at once) while the lid is closed and the agent is between turns, otherwise put at background priority (`taskpolicy -b`), like any other process above `cpu_throttle`% CPU. Never touched: the agent's process tree (including what it started earlier and left running), its parents, your terminal, the agent's app and any browser running with remote debugging (CDP automation). Opening the lid or the agent's next prompt unfreezes everything at once. Everything is reverted when the condition ends — Low Power Mode is only turned off if swk turned it on.
- **Sleep**: swk only forces sleep on a Mac it was holding awake — never on a Mac on an external display, never within `wake_grace` minutes of a wake. `swk status` also warns when a phone is charging from the Mac on battery (≈5× the drain, measured).
- The daemon is a root-owned copy in `/usr/local/libexec/sleepwalker`; it reads your config as plain validated values and never executes files from your home folder.

## Security

- **Zero third-party dependencies.** Plain Bash plus tools that ship with macOS (`pmset`, `launchctl`, `taskpolicy`, `ioreg`, `ps`, `sed`, `awk`, `osascript`). No package manager pulls anything at install or run time — nothing upstream to compromise.
- **Smallest possible root surface.** One sudoers line allows only `sleepwalker-root start|stop`. Both root scripts are copied to `/usr/local/libexec/sleepwalker`, owned by root, and never read code from your home folder.
- **Config is data, not code.** The daemon parses `~/.config/sleepwalker/config` line by line and validates every value (numbers, `on|off`, or names limited to `[A-Za-z0-9 ._+-]`); it never `source`s it.
- Short enough to audit in one sitting: `bin/swk`, `libexec/sleepwalker-daemon`, `libexec/sleepwalker-root`.

## Caveats

- **Heat.** A closed Mac in a bag can't breathe. The thermal guard covers extremes, but prefer light work on the move (specs, edits, reviews) over long builds.
- **Signal.** Offline for more than 5 min → the Mac sleeps and the remote session drops. Open the lid to resume.
- macOS only. Tested on Apple Silicon, macOS 26.

## Uninstall

```bash
swk uninstall && brew uninstall sleepwalker
```

---

### 🇧🇷 Em português

**Feche a tampa. O Mac continua codando.** O `swk` mantém o MacBook acordado — de tampa fechada, na mochila — **só enquanto seu agente de IA está trabalhando**. Perfeito pra quem usa Claude Code com Remote Control e precisa trabalhar pelo celular enquanto se move. Ficou 30 min parado, o sono volta sozinho; na bateria, liga o Modo de Pouca Energia e freia os outros apps, sem tocar no que o agente está rodando. Mesmos comandos acima.

## License

[MIT](LICENSE)
