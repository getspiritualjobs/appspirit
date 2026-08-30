# Porting `landing-reference.html` into Flutter

`design/landing-reference.html` is the approved visual target for the app — open it in a browser and treat it as the source of truth for look and feel. It is a self-contained page (Google Fonts + inline CSS, no build step). The only edit from the original is that the inlined base64 logo was swapped for `../assets/giftpath-mark.png` so the file stays readable.

This document maps that CSS to Flutter, and records what is already ported vs. what is still missing.

## Status

**Already ported** (in `lib/core/theme.dart`, `lib/widgets/`, `lib/features/home/home_page.dart`):
- Color tokens, type scale (Fraunces headings / Inter body), tiered radii, card shadows
- Page structure: hero, scripture band, feature grid, how-it-works + sample result, CTA band, footer
- Frosted-blur app bar, pill nav links, button hover/press states

**Not yet ported — this is the gap that makes the app feel flatter than the HTML:**
1. **Scroll reveal** — every major section fades up on entering the viewport
2. **Hero path draw-on** — the dashed gold path animates drawing itself on load
3. **Card hover lift** — feature cards translate up 4px on hover

Items 1–3 are the "feel" difference. Everything else is static styling that already matches.

---

## Motion specs (the missing layer)

### 1. Scroll reveal
```css
.reveal    { opacity: 0; transform: translateY(18px);
             transition: opacity .7s ease,
                         transform .7s cubic-bezier(.2,.7,.3,1); }
.reveal.in { opacity: 1; transform: none; }
```
Triggered by an IntersectionObserver at `threshold: 0.12`, and it **unobserves after firing** — each section animates once, never replays on scroll-up.

Flutter equivalent: wrap each section in a `VisibilityDetector` (package `visibility_detector`) or a scroll-offset check, driving an `AnimatedOpacity` + `AnimatedSlide` with:
- duration `700ms`
- opacity curve `Curves.ease`
- offset curve `Cubic(.2, .7, .3, 1)`
- start offset `Offset(0, 18 / heightOfWidget)` — `AnimatedSlide` is fraction-based, so 18px must be converted, or use `Transform.translate` inside a `TweenAnimationBuilder` to keep it in logical pixels.
- Fire once; keep a `bool _shown` so it does not re-run.

### 2. Hero path draw-on
```css
.path-track-draw { stroke-dasharray: 900; stroke-dashoffset: 900;
                   animation: draw 2.2s cubic-bezier(.3,.7,.2,1) .3s forwards; }
@keyframes draw  { to { stroke-dashoffset: 0; } }
```
Flutter equivalent: `_HeroPathPainter` already builds the `Path`. Add an `AnimationController` (duration `2200ms`, delay `300ms`, curve `Cubic(.3,.7,.2,1)`) and pass its value `t` into the painter; inside `paint`, instead of drawing the whole path, draw `metric.extractPath(0, metric.length * t)` before applying the dash loop. Nodes should pop in as the line passes them (compare each node's distance-along-path to `metric.length * t`).

### 3. Card hover lift
```css
.feature-card         { transition: transform .25s cubic-bezier(.2,.7,.3,1),
                                    box-shadow .25s ease, border-color .25s ease; }
.feature-card:hover   { transform: translateY(-4px);
                        box-shadow: 0 28px 50px -30px rgba(...,.5); }
```
Flutter equivalent: `MouseRegion` + `AnimatedContainer` (250ms, `Cubic(.2,.7,.3,1)`), translating `-4px` and swapping to the deeper shadow.

Respect `prefers-reduced-motion` — the HTML disables all of the above under that query; use `MediaQuery.of(context).disableAnimations` in Flutter.

---

## Token mapping (CSS → `BrandTokens`)

| CSS variable | Hex | Flutter |
|---|---|---|
| `--forest` | `#24392C` | `BrandTokens.forest` |
| `--forest-deep` | `#16261B` | `BrandTokens.forestDeep` |
| `--gold` | `#C6A046` | `BrandTokens.gold` |
| `--gold-bright` | `#D8B968` | `BrandTokens.goldBright` |
| `--cream` | `#F3ECDF` | `BrandTokens.cream` |
| `--cream-dim` | `#EBE2D0` | `BrandTokens.creamDim` |
| `--surface` | `#FFFCF7` | `BrandTokens.surface` |
| `--ink` | `#17181A` | `BrandTokens.ink` |
| `--moss` | `#53614F` | `BrandTokens.moss` |
| `--moss-soft` | `#8A9484` | `BrandTokens.mossSoft` |

The reference file also defines a full dark-mode token set under `prefers-color-scheme: dark`. The Flutter app has no dark mode yet; those values are the palette to use when it gets one.

## Type mapping

| Role | CSS | Flutter |
|---|---|---|
| Hero headline | Fraunces 600, `clamp(40px,6vw,76px)`, `line-height .98`, `letter-spacing -1px`; second line italic 500 in `--forest` | `home_page.dart` hero `Text.rich` |
| Section h2 | Fraunces 600, `clamp(30px,4vw,44px)` | `textTheme.displayMedium` |
| Card title | Fraunces 600, 20–23px | `textTheme.titleLarge` |
| Body | Inter 500, 15–17px, `line-height 1.55–1.6`, color `--moss` | `textTheme.bodyLarge` / `bodyMedium` |
| Eyebrow | Inter 800, 12.5px, `letter-spacing 1.9px`, uppercase, `--gold` | `BrandEyebrow` |

**Never use Inter for a heading** — the app previously rendered headings in Inter Black, which was the single biggest reason it did not match this page.

## Radius / depth

| Element | CSS | Flutter |
|---|---|---|
| Buttons, inputs, chips | 12–14px | `BrandTokens.radiusSm` (12) |
| Cards | 16–20px | `BrandTokens.radiusMd` (20) |
| Hero / CTA panels | 26–32px | `BrandTokens.radiusLg` (32) |
| Nav links, pills, tags | 100px | `StadiumBorder()` |

Resting card shadow `0 20px 40px -32px rgba(shadow,.4)`; hero/CTA `0 40px 80px -30px rgba(shadow,.55)`. Flutter's default Material elevation is far tighter than this — use explicit `BoxShadow` with a large `blurRadius` and a downward offset, as `InfoCard` now does.

## Gotcha: release builds

A `const` widget subtree in `home_page.dart` that analyzed clean in debug broke `flutter build web --release` (fixed in `556c5ca`). When adding widgets here, prefer `final` locals with `const` only on leaf widgets, and always confirm against the **release** build, not just `flutter run`.
