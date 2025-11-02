# Known Issues

## Redundant `&nbsp;` Before Featured Link (In Progress)

**Status**: Under investigation  
**Severity**: Low (cosmetic)  
**Affects**: Topic cards with featured links

### Description

A non-breaking space (`&nbsp;` / `\u00A0`) text node still appears before the featured link area in topic cards, despite CSS suppression of the inline `a.topic-featured-link` anchor.

### Root Cause

Discourse core inserts a literal text node (`\u00A0`) in the `.link-top-line` container as spacing between the title and the inline featured link anchor. Even though we hide the anchor via CSS (`display: none`), the text node itself remains in the DOM.

### Current Mitigation

- The inline featured link anchor is hidden via CSS in card mode
- Featured link functionality is preserved via the CTA button in `TopicActionButtons`
- The `&nbsp;` is not visible to users (no visual spacing issue)
- Plugin outlets in the title area remain functional

### Planned Fix

Investigating options:
1. Use a value transformer to prevent core from rendering the text node in card contexts
2. Use a wrapper outlet to replace the entire title-line rendering in card mode
3. Add minimal post-render cleanup scoped only to the text node (not the full DOM surgery we removed)

### Workaround

None needed - the issue is cosmetic only. The `&nbsp;` text node exists in the DOM but does not affect layout or functionality.

### Related

- Phase 2 implementation: Structural fix for featured link in card layouts
- CSS suppression: `common/common.scss` lines 223-246

