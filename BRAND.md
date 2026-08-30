# GiftPath Brand Guide

Derived from the landing page redesign mockup. This is the reference for bringing the rest of the app (About, Assessment, Saved, Account, Blog) up to the same level of polish. Existing tokens in `lib/core/theme.dart` already match the core palette below — this document extends them, it doesn't replace them.

## Voice

Calm, plain-spoken, unhurried. Short sentences. No hype, no corporate warmth, no exclamation points. Say what happens, not what it means ("Free to start, seven minutes to your first result" — not "Unlock your God-given potential today!"). Scripture is cited, never paraphrased into marketing copy.

## Color

| Token | Light | Dark | Use |
|---|---|---|---|
| `forest` | `#24392C` | `#2C4433` | Primary brand color. Dark panels, primary text on light, primary button outline. |
| `forest-deep` | `#16261B` | `#0F1712` | Gradient partner for `forest` on hero/CTA panels; darkest surface. |
| `gold` | `#C6A046` | `#D8B968` | Accent. CTAs, active states, node markers, eyebrows. Use sparingly — one accent per screen. |
| `gold-bright` | `#D8B968` | `#E9CD87` | Gold on dark backgrounds (hero panel titles, accent captions) — plain `gold` is too muddy on `forest`. |
| `cream` | `#F3ECDF` | `#10150F` | Page background. |
| `cream-dim` | `#EBE2D0` | `#161C13` | Section backgrounds that need to sit one step back from `cream` (e.g. "How it works" band). |
| `surface` | `#FFFCF7` | `#171D15` | Card backgrounds, inputs. |
| `ink` | `#17181A` | `#F1EEE2` | Primary text. |
| `moss` | `#53614F` | `#AEBAA5` | Secondary text, muted copy. |
| `moss-soft` | `#8A9484` | `#6E7A66` | Tertiary text — trust-row labels, footer captions. |

**Rule:** gold is a spotlight, not a fill. It marks the one primary action or the one accented label per view. If two things on a screen are gold, one of them shouldn't be.

The app has no dark mode today. These dark values exist so a future dark mode doesn't require re-deriving the palette — implement by swapping these tokens, not by inventing new colors.

## Typography

- **Display / headlines — Fraunces.** Weight 500–600 for headlines, 600 for card titles. Use the italic cut for a single emphasized phrase in a headline (e.g. "for *a reason*"), not for full sentences.
- **Body / UI — Inter.** Weight 500–700 for body copy, 700–900 for buttons and labels, 800–900 tracked uppercase for eyebrows.
- **One serif, one sans, nothing else.** The live app currently mixes Fraunces (lockup asset) and Cormorant Garamond (`GiftPathLogo` widget) for the same wordmark — pick Fraunces everywhere and delete the Cormorant Garamond usage in `lib/widgets/brand_mark.dart`.

Type scale (desktop):
- Hero headline: 76px / weight 600 / line-height .98 / letter-spacing -1px
- Section headline (h2): 44px / weight 600
- Card title: 21–23px / weight 600 (Fraunces)
- Body: 15–17px / weight 500, line-height 1.55–1.6
- Eyebrow: 12.5px / weight 800 / letter-spacing 1.9px / uppercase / gold

## Spacing & Radius — a tiered scale, not one flat value

The current app uses `borderRadius: 8` on literally everything (buttons, cards, chips, inputs — see `theme.dart`). That's the single biggest reason it reads as a solid internal tool rather than a premium product. Replace with a tier:

| Element | Radius |
|---|---|
| Buttons, chips, inputs | 12px |
| Standard cards | 16–20px |
| Hero / feature panels | 26–32px |
| Pills (nav links, tags) | 100px (full) |

Depth follows the same idea — not every card gets the same shadow:
- **Resting cards** (feature grid, list items): soft ambient shadow only — `0 20px 40px -32px rgba(shadow, .4)`, 1px hairline border at ~8% opacity.
- **Hover state**: lift 4px, deepen shadow — `0 28px 50px -30px rgba(shadow, .5)`.
- **Hero / CTA panels**: heavier shadow, no hairline border — `0 40px 80px -30px rgba(shadow, .55)`.

## Motion

- Section reveal: fade + 18px translateY on scroll into view, `.7s cubic-bezier(.2,.7,.3,1)`.
- Card hover: `translateY(-4px)` over `.25s`, same easing.
- Button hover: `translateY(-1px)` with shadow deepening, `.18s`.
- Respect `prefers-reduced-motion` — disable all of the above, snap to end state.
- The live app currently has no hover/press feedback and route transitions that visibly pop mid-animation (caught during QA) — motion is the single fastest way to make the app feel considered rather than static.

## Components

**Buttons**
- Primary: gold gradient fill (`gold-bright` → `gold`), `forest-deep` text, radius 12–14px. One primary CTA per screen — don't pair it with a second colored button.
- Secondary action: demote to a plain underlined text link (e.g. "How it works"), not a second outlined button competing for attention.
- Outline: 1.5px border at ~20% ink opacity, transparent fill.

**Cards** — see radius/depth table above. Icon badges inside cards use a dark gradient chip (`forest` → `forest-deep`) with a `gold-bright` icon, 13px radius.

**Nav** — sticky, blurred surface on scroll (`backdrop-filter: blur(14px)`), hairline border at ~8% opacity, not a hard shadow.

**Forms/inputs** — this is the weakest surface in the current app (the `/auth` screen uses bare Material text fields with no brand treatment). Bring inputs up to the same radius/surface tokens as cards; the auth screen should look like it belongs to the same product as the landing page, not a stock form.

**Empty states** — currently identical across Opportunities/My Gifts/Saved (icon chip + text + button). Vary the icon and supporting copy per context so they reinforce brand personality instead of reading as one template reused three times.

## Iconography & motif

The hero's dashed gold path connecting numbered stops is the strongest recurring device in the product — it already reappears as a decorative squiggle on the Blog page. Extend it deliberately:
- Empty states could use a faded single dash-and-node fragment instead of a generic icon.
- About page step lists could adopt the same numbered-node treatment instead of plain cards.
- Don't let it become wallpaper — it should mark a *sequence* (steps, progress), not decorate unrelated content.

Keep icons to simple 2px stroke line icons (see hero CTA arrow, trust-row check icons) — no filled/glyph-style icons mixed in.

## What to fix first (highest ROI)

1. Unify the wordmark font (Fraunces everywhere — drop Cormorant Garamond)
2. Redesign `/auth` to use brand tokens (highest-intent screen, currently the least branded)
3. Replace the flat 8px radius with the tiered scale above
4. Add hover/press motion and fix the route-transition pop
5. Fix mobile hero label collisions (see `lib/features/home/home_page.dart`)
6. Vary empty-state copy/iconography per context instead of reusing one template
