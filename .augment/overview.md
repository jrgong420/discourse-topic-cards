---
id: discourse-theme-overview
title: Discourse Theme Component Development - Overview
type: overview
category: meta
tags: [discourse, theme, overview, index]
last_updated: 2025-10-07
sources:
  - https://meta.discourse.org/t/theme-developer-tutorial-1-introduction/357796
  - https://meta.discourse.org/t/theme-developer-quick-reference-guide/110448
---

# Discourse Theme Component Development - Overview

This directory contains coding rules and best practices for developing Discourse theme components, specifically tailored for this project.

## 🚨 Critical 2025 Platform Updates

Discourse has made several breaking changes in 2025. **All theme components must be updated**:

### Deprecated & Removed (2025)

- ❌ **Inline script tags** - Removed September 2025 ([guide](https://meta.discourse.org/t/366482))
  - No more `<script type="text/discourse-plugin">` or `<script type="text/x-handlebars">`
  - Migrate to `.gjs` files in `javascripts/discourse/api-initializers/`

- ❌ **Template overrides** - Removed June 2025 ([guide](https://meta.discourse.org/t/355668))
  - Use wrapper plugin outlets instead

- ❌ **Widget rendering system** - EOL Q4 2025 ([guide](https://meta.discourse.org/t/375332))
  - No `createWidget`, `decorateWidget`, `changeWidgetSetting`, `reopenWidget`, `attachWidgetAction`, `MountWidget`
  - Migrate to Glimmer components and plugin outlets

- ❌ **Post stream widgets** - Modernized 2025 ([guide](https://meta.discourse.org/t/372063))
  - Use `addTrackedPostProperties` instead of `includePostAttributes`
  - Use plugin outlets and value transformers instead of widget decorations

## 📚 Rule Categories

### Core SPA Patterns

Essential patterns for Discourse SPA architecture:

- [Core SPA Patterns](rules/core-spa-patterns.md) - Event binding, navigation guards, state management

### Modern JavaScript

Modern JavaScript patterns and APIs:

- [Modern JavaScript](rules/modern-javascript.md) - Glimmer components, outlets, transformers, initializers

### Configuration

Theme configuration and metadata:

- [Configuration](rules/configuration.md) - Settings, about.json, localization

### Workflow

Development processes:

- [Workflow](rules/workflow.md) - Development setup, compatibility, migrations

### Styling

SCSS and CSS guidelines:

- [Styling](rules/styling.md) - SCSS best practices and patterns

## 🎯 Quick Start

### For New Components

1. Read [Modern JavaScript](rules/modern-javascript.md)
2. Review [Core SPA Patterns](rules/core-spa-patterns.md)
3. Check [Workflow](rules/workflow.md) for setup and compatibility

### For Existing Components

1. Check [Workflow](rules/workflow.md) for 2025 deprecations
2. Migrate widgets to Glimmer components (see [Modern JavaScript](rules/modern-javascript.md))
3. Update to modern patterns

## 📖 Official Resources

- [Theme Developer Tutorial Series](https://meta.discourse.org/t/357796) - Official tutorial
- [Theme Developer Quick Reference](https://meta.discourse.org/t/110448) - Quick reference guide
- [Plugin API Documentation](https://github.com/discourse/discourse/blob/main/app/assets/javascripts/discourse/app/lib/plugin-api.gjs)
- [Discourse Developer Guides](https://meta.discourse.org/c/documentation/developer-guides/56)

## 🔧 Development Tools

- **Discourse Theme CLI** - `discourse_theme watch .`
- **Developer Toolbar** - Enable with `enableDevTools()` in browser console
- **Plugin Outlet Inspector** - Click 🔌 icon in developer toolbar

## ⚡ Modern Stack (2025)

- **File Format**: `.gjs` (Glimmer JavaScript with template tags)
- **Components**: Glimmer Components (not widgets)
- **Extension Points**: Plugin outlets, value transformers, behavior transformers
- **Initialization**: `apiInitializer` in `javascripts/discourse/api-initializers/`
- **State Management**: `@tracked` properties, Ember services
- **Styling**: SCSS with Discourse variables

## 📝 Rule Format

Each rule follows this structure:

- **Intent** - What and why
- **When This Applies** - Specific scenarios
- **Do** - Recommended practices with examples
- **Don't** - Anti-patterns to avoid
- **Patterns** - Good/bad comparisons
- **Diagnostics/Verification** - Testing approaches
- **References** - Official documentation links

---

**Last Updated**: 2025-10-07  
**Discourse Version Target**: 3.5+ (2025 standards)
