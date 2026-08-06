# EOM Tracker — TUI Keybindings Reference

All keybindings are global (active regardless of which pane has focus),
except where noted.

## Navigation

| Key | Action |
|---|---|
| `↑` / `k` | Move selection up in focused list |
| `↓` / `j` | Move selection down in focused list |
| `Tab` | Cycle focus: Epics → Stories → Subtasks → Epics |

## CRUD

| Key | Action | Context |
|---|---|---|
| `n` | **New** item | Creates at the focused level (Epic / Story / Subtask) |
| `e` | **Edit** focused item | Pre-populates form with current values |
| `D` (capital) | **Delete** focused item | Prompts for confirmation; cascades children |

## Status & Linking

| Key | Action |
|---|---|
| `d` | Cycle status forward: `todo → in_progress → done` |
| `b` | Link a git branch to the focused **story** (pre-fills current branch) |

## Comments (subtasks only)

| Key | Action |
|---|---|
| `c` | **Add** a comment to the focused **subtask** (prompts for body + author) |
| `v` | **View** all comments on the focused **subtask** (popup; `q`/`Esc` to close) |

Subtasks with comments show a `💬N` badge (indigo) next to their title in the
subtask list, where `N` is the comment count.

## App

| Key | Action |
|---|---|
| `q` | Quit |
| `Ctrl+C` | Force quit |

---

## Pane layout

```
┌─────────────┬──────────────────────────────┬───────────────────────────┐
│   Epics     │         Stories              │          Detail           │
│  (25% wide) │        (40% wide)            │        (35% wide)         │
│             │                              │  key / title / meta       │
│ EOM-E1 …   │ P1 TODO  EOM-S1 …           │  status / priority        │
│ EOM-E2 …   │ P2 DONE  EOM-S2 …           │  branch / description     │
│             │                              │                           │
│             │                              │  ── Subtasks ──           │
│             │                              │  · EOM-T1 …              │
│             │                              │  ✓ EOM-T2 … 💬3          │
└─────────────┴──────────────────────────────┴───────────────────────────┘
  [Tab focus]        [Tab focus]                   [Tab focus]
```

## Status & priority colour codes

| Value | Colour |
|---|---|
| `todo` | Slate grey |
| `in_progress` | Amber |
| `done` | Sage green |
| `p1` | Red |
| `p2` | Amber |
| `p3` | Grey |
