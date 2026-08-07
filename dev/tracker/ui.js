// ui.js — blessed TUI for EOM Tracker
'use strict';

const blessed = require('blessed');
const { Epics, Stories, Subtasks, Comments } = require('./db');

// ── Palette (matches EOM's Epistemic Calm design) ────────────────────────────
const COLORS = {
  bg:           '#1A1C23',
  surface:      '#242731',
  border:       '#3A3E4A',
  text:         '#E2E8F0',
  textDim:      '#94A3B8',
  accent:       '#6366F1',   // muted indigo
  accentDim:    '#4B4E75',
  done:         '#34D399',   // sage green
  inProgress:   '#FBBF24',   // amber
  todo:         '#94A3B8',   // slate
  p1:           '#F87171',   // red
  p2:           '#FBBF24',   // amber
  p3:           '#6B7280',   // grey
  selected:     '#2E3250',
};

const STATUS_CYCLE = ['todo', 'in_progress', 'done'];
const STATUS_LABEL = { todo: 'TODO', in_progress: 'IN PROG', done: 'DONE' };
const STATUS_COLOR = { todo: COLORS.todo, in_progress: COLORS.inProgress, done: COLORS.done };
const PRIORITY_LABEL = { p1: 'P1', p2: 'P2', p3: 'P3' };
const PRIORITY_COLOR = { p1: COLORS.p1, p2: COLORS.p2, p3: COLORS.p3 };

// ── State ─────────────────────────────────────────────────────────────────────
let state = {
  epics: [],
  stories: [],
  subtasks: [],
  epicIdx: 0,
  storyIdx: 0,
  subtaskIdx: 0,
  focus: 'epics',   // 'epics' | 'stories' | 'subtasks'
  branch: '',
};

// ── Helpers ───────────────────────────────────────────────────────────────────
function colorTag(color, text) {
  return `{${color}-fg}${text}{/}`;
}

function statusTag(status) {
  return colorTag(STATUS_COLOR[status] || COLORS.textDim, STATUS_LABEL[status] || status);
}

function priorityTag(p) {
  return colorTag(PRIORITY_COLOR[p] || COLORS.textDim, PRIORITY_LABEL[p] || p);
}

function epicProgress(epicId) {
  const stories = Stories.forEpic(epicId);
  if (!stories.length) return '';
  const done = stories.filter(s => s.status === 'done').length;
  return `${done}/${stories.length}`;
}

// ── Prompt helpers ────────────────────────────────────────────────────────────
function prompt(screen, title, fields, cb) {
  const form = blessed.form({
    parent: screen,
    top: 'center',
    left: 'center',
    width: 70,
    height: fields.length * 4 + 6,
    border: { type: 'line', fg: COLORS.accent },
    style: { bg: COLORS.surface, fg: COLORS.text },
    keys: true,
    mouse: true,
    label: ` ${title} `,
  });

  const inputs = {};
  fields.forEach((f, i) => {
    blessed.text({
      parent: form,
      top: i * 4 + 1,
      left: 2,
      content: f.label + ':',
      style: { fg: COLORS.textDim, bg: COLORS.surface },
    });
    inputs[f.key] = blessed.textbox({
      parent: form,
      top: i * 4 + 2,
      left: 2,
      width: form.width - 6,
      height: 1,
      inputOnFocus: true,
      style: {
        bg: COLORS.bg,
        fg: COLORS.text,
        focus: { bg: COLORS.selected },
      },
      value: f.default || '',
    });
  });

  const submitBtn = blessed.button({
    parent: form,
    bottom: 1,
    right: 10,
    width: 10,
    height: 1,
    content: '  Save  ',
    style: { bg: COLORS.accent, fg: COLORS.text, hover: { bg: COLORS.accentDim } },
    mouse: true,
  });

  const cancelBtn = blessed.button({
    parent: form,
    bottom: 1,
    right: 22,
    width: 10,
    height: 1,
    content: ' Cancel ',
    style: { bg: COLORS.border, fg: COLORS.text },
    mouse: true,
  });

  function collect() {
    const result = {};
    fields.forEach(f => { result[f.key] = inputs[f.key].getValue(); });
    return result;
  }

  submitBtn.on('press', () => { form.destroy(); screen.render(); cb(collect()); });
  cancelBtn.on('press', () => { form.destroy(); screen.render(); cb(null); });

  form.key(['escape'], () => { form.destroy(); screen.render(); cb(null); });
  form.key(['enter'], () => { form.destroy(); screen.render(); cb(collect()); });

  screen.append(form);
  form.focus();
  inputs[fields[0].key].focus();
  screen.render();
}

function confirm(screen, message, cb) {
  const box = blessed.question({
    parent: screen,
    top: 'center',
    left: 'center',
    width: 50,
    height: 7,
    border: { type: 'line', fg: COLORS.p1 },
    style: { bg: COLORS.surface, fg: COLORS.text },
    label: ' Confirm ',
  });
  box.ask(message, (err, val) => {
    box.destroy();
    screen.render();
    cb(val);
  });
  screen.render();
}

// ── Main TUI ──────────────────────────────────────────────────────────────────
function launchTUI({ branch }) {
  state.branch = branch;

  const screen = blessed.screen({
    smartCSR: true,
    title: 'EOM Tracker',
    fullUnicode: true,
    dockBorders: true,
  });

  // ── Layout ──────────────────────────────────────────────────────────────────

  // Header bar
  const header = blessed.box({
    parent: screen,
    top: 0,
    left: 0,
    width: '100%',
    height: 1,
    content:
      ` {bold}EOM Tracker{/bold}   ` +
      colorTag(COLORS.textDim, `branch: ${branch || '(none)'}`) +
      `   {right}` +
      colorTag(COLORS.textDim, `[Tab] focus  [n] new  [e] edit  [d] cycle  [b] branch  [c] comment  [v] view  [r] reload  [D] delete  [q] quit `) ,
    tags: true,
    style: { bg: COLORS.surface, fg: COLORS.text },
  });

  // Footer / status bar
  const footer = blessed.box({
    parent: screen,
    bottom: 0,
    left: 0,
    width: '100%',
    height: 1,
    content: '',
    tags: true,
    style: { bg: COLORS.surface, fg: COLORS.textDim },
  });

  // Left: Epic list
  const epicPanel = blessed.list({
    parent: screen,
    top: 1,
    left: 0,
    width: '25%',
    bottom: 1,
    border: { type: 'line' },
    label: ' Epics ',
    tags: true,
    scrollable: true,
    keys: true,
    vi: true,
    mouse: true,
    style: {
      bg: COLORS.bg,
      fg: COLORS.text,
      border: { fg: COLORS.border },
      label: { fg: COLORS.textDim },
      selected: { bg: COLORS.selected, fg: COLORS.text },
      item: { fg: COLORS.text },
    },
  });

  // Center: Story list
  const storyPanel = blessed.list({
    parent: screen,
    top: 1,
    left: '25%',
    width: '40%',
    bottom: 1,
    border: { type: 'line' },
    label: ' Stories ',
    tags: true,
    scrollable: true,
    keys: true,
    vi: true,
    mouse: true,
    style: {
      bg: COLORS.bg,
      fg: COLORS.text,
      border: { fg: COLORS.border },
      label: { fg: COLORS.textDim },
      selected: { bg: COLORS.selected, fg: COLORS.text },
      item: { fg: COLORS.text },
    },
  });

  // Right: Detail panel
  const detailPanel = blessed.box({
    parent: screen,
    top: 1,
    right: 0,
    width: '35%',
    bottom: 1,
    border: { type: 'line' },
    label: ' Detail ',
    tags: true,
    scrollable: true,
    alwaysScroll: true,
    keys: true,
    mouse: true,
    style: {
      bg: COLORS.bg,
      fg: COLORS.text,
      border: { fg: COLORS.border },
      label: { fg: COLORS.textDim },
    },
  });

  // Subtask list embedded inside the detail panel
  const subtaskList = blessed.list({
    parent: screen,
    top: 1,
    right: 0,
    width: '35%',
    height: 0,  // hidden initially
    border: { type: 'line' },
    label: ' Subtasks ',
    tags: true,
    scrollable: true,
    keys: true,
    vi: true,
    mouse: true,
    style: {
      bg: COLORS.bg,
      fg: COLORS.text,
      border: { fg: COLORS.border },
      label: { fg: COLORS.textDim },
      selected: { bg: COLORS.selected, fg: COLORS.text },
    },
  });

  // ── Data refresh ────────────────────────────────────────────────────────────

  function loadEpics() {
    state.epics = Epics.all();
    const items = state.epics.map(e => {
      const prog = epicProgress(e.id);
      const tag = statusTag(e.status);
      return ` ${tag}  ${e.key}  ${e.title} ${colorTag(COLORS.textDim, prog ? `(${prog})` : '')}`;
    });
    epicPanel.setItems(items.length ? items : [colorTag(COLORS.textDim, '  (no epics)')]);
    if (state.epicIdx >= state.epics.length) state.epicIdx = Math.max(0, state.epics.length - 1);
    epicPanel.select(state.epicIdx);
  }

  function loadStories() {
    const epic = state.epics[state.epicIdx];
    state.stories = epic ? Stories.forEpic(epic.id) : [];
    const items = state.stories.map(s => {
      return ` ${priorityTag(s.priority)} ${statusTag(s.status)}  ${s.key}  ${s.title}`;
    });
    storyPanel.setItems(items.length ? items : [colorTag(COLORS.textDim, '  (no stories)')]);
    storyPanel.setLabel(` Stories ${epic ? `— ${epic.title}` : ''} `);
    if (state.storyIdx >= state.stories.length) state.storyIdx = Math.max(0, state.stories.length - 1);
    storyPanel.select(state.storyIdx);
    loadDetail();
  }

  function loadDetail() {
    const story = state.stories[state.storyIdx];
    if (!story) {
      detailPanel.setContent(colorTag(COLORS.textDim, ' Select a story to view details.'));
      subtaskList.height = 0;
      subtaskList.hide();
      screen.render();
      return;
    }

    state.subtasks = Subtasks.forStory(story.id);

    const lines = [
      ` {bold}${story.key}{/bold}  ${story.title}`,
      ``,
      ` Status:   ${statusTag(story.status)}`,
      ` Priority: ${priorityTag(story.priority)}`,
      ` Branch:   ${colorTag(COLORS.accent, story.branch || '(none)')}`,
      ` Updated:  ${colorTag(COLORS.textDim, story.updated_at || '—')}`,
      ``,
      story.description
        ? ` ${colorTag(COLORS.textDim, story.description)}`
        : ` ${colorTag(COLORS.textDim, '(no description)')}`,
      ``,
      ` {underline}Subtasks (${state.subtasks.length}){/underline}`,
    ];
    detailPanel.setContent(lines.join('\n'));

    // Subtask list (shown below detail or overlaid)
    const DETAIL_HEADER_LINES = lines.length + 2;
    const subtaskItems = state.subtasks.map(t => {
      const check = t.status === 'done' ? colorTag(COLORS.done, '✓') : colorTag(COLORS.textDim, '·');
      const nComments = Comments.count(t.id);
      const commentTag = nComments > 0
        ? ' ' + colorTag(COLORS.accent, `💬${nComments}`)
        : '';
      return ` ${check}  ${statusTag(t.status)}  ${t.key}  ${t.title}${commentTag}`;
    });

    if (state.subtasks.length > 0) {
      subtaskList.setItems(subtaskItems);
      subtaskList.show();
      // Position subtask list at bottom of right column
      const detailHeight = screen.height - DETAIL_HEADER_LINES - 2;
      subtaskList.height = Math.min(state.subtasks.length + 2, Math.max(5, detailHeight));
      subtaskList.top = screen.height - subtaskList.height - 1;
      if (state.subtaskIdx >= state.subtasks.length)
        state.subtaskIdx = Math.max(0, state.subtasks.length - 1);
      subtaskList.select(state.subtaskIdx);
    } else {
      subtaskList.setItems([colorTag(COLORS.textDim, '  (no subtasks)')]);
      subtaskList.height = 3;
      subtaskList.top = screen.height - 4;
      subtaskList.show();
    }

    screen.render();
  }

  function refreshAll() {
    loadEpics();
    loadStories();
    screen.render();
  }

  function setStatus(msg, color) {
    footer.setContent(` ${colorTag(color || COLORS.textDim, msg)}`);
    screen.render();
  }

  // ── Focus management ─────────────────────────────────────────────────────────

  function focusBorder(panel, active) {
    panel.style.border.fg = active ? COLORS.accent : COLORS.border;
    panel.style.label.fg = active ? COLORS.text : COLORS.textDim;
  }

  function applyFocus() {
    focusBorder(epicPanel, state.focus === 'epics');
    focusBorder(storyPanel, state.focus === 'stories');
    focusBorder(detailPanel, state.focus === 'subtasks');
    focusBorder(subtaskList, state.focus === 'subtasks');

    if (state.focus === 'epics') epicPanel.focus();
    else if (state.focus === 'stories') storyPanel.focus();
    else subtaskList.focus();

    screen.render();
  }

  function cycleTab() {
    if (state.focus === 'epics') state.focus = 'stories';
    else if (state.focus === 'stories') state.focus = state.subtasks.length ? 'subtasks' : 'epics';
    else state.focus = 'epics';
    applyFocus();
  }

  // ── Status cycle ─────────────────────────────────────────────────────────────

  function cycleStatus() {
    if (state.focus === 'epics') {
      const epic = state.epics[state.epicIdx];
      if (!epic) return;
      const next = STATUS_CYCLE[(STATUS_CYCLE.indexOf(epic.status) + 1) % STATUS_CYCLE.length];
      Epics.update(epic.id, { status: next });
      setStatus(`Epic status → ${next}`, STATUS_COLOR[next]);
      refreshAll();

    } else if (state.focus === 'stories') {
      const story = state.stories[state.storyIdx];
      if (!story) return;
      const next = STATUS_CYCLE[(STATUS_CYCLE.indexOf(story.status) + 1) % STATUS_CYCLE.length];
      Stories.update(story.id, { status: next });
      setStatus(`Story status → ${next}`, STATUS_COLOR[next]);
      refreshAll();

    } else {
      const subtask = state.subtasks[state.subtaskIdx];
      if (!subtask) return;
      const next = STATUS_CYCLE[(STATUS_CYCLE.indexOf(subtask.status) + 1) % STATUS_CYCLE.length];
      Subtasks.update(subtask.id, { status: next });
      setStatus(`Subtask status → ${next}`, STATUS_COLOR[next]);
      loadDetail();
    }
  }

  // ── New item ──────────────────────────────────────────────────────────────────

  function createNew() {
    if (state.focus === 'epics') {
      prompt(screen, 'New Epic', [
        { key: 'title', label: 'Title' },
        { key: 'description', label: 'Description' },
      ], data => {
        if (!data || !data.title.trim()) return;
        Epics.create({ title: data.title.trim(), description: data.description.trim() });
        setStatus('Epic created', COLORS.done);
        refreshAll();
      });

    } else if (state.focus === 'stories') {
      const epic = state.epics[state.epicIdx];
      if (!epic) { setStatus('Select an epic first', COLORS.p1); return; }
      prompt(screen, `New Story — ${epic.title}`, [
        { key: 'title', label: 'Title' },
        { key: 'description', label: 'Description' },
        { key: 'priority', label: 'Priority (p1/p2/p3)', default: 'p2' },
      ], data => {
        if (!data || !data.title.trim()) return;
        const priority = ['p1', 'p2', 'p3'].includes(data.priority) ? data.priority : 'p2';
        Stories.create({
          epicId: epic.id,
          title: data.title.trim(),
          description: data.description.trim(),
          priority,
        });
        setStatus('Story created', COLORS.done);
        refreshAll();
      });

    } else {
      const story = state.stories[state.storyIdx];
      if (!story) { setStatus('Select a story first', COLORS.p1); return; }
      prompt(screen, `New Subtask — ${story.title}`, [
        { key: 'title', label: 'Title' },
      ], data => {
        if (!data || !data.title.trim()) return;
        Subtasks.create({ storyId: story.id, title: data.title.trim() });
        setStatus('Subtask created', COLORS.done);
        loadDetail();
      });
    }
  }

  // ── Edit item ─────────────────────────────────────────────────────────────────

  function editCurrent() {
    if (state.focus === 'epics') {
      const epic = state.epics[state.epicIdx];
      if (!epic) return;
      prompt(screen, `Edit Epic — ${epic.key}`, [
        { key: 'title', label: 'Title', default: epic.title },
        { key: 'description', label: 'Description', default: epic.description },
      ], data => {
        if (!data || !data.title.trim()) return;
        Epics.update(epic.id, { title: data.title.trim(), description: data.description.trim() });
        setStatus('Epic updated', COLORS.done);
        refreshAll();
      });

    } else if (state.focus === 'stories') {
      const story = state.stories[state.storyIdx];
      if (!story) return;
      prompt(screen, `Edit Story — ${story.key}`, [
        { key: 'title', label: 'Title', default: story.title },
        { key: 'description', label: 'Description', default: story.description },
        { key: 'priority', label: 'Priority (p1/p2/p3)', default: story.priority },
      ], data => {
        if (!data || !data.title.trim()) return;
        const priority = ['p1', 'p2', 'p3'].includes(data.priority) ? data.priority : story.priority;
        Stories.update(story.id, {
          title: data.title.trim(),
          description: data.description.trim(),
          priority,
        });
        setStatus('Story updated', COLORS.done);
        refreshAll();
      });

    } else {
      const subtask = state.subtasks[state.subtaskIdx];
      if (!subtask) return;
      prompt(screen, `Edit Subtask — ${subtask.key}`, [
        { key: 'title', label: 'Title', default: subtask.title },
      ], data => {
        if (!data || !data.title.trim()) return;
        Subtasks.update(subtask.id, { title: data.title.trim() });
        setStatus('Subtask updated', COLORS.done);
        loadDetail();
      });
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────────

  function deleteCurrent() {
    if (state.focus === 'epics') {
      const epic = state.epics[state.epicIdx];
      if (!epic) return;
      confirm(screen, `Delete epic "${epic.title}" and all its stories?`, yes => {
        if (!yes) return;
        Epics.delete(epic.id);
        state.epicIdx = Math.max(0, state.epicIdx - 1);
        setStatus('Epic deleted', COLORS.p1);
        refreshAll();
      });

    } else if (state.focus === 'stories') {
      const story = state.stories[state.storyIdx];
      if (!story) return;
      confirm(screen, `Delete story "${story.title}"?`, yes => {
        if (!yes) return;
        Stories.delete(story.id);
        state.storyIdx = Math.max(0, state.storyIdx - 1);
        setStatus('Story deleted', COLORS.p1);
        refreshAll();
      });

    } else {
      const subtask = state.subtasks[state.subtaskIdx];
      if (!subtask) return;
      confirm(screen, `Delete subtask "${subtask.title}"?`, yes => {
        if (!yes) return;
        Subtasks.delete(subtask.id);
        state.subtaskIdx = Math.max(0, state.subtaskIdx - 1);
        setStatus('Subtask deleted', COLORS.p1);
        loadDetail();
      });
    }
  }

  // ── Link branch ───────────────────────────────────────────────────────────────

  function linkBranch() {
    const story = state.stories[state.storyIdx];
    if (!story) { setStatus('Select a story first', COLORS.p1); return; }
    prompt(screen, 'Link Git Branch', [
      { key: 'branch', label: 'Branch name', default: state.branch || story.branch || '' },
    ], data => {
      if (!data) return;
      Stories.update(story.id, { branch: data.branch.trim() });
      setStatus(`Branch linked: ${data.branch.trim()}`, COLORS.accent);
      loadStories();
    });
  }

  // ── Subtask comments ──────────────────────────────────────────────────────────

  function addComment() {
    if (state.focus !== 'subtasks') {
      setStatus('Focus the subtask pane to comment', COLORS.p1);
      return;
    }
    const subtask = state.subtasks[state.subtaskIdx];
    if (!subtask) { setStatus('Select a subtask first', COLORS.p1); return; }
    prompt(screen, `Comment — ${subtask.key} ${subtask.title}`, [
      { key: 'body',    label: 'Comment', default: '' },
      { key: 'author',  label: 'Author',  default: 'agent' },
    ], data => {
      if (!data || !data.body.trim()) return;
      const author = data.author.trim() || 'agent';
      Comments.create({ subtaskId: subtask.id, body: data.body.trim(), author });
      setStatus('Comment added', COLORS.done);
      loadDetail();
    });
  }

  function viewComments() {
    if (state.focus !== 'subtasks') {
      setStatus('Focus the subtask pane to view comments', COLORS.p1);
      return;
    }
    const subtask = state.subtasks[state.subtaskIdx];
    if (!subtask) { setStatus('Select a subtask first', COLORS.p1); return; }

    const list = Comments.forSubtask(subtask.id);
    const box = blessed.box({
      parent: screen,
      top: 'center',
      left: 'center',
      width: '70%',
      height: Math.max(10, Math.min(list.length * 3 + 8, screen.height - 4)),
      border: { type: 'line', fg: COLORS.accent },
      label: ` Comments — ${subtask.key} ${subtask.title} `,
      tags: true,
      scrollable: true,
      alwaysScroll: true,
      keys: true,
      vi: true,
      mouse: true,
      style: { bg: COLORS.surface, fg: COLORS.text },
    });

    if (!list.length) {
      box.setContent(colorTag(COLORS.textDim, '\n  (no comments)'));
    } else {
      const lines = [];
      list.forEach((c, i) => {
        if (i > 0) lines.push(colorTag(COLORS.border, '  ' + '─'.repeat(60)));
        lines.push(`  ${colorTag(COLORS.accent, '#' + (i + 1))} ${colorTag(COLORS.textDim, c.created_at)}  ${colorTag(COLORS.text, '[' + c.author + ']')}`);
        lines.push(`  ${c.body}`);
      });
      box.setContent(lines.join('\n'));
    }

    box.key(['escape', 'q', 'enter', 'space'], () => {
      box.destroy();
      screen.render();
    });
    box.focus();
    screen.render();
  }

  // ── List selection events ─────────────────────────────────────────────────────

  epicPanel.on('select item', (_, idx) => {
    state.epicIdx = idx;
    state.storyIdx = 0;
    state.subtaskIdx = 0;
    loadStories();
  });

  storyPanel.on('select item', (_, idx) => {
    state.storyIdx = idx;
    state.subtaskIdx = 0;
    loadDetail();
  });

  subtaskList.on('select item', (_, idx) => {
    state.subtaskIdx = idx;
    screen.render();
  });

  // ── Global keybindings ────────────────────────────────────────────────────────

  screen.key(['tab'], () => cycleTab());
  screen.key(['n'], () => createNew());
  screen.key(['e'], () => editCurrent());
  screen.key(['d'], () => cycleStatus());
  screen.key(['D'], () => deleteCurrent());
  screen.key(['b'], () => linkBranch());
  screen.key(['c'], () => addComment());
  screen.key(['v'], () => viewComments());
  screen.key(['r'], () => { refreshAll(); setStatus('Reloaded from DB', COLORS.done); });
  screen.key(['q', 'C-c'], () => process.exit(0));

  // ── Init ──────────────────────────────────────────────────────────────────────

  refreshAll();
  applyFocus();

  setStatus(
    `EOM Tracker ready  ·  ${state.epics.length} epics loaded  ·  branch: ${branch || '(none)'}`,
    COLORS.textDim
  );

  screen.render();
}

module.exports = { launchTUI };
