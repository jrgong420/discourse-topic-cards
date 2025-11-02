# Discourse Topic Cards

A modern Discourse theme component that transforms standard topic lists into beautiful, card-based layouts with support for list and grid styles.

[![Discourse Version](https://img.shields.io/badge/discourse-3.2%2B-blue)](https://www.discourse.org/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Features

- 🎨 **Multiple Layout Styles** - Choose between list or grid card layouts per category
- 📱 **Fully Responsive** - Optimized for desktop, tablet, and mobile devices
- 🖼️ **Rich Media Support** - Display topic thumbnails with customizable aspect ratios
- 🏷️ **Category & Tag Display** - Inline category badges and tags
- 🔗 **Featured Link Support** - Dedicated CTA buttons for topics with external links
- ⚡ **Performance Optimized** - Data-driven rendering with no DOM observers
- ♿ **Accessible** - ARIA labels, keyboard navigation, and screen reader support
- 🎯 **Per-Category Configuration** - Enable cards for specific categories only
- 🌐 **Fully Localized** - Translations available in 40+ languages

## Screenshots

### List Style Cards
![List Style Cards](screenshots/list-cards.png)

### Grid Style Cards
![Grid Style Cards](screenshots/grid-cards.png)

## Installation

### Via Admin Panel (Recommended)

1. Go to **Admin → Customize → Themes**
2. Click **Install** → **From a git repository**
3. Enter: `https://github.com/discourse/discourse-topic-cards`
4. Click **Install**

### Via Theme CLI (Development)

```bash
# Clone the repository
git clone https://github.com/discourse/discourse-topic-cards.git
cd discourse-topic-cards

# Install dependencies
pnpm install

# Watch for changes
discourse_theme watch .
```

## Configuration

### Basic Setup

1. **Enable the theme component**
   - Admin → Customize → Themes
   - Select your active theme
   - Add "Topic Cards" as a component

2. **Configure card styles per category**
   - Admin → Settings → Theme Settings → Topic Cards
   - Set `list_view_categories` for list-style cards
   - Set `grid_view_categories` for grid-style cards
   - Format: `category-slug|another-slug`

### Theme Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `list_view_categories` | list | - | Categories to display as list-style cards |
| `grid_view_categories` | list | - | Categories to display as grid-style cards |
| `mobile_list_view_categories` | list | - | Mobile-specific list-style categories |
| `mobile_grid_view_categories` | list | - | Mobile-specific grid-style categories |
| `show_excerpt` | bool | true | Display topic excerpts |
| `show_views` | bool | true | Display view count |
| `show_likes` | bool | true | Display like count |
| `show_reply_count` | bool | true | Display reply count |
| `show_activity` | bool | true | Display activity timestamp |
| `show_publish_date` | bool | true | Display topic creation date |
| `card_border_radius` | enum | medium | Border radius for cards |
| `thumbnail_aspect_ratio` | enum | 16:9 | Aspect ratio for thumbnails |
| `portfolio_topic_cards_style` | enum | disabled | Enable cards on user portfolio pages |

### Advanced Configuration

See [CONFIGURATION.md](CONFIGURATION.md) for detailed configuration options.

## Usage

### Enabling Cards for a Category

1. Navigate to **Admin → Settings → Theme Settings → Topic Cards**
2. Add your category slug to `list_view_categories` or `grid_view_categories`
3. Example: `support|feature-requests|announcements`
4. Save settings

### Mobile-Specific Layouts

Configure different card styles for mobile devices:

```
# Desktop: Grid layout
grid_view_categories: announcements|showcase

# Mobile: List layout (easier to scroll)
mobile_list_view_categories: announcements|showcase
```

### Portfolio Pages

Enable cards on user portfolio pages:

1. Set `portfolio_topic_cards_style` to "list" or "grid"
2. Navigate to any user's portfolio: `/u/username/portfolio`
3. Topics will render as cards

## Architecture

### Modern Discourse Patterns

This theme component follows Discourse's latest development standards:

- ✅ **Glimmer Components** - Modern `.gjs` template-tag format
- ✅ **Value Transformers** - Clean API for customizing behavior
- ✅ **Plugin Outlets** - Proper integration points
- ✅ **Data-Driven Rendering** - No post-render DOM manipulation
- ✅ **BEM Naming** - Consistent, maintainable CSS architecture
- ✅ **SPA-Friendly** - No MutationObservers or timing dependencies

### Component Structure

```
topic-card
├── topic-card__thumbnail (optional)
├── topic-card__content
│   ├── topic-card__title
│   ├── topic-card__excerpt
│   ├── topic-card__tags (category + tags)
│   ├── topic-card__byline (author + date)
│   ├── topic-card__actions (featured link buttons)
│   └── topic-card__metadata (views, likes, replies)
```

### Key Components

- **TopicThumbnail** - Displays topic image with aspect ratio control
- **TopicExcerpt** - Renders topic excerpt with line clamping
- **TopicTagsInline** - Shows category badge and tags
- **TopicByline** - Displays author and publish date
- **TopicActionButtons** - Featured link and details CTAs
- **TopicMetadata** - Views, likes, replies, activity

## Development

### Prerequisites

- Ruby ≥ 2.7 (recommended: 3.3.9)
- Node.js ≥ 22 (recommended: 22.x)
- pnpm (via Corepack: `corepack enable`)
- Discourse Theme CLI: `gem install discourse_theme`

### Setup

```bash
# Install dependencies
pnpm install

# Start watch mode
discourse_theme watch .

# Run tests
pnpm test

# Lint code
pnpm run lint
```

### Testing

See [TESTING.md](TESTING.md) for comprehensive testing guide.

```bash
# Run automated tests
pnpm test

# Run specific test file
pnpm test test/javascripts/topic-cards-test.gjs

# Lint JavaScript
pnpm run lint:js

# Lint SCSS
pnpm run lint:scss
```

### Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run tests: `pnpm test`
5. Commit: `git commit -am 'Add new feature'`
6. Push: `git push origin feature/my-feature`
7. Create a Pull Request

## Troubleshooting

### Cards Not Appearing

1. Verify theme component is enabled
2. Check category slug is correct in settings
3. Ensure Glimmer topic list mode is enabled (default in Discourse 3.2+)
4. Clear browser cache

### Layout Issues

1. Check browser console for errors
2. Verify CSS is loading (DevTools → Network)
3. Try disabling other theme components temporarily
4. Check for CSS conflicts with custom themes

### Featured Links Not Working

1. Verify topic has a featured link set
2. Check that `TopicActionButtons` component is rendering
3. Inspect element to verify `.topic-card__actions` exists
4. Check console for JavaScript errors

### Performance Issues

1. Reduce number of categories with cards enabled
2. Disable thumbnails if not needed
3. Reduce excerpt length in Discourse settings
4. Check for conflicting theme components

## Known Issues

See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for current known issues and workarounds.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and migration notes.

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest, macOS/iOS)
- Mobile browsers (iOS Safari, Chrome Mobile)

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

Developed and maintained by the [Discourse Team](https://www.discourse.org/).

## Support

- **Documentation**: [Meta Discourse Topic](https://meta.discourse.org/t/discourse-topic-cards/296048)
- **Issues**: [GitHub Issues](https://github.com/discourse/discourse-topic-cards/issues)
- **Community**: [Discourse Meta](https://meta.discourse.org/)

## Related

- [Discourse Theme CLI](https://github.com/discourse/discourse_theme)
- [Discourse Developer Guide](https://meta.discourse.org/c/dev/7)
- [Theme Component Guide](https://meta.discourse.org/t/developer-s-guide-to-discourse-themes/93648)

