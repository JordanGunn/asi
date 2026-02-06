# Presentation Build (Marp)

This folder contains a one-file-per-slide Markdown deck (`01_*.md`, `02_*.md`, …) plus a small build pipeline using **Marp**.

## Quick start

```bash
cd presentation
npm install
npm run build
```

Outputs:

- `presentation/dist/skills.html`
- `presentation/dist/skills.pdf`
- `presentation/dist/skills.pptx` (only if your Marp CLI build supports `--pptx`)

## How it works

- `assemble.sh` concatenates `01_*.md` … `NN_*.md` into `DECK.md` with Marp frontmatter and slide separators.
- `build.sh` runs `assemble.sh`, then exports HTML/PDF (and attempts PPTX).

## Notes on PPTX

Marp’s PPTX export support can vary by version/build. If `./build.sh` can’t produce a PPTX:

- you still get `skills.pdf` and `skills.html`, and
- you can produce PPTX using Pandoc as an alternative path.
