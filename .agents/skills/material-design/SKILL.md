---
name: material-design
version: 1.0.0
description: Practical quick reference for Google Material Design 3. Covers Material You dynamic color, typography system, component specs, shape system, motion guidelines, dark theme adaptation, and Jetpack Compose/Flutter comparisons. Suitable for UI design decisions in Android apps, Web apps, and cross-platform apps.
---

# Google Material Design 3 Practical Reference

A practical quick reference for Material Design 3 (Material You), covering colors, typography, components, and motion.

## Applicable Scenarios

- Android app UI design (Jetpack Compose / XML Views)
- Flutter cross-platform apps
- Web apps using Material component libraries (MUI / Angular Material)
- Auditing existing UI for compliance with Material 3 guidelines

## Not Applicable

- macOS / iOS native apps (refer to apple-hig)
- Windows native apps (refer to fluent-design)

---

## 1. Core Design Principles

The three pillars of Material 3:

| Principle | Meaning | Practice |
|------|------|------|
| **Personal** | Adapts to user preferences | Dynamic Color from wallpaper |
| **Adaptive** | Adapts to various devices | Responsive layout, foldable support |
| **Expressive** | Rich visual expression | Large rounded corners, color hierarchies, motion |

### Differences from Apple HIG / Fluent

```
Apple:   Subtractive, restrained, content-first
Fluent:  Blends with environment (Mica/Acrylic), rich hierarchy
Material: Additive, highly expressive, bold colors, larger rounded corners
```

---

## 2. Color System (Dynamic Color)

### Material 3 Color Scheme

M3 generates a complete color scheme using **Tonal Palettes**:

```
Source Color
  → Primary Palette (13 tones)
  → Secondary Palette (13 tones)
  → Tertiary Palette (13 tones)
  → Neutral Palette (13 tones)
  → Neutral Variant Palette (13 tones)
  → Error Palette (13 tones)
```

### Key Color Roles

| Role | Light | Dark | Purpose |
|------|-------|------|------|
| Primary | Tone 40 | Tone 80 | Main interactive elements (FAB, buttons) |
| On Primary | Tone 100 | Tone 20 | Text/icons on Primary |
| Primary Container | Tone 90 | Tone 30 | Secondary emphasis container |
| On Primary Container | Tone 10 | Tone 90 | Content on container |
| Secondary | Tone 40 | Tone 80 | Secondary interactive elements |
| Tertiary | Tone 40 | Tone 80 | Contrast/emphasis |
| Surface | Tone 99 | Tone 6 | Main page background |
| Surface Variant | Tone 90 | Tone 30 | Card/block background |
| On Surface | Tone 10 | Tone 90 | Primary text |
| On Surface Variant | Tone 30 | Tone 80 | Secondary text |
| Outline | Tone 50 | Tone 60 | Borders |
| Outline Variant | Tone 80 | Tone 30 | Subtle borders/dividers |
| Error | `#B3261E` | `#F2B8B5` | Error states |
| Background | Tone 99 | Tone 6 | Window background |

### Dynamic Color (Material You)

Android 12+ supports automatically extracting the Source Color from the wallpaper:

```kotlin
// Jetpack Compose
val colorScheme = if (dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
    dynamicLightColorScheme(context) // or dynamicDarkColorScheme
} else {
    lightColorScheme(primary = Purple40, ...)
}
```

### Manually Generating Colors

Use Google's official tools:
- **Material Theme Builder**: https://m3.material.io/theme-builder
- Input a Source Color → Automatically generates full Light/Dark schemes
- Export as Compose / CSS / Figma Tokens

---

## 3. Typography

### Font Stacks

```
Android: Roboto (System default)
Web:     'Roboto', system-ui, sans-serif
iOS:     SF Pro (Automatically adapted by Flutter)
```

### Type Scale

| Role | Size | Weight | Line Height | Tracking | Purpose |
|------|------|------|------|------|------|
| Display Large | 57px | Regular | 64px | -0.25px | Extra-large numbers/Hero titles |
| Display Medium | 45px | Regular | 52px | 0 | Large titles |
| Display Small | 36px | Regular | 44px | 0 | Medium-large titles |
| Headline Large | 32px | Regular | 40px | 0 | Page titles |
| Headline Medium | 28px | Regular | 36px | 0 | Section titles |
| Headline Small | 24px | Regular | 32px | 0 | Card titles |
| Title Large | 22px | Regular | 28px | 0 | Top App Bar titles |
| Title Medium | 16px | Medium | 24px | 0.15px | Tab / Navigation labels |
| Title Small | 14px | Medium | 20px | 0.1px | Subtitles |
| Body Large | 16px | Regular | 24px | 0.5px | Default body text |
| Body Medium | 14px | Regular | 20px | 0.25px | Secondary body text |
| Body Small | 12px | Regular | 16px | 0.4px | Helper text |
| Label Large | 14px | Medium | 20px | 0.1px | Button text |
| Label Medium | 12px | Medium | 16px | 0.5px | Badges |
| Label Small | 11px | Medium | 16px | 0.5px | Timestamps |

### Comparison with Other Platforms

```
Material Body Large = 16px → Apple Body = 13px (macOS) / 17px (iOS)
Material is generally larger and looser, Apple is more compact.
Material extensively uses Medium weight, Apple leans towards Regular.
```

---

## 4. Component Specifications

### Buttons

| Type | Height | Radius | Purpose |
|------|------|------|------|
| Filled | 40px | 20px (Fully rounded) | Primary action |
| Outlined | 40px | 20px | Secondary action |
| Text | 40px | 20px | Low-priority action |
| Tonal | 40px | 20px | Between Filled and Outlined |
| FAB (Mini) | 40px | 12px | Minor floating action |
| FAB | 56px | 16px | Primary floating action |
| Extended FAB | 56px | 16px | FAB with text |
| Icon Button | 40×40px | 20px | Icon action |

### Inputs

| Component | Height | Radius | Features |
|------|------|------|------|
| Text Field (Filled) | 56px | Top 4px | Bottom underline |
| Text Field (Outlined) | 56px | 4px | All-around border |
| Checkbox | 18×18px | 2px | — |
| Radio | 20×20px | 50% | — |
| Switch | 32×52px | 16px | Large toggle |
| Slider | 4px track | 2px | Circular thumb 20px |

### Containers

| Component | Radius | Elevation/Shadow |
|------|------|------|
| Card (Filled) | 12px | None (Differentiated by background color) |
| Card (Elevated) | 12px | Elevation 1 |
| Card (Outlined) | 12px | None (Differentiated by border) |
| Dialog | 28px | Elevation 3 |
| Bottom Sheet | 28px (Top) | Elevation 1 |
| Chip | 8px | — |
| Navigation Bar | 0 | Elevation 2 |

### Touch Targets

```
Minimum touch target: 48×48dp
Recommended touch target: 56×56dp (FAB)
Spacing: At least 8dp
```

---

## 5. Shape System

M3's rounded corner rules (using dp):

| Shape Scale | Radius Value | Applicable Components |
|-----------|--------|---------|
| None | 0dp | — |
| Extra Small | 4dp | Text Field, Menu |
| Small | 8dp | Chip, Snackbar |
| Medium | 12dp | Card, Search Bar |
| Large | 16dp | FAB, Navigation Drawer |
| Extra Large | 28dp | Dialog, Bottom Sheet |
| Full | 50% (Circular) | FAB Mini, Icon Button |

### Comparison with Other Platforms

```
Material: Large corner radius style (Dialog 28dp, Button 20dp)
Apple:    Medium corner radius (Dialog ~12px, Button 5-7px)
Fluent:   Small corner radius (Dialog 8px, Button 4px)
```

Material 3's rounded corners are the largest among the three, making it visually the softest and most expressive.

---

## 6. Elevation System

M3 uses **Surface Tint** instead of pure shadows to express hierarchy:

| Level | Tint Opacity | Shadow | Purpose |
|-------|-------------|------|------|
| 0 | 0% | None | Surface base |
| 1 | 5% | Very Subtle | Card, Navigation Bar |
| 2 | 8% | Subtle | Elevated Card |
| 3 | 11% | Medium | FAB, Snackbar |
| 4 | 12% | — | Rarely used |
| 5 | 14% | Prominent | Navigation Drawer |

### Surface Tint Implementation

```css
/* Using Primary color as overlay, opacity increases by level */
.elevation-1 {
  background: linear-gradient(
    rgba(var(--md-primary-rgb), 0.05),
    rgba(var(--md-primary-rgb), 0.05)
  ), var(--md-surface);
}
```

> **Surface Tint is more important in Dark Mode** — Shadows are barely visible on dark backgrounds, so tint is used to differentiate layers.

---

## 7. Motion System

### Duration

| Type | Duration | Purpose |
|------|------|------|
| Short 1 | 50ms | Selection/Deselection |
| Short 2 | 100ms | Simple state changes |
| Short 3 | 150ms | Small components appearing |
| Short 4 | 200ms | Standard interactions |
| Medium 1 | 250ms | Expanding panels |
| Medium 2 | 300ms | Standard transitions |
| Medium 3 | 350ms | Complex transitions |
| Medium 4 | 400ms | Full-screen transitions |
| Long 1 | 450ms | Emphasis animations |
| Long 2 | 500ms | Complex emphasis |
| Extra Long 1-4 | 700-1000ms | Used extremely rarely |

### Easing

```css
/* Standard — Movement that doesn't leave the screen */
--md-standard: cubic-bezier(0.2, 0, 0, 1);
--md-standard-decelerate: cubic-bezier(0, 0, 0, 1);
--md-standard-accelerate: cubic-bezier(0.3, 0, 1, 1);

/* Emphasized — More expressive movement */
--md-emphasized: cubic-bezier(0.2, 0, 0, 1);
--md-emphasized-decelerate: cubic-bezier(0.05, 0.7, 0.1, 1);
--md-emphasized-accelerate: cubic-bezier(0.3, 0, 0.8, 0.15);
```

### Transition Patterns

| Pattern | Purpose | Example |
|------|------|------|
| Container Transform | Element expands into a page | Card → Detail Page |
| Shared Axis | Navigating between same hierarchy levels | Tab switching |
| Fade Through | Switching between unrelated pages | Bottom Nav switching |
| Fade | Simple appear/disappear | Dialog, Snackbar |

---

## 8. Navigation Patterns

### Selection by Device

| Device | Recommended Navigation | Component |
|------|---------|------|
| Phone (Portrait) | Bottom navigation | Navigation Bar (3-5 items) |
| Phone (Landscape) | Side navigation | Navigation Rail |
| Tablet | Side navigation | Navigation Rail / Drawer |
| Desktop/Large Screen | Side navigation | Navigation Drawer (Persistent) |
| Foldable | Adaptive | Rail (Folded) → Drawer (Unfolded) |

### Navigation Bar (Bottom Navigation)

```
┌─────────────────────────────────────────┐
│                                         │
│          Content Area                   │
│                                         │
├───────┬───────┬───────┬───────┬─────────┤
│  🏠   │   🔍  │  ➕  │  💬  │  👤    │
│ Home  │ Search│  Add  │  Chat │ Profile │
└───────┴───────┴───────┴───────┴─────────┘
```

- 3-5 destinations
- Selected item shows label + indicator (pill shape)
- Height: 80dp
- Indicator: 64×32dp, radius 16dp

### Navigation Rail (Narrow Side Navigation)

```
┌──┬──────────────────────┐
│🏠│                      │
│──│                      │
│🔍│    Content Area      │
│──│                      │
│💬│                      │
│──│                      │
│⚙️│                      │
└──┴──────────────────────┘
```

- Width: 80dp
- Optional FAB at the top
- Selected item has a pill indicator

---

## 9. Dark Theme

### M3 Dark Theme Rules

```
Surface: Very dark gray (#1C1B1F), not pure black #000000
On Surface: Very light gray (#E6E1E5), not pure white #FFFFFF
```

| Principle | Practice |
|------|------|
| Avoid pure black | Use `#1C1B1F` (Neutral Tone 6) for Surface |
| Reduce large areas of white | Use Surface Tint instead of white cards |
| Lower saturation | Use a brighter tone for Primary (Tone 80) |
| Invert container relationship | Light: Container is lighter than background → Dark: Container is lighter than background (higher tint) |

### Comparison with Apple Dark Mode

```
Apple:    Dark gray #1E1E1E, leans neutral
Material: Very dark gray #1C1B1F, with a purple tint (from Neutral palette)
Apple:    Discourages pure black (but uses #000000 for OLED)
Material: Explicitly recommends against pure black
```

---

## 10. Platform Differences Quick Reference

| Difference | Material (Android) | Apple (iOS) |
|--------|-------------------|-------------|
| Primary Emphasis Color | Dynamic Color (Extracted from wallpaper) | System Blue #007AFF |
| Body Text Size | 16dp (Body Large) | 17pt (Body) |
| Button Radius | 20dp (Fully rounded) | No standard (Leans 8-12px) |
| Dialog Radius | 28dp | ~14px |
| Navigation | Bottom Navigation Bar | Bottom Tab Bar |
| Back Action | System back gesture/button | Top-left Back Button |
| Primary Action | FAB (Floating Action Button) | Navigation Bar Button |
| Pull to Refresh | Yes | Yes (Pull to Refresh) |
| Toast/Alerts | Snackbar (Bottom, actionable) | Alert / Toast (Center/Top) |
| Touch Target | 48dp | 44pt |
| Header Bar | Top App Bar (Multiple styles) | Navigation Bar (Standard) |

---

## 11. Checklist

### Design Audit
- [ ] Uses M3 Color Scheme (Primary/Secondary/Tertiary + Surface series)
- [ ] Buttons use full rounded corners (20dp radius)
- [ ] Cards use 12dp radius
- [ ] Dialogs use 28dp radius
- [ ] Touch targets ≥ 48dp
- [ ] Typography uses M3 Type Scale
- [ ] Elevation uses Surface Tint instead of pure shadows
- [ ] Navigation matches device pattern (Bar / Rail / Drawer)
- [ ] Animations use M3 standard easing

### Dark Theme
- [ ] Surface is not pure black (Uses Neutral Tone 6)
- [ ] On Surface is not pure white
- [ ] Primary uses Tone 80 (Brighter)
- [ ] Surface Tint is recognizable
- [ ] Contrast ratio ≥ 4.5:1

### Android Development
- [ ] Supports Dynamic Color (Android 12+)
- [ ] Falls back to static colors directly on lower versions
- [ ] Uses MaterialTheme (Compose) or Theme.Material3 (XML)

---

## Sources

Material Design 3 (m3.material.io) + Material Theme Builder + Official Jetpack Compose Component References.