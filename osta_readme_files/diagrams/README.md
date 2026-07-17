# 📐 Diagrams / المخططات

> [INDEX](../INDEX.md) > Diagrams

Hand-authored architecture/flow diagrams. Source-of-truth is the **SVG itself**
(no build step, no generator) — edit the SVG, it renders inline on GitHub and
scales crisply. A **PNG render sits beside each SVG** (2× raster, white
background) for anywhere raster is needed. All diagrams share one visual system
so the set reads as a family.

> ‏مخططات معمارية/تدفّق مكتوبة يدويًا. المصدر هو ملف **SVG** نفسه (بلا خطوة بناء) —
> عدّل الـ SVG مباشرة؛ يُعرض داخل GitHub ويتوسّع بوضوح. كل المخططات تشترك في نظام
> ألوان واحد.

## The set / المجموعة

| Diagram | Depicts | Source of truth |
|---|---|---|
| [`register_flow.png`](register_flow.png) | First-run + role split + both onboarding gates | `lib/core/router/session_redirect.dart` |
| [`routing_guard.svg`](routing_guard.svg) | `resolveRedirect()` decision ladder (splash → gates → shell) | [`session_redirect.dart`](../../lib/core/router/session_redirect.dart), [`app_routes.dart`](../../lib/core/router/app_routes.dart), [`session_state.dart`](../../lib/core/session/session_state.dart) |
| [`http_auth_refresh.svg`](http_auth_refresh.svg) | Request path + queued 401 refresh-once + typed `ApiException` | [`02_architecture.md`](../guides/02_architecture.md), `lib/core/network/` |
| [`booking_funnel.svg`](booking_funnel.svg) | service → slot → 10-min hold → confirm → live status | [`booking-funnel.md`](../features/booking-funnel.md) (epic #44) |
| [`clean_architecture_bloc.svg`](clean_architecture_bloc.svg) | 3-layer dependency rule + event→state cycle + error boundary | [`02_architecture.md`](../guides/02_architecture.md) |

## Palette / لوحة الألوان

Sampled pixel-exact from `register_flow.png`. Reuse these tokens for any new
diagram. Each SVG carries them in an inline `<style>` block as classes
(`.customer` `.business` `.gate` `.shared`, `-t` suffix for text/border).

| Bucket | Fill | Border + text |
|---|---|---|
| **customer** (B2C) | `#e1f5ee` | `#0f6e56` |
| **business** (B2B) | `#eeedfe` | `#534ab7` |
| **server gate · fails open** | `#faeeda` | `#854f0b` |
| **shared / neutral / predicate** | `#f1efe8` | border `#e2e0d9`, text `#444441` |
| arrows / edges | — | `#888780` |
| error / recovery branch (accent) | `#f7e7e4` | `#b04a3f` |

Background `#ffffff` (so text stays readable in a dark README theme). Font stack
`-apple-system, 'Segoe UI', Roboto, system-ui, sans-serif`. Rounded rects ~12px;
dashed edges = return/recovery; the orange **gate** color marks a server-derived
check that **fails open** (fires on an explicit `false`, falls through on `null`).

## Adding a diagram / إضافة مخطط

1. Copy the `<defs>` + `<style>` header from any existing SVG.
2. Lay out with `<rect rx="12">` nodes and `<path class="edge" marker-end>` arrows.
3. Colour nodes by role bucket; keep a legend row up top.
4. `xmllint --noout your.svg` to check it's well-formed, then eyeball it in a browser.
5. Keep every element inside the `viewBox` — browsers show SVG overflow, but a PNG render crops to the `viewBox` and silently clips it.
6. Add a row to the table above.

## Regenerating the PNGs / إعادة توليد الصور

The PNGs are a 2× raster of the SVGs via [`sharp`](https://sharp.pixelplumbing.com/)
(librsvg + pango, no system deps). One-off — not wired into CI:

```bash
npm i sharp   # transient; don't add to the app's package deps
node -e '
  const sharp=require("sharp"), {readFileSync}=require("fs");
  for (const f of ["routing_guard","http_auth_refresh","booking_funnel","clean_architecture_bloc"])
    sharp(readFileSync(f+".svg"),{density:144}).flatten({background:"#ffffff"}).png({compressionLevel:9}).toFile(f+".png");
'
```

`density:144` = 2× (SVG base is 72 dpi). Bump to `216` for 3×.
