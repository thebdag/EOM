// seed.js — pre-populate the tracker with EOM's natural epic/story structure
'use strict';

const { Epics, Stories } = require('./db');

function seed() {
  const data = [
    {
      title: 'Core LLM Integration',
      description:
        'Abstract LlmProvider interface and concrete implementations for OpenAI, Anthropic, Gemini, and LiteLLM. Intent routing and system prompt management in AiService.',
      stories: [
        { title: 'Abstract LlmProvider interface', status: 'done', priority: 'p1' },
        { title: 'OpenAI (GPT-4o) provider implementation', status: 'done', priority: 'p1' },
        { title: 'Anthropic (Claude) provider implementation', status: 'done', priority: 'p1' },
        { title: 'Google Gemini provider implementation', status: 'done', priority: 'p1' },
        { title: 'LiteLLM local gateway provider', status: 'done', priority: 'p1' },
        { title: 'Intent router and system prompt configuration', status: 'done', priority: 'p1' },
        { title: 'Streaming response support', status: 'todo', priority: 'p2' },
        { title: 'Error handling and retry logic', status: 'todo', priority: 'p2' },
      ],
    },
    {
      title: 'UI / Design System',
      description:
        'EomColors palette tokens, EomTheme Material 3 definition, and all core widgets implementing the Epistemic Calm visual philosophy.',
      stories: [
        { title: 'EomColors palette and token system', status: 'done', priority: 'p1' },
        { title: 'EomTheme Material 3 ThemeData', status: 'done', priority: 'p1' },
        { title: 'HomeScreen — borderless input, intent buttons, response area', status: 'done', priority: 'p1' },
        { title: 'IntentButton pill widget with hover/active states', status: 'done', priority: 'p1' },
        { title: 'ResponseCard fade-in markdown widget', status: 'done', priority: 'p2' },
        { title: 'Full markdown rendering in ResponseCard', status: 'todo', priority: 'p2' },
        { title: 'Responsive layout (tablet/desktop breakpoints)', status: 'todo', priority: 'p3' },
        { title: 'Light mode theme variant', status: 'todo', priority: 'p3' },
      ],
    },
    {
      title: 'Map Visualization',
      description:
        'ThoughtNode recursive data model and ThoughtTreeView custom widget for rendering the Map cognitive intent as a directory-style tree.',
      stories: [
        { title: 'ThoughtNode recursive model', status: 'done', priority: 'p1' },
        { title: 'ThoughtTreeView custom widget', status: 'done', priority: 'p1' },
        { title: 'Tree expand/collapse interaction', status: 'todo', priority: 'p2' },
        { title: 'Export map as plain text / image', status: 'todo', priority: 'p3' },
      ],
    },
    {
      title: 'History & Persistence',
      description:
        'SQLite-backed history service for storing and retrieving past thought sessions, plus the HistoryScreen library UI.',
      stories: [
        { title: 'HistoryService SQLite implementation', status: 'done', priority: 'p1' },
        { title: 'HistoryScreen — session library UI', status: 'done', priority: 'p1' },
        { title: 'Search / filter history', status: 'todo', priority: 'p2' },
        { title: 'Delete / archive sessions', status: 'todo', priority: 'p2' },
        { title: 'Export history as JSON or Markdown', status: 'todo', priority: 'p3' },
      ],
    },
    {
      title: 'Settings & Config',
      description:
        'SharedPreferences-backed settings service, provider selection, API key management, and LiteLLM gateway configuration.',
      stories: [
        { title: 'SettingsService SharedPreferences wrapper', status: 'done', priority: 'p1' },
        { title: 'SettingsScreen UI — provider + key entry', status: 'done', priority: 'p1' },
        { title: 'LiteLLM gateway origin normalization', status: 'done', priority: 'p1' },
        { title: 'Per-intent model override settings', status: 'todo', priority: 'p2' },
        { title: 'Import/export settings', status: 'todo', priority: 'p3' },
      ],
    },
    {
      title: 'Testing & Quality',
      description:
        'Unit tests, widget tests, linting, and flutter analyze coverage for the codebase.',
      stories: [
        { title: 'SettingsService unit tests', status: 'done', priority: 'p1' },
        { title: 'ThoughtNode unit tests', status: 'done', priority: 'p1' },
        { title: 'LlmProvider mock and AiService unit tests', status: 'todo', priority: 'p1' },
        { title: 'HistoryService unit tests', status: 'todo', priority: 'p1' },
        { title: 'HomeScreen widget tests', status: 'todo', priority: 'p2' },
        { title: 'CI: flutter analyze on every push', status: 'todo', priority: 'p2' },
      ],
    },
    {
      title: 'Documentation',
      description:
        'REPOMAP, design spec, ADRs, changelog, and learnings kept in sync with code changes.',
      stories: [
        { title: 'REPOMAP.md — directory structure doc', status: 'done', priority: 'p1' },
        { title: 'design_spec.md — visual philosophy', status: 'done', priority: 'p1' },
        { title: 'ADR-0001: local means LiteLLM gateway', status: 'done', priority: 'p2' },
        { title: 'CONTEXT.md — domain glossary', status: 'done', priority: 'p2' },
        { title: 'AGENTS.md — agent workflow rules', status: 'done', priority: 'p2' },
        { title: 'Contributing guide', status: 'todo', priority: 'p3' },
      ],
    },
  ];

  for (const epicData of data) {
    const epic = Epics.create({ title: epicData.title, description: epicData.description });
    for (const s of epicData.stories) {
      const story = Stories.create({
        epicId: epic.id,
        title: s.title,
        priority: s.priority || 'p2',
      });
      if (s.status && s.status !== 'todo') {
        Stories.update(story.id, { status: s.status });
      }
    }
  }

  console.log('✓ Seeded 7 epics with stories.');
}

// Allow running standalone: node seed.js
if (require.main === module) {
  const { initDb } = require('./db');
  initDb().then(() => {
    seed();
    console.log('Done.');
    process.exit(0);
  });
}

module.exports = { seed };
