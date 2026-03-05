# AIΩN Observer Geometry I

LaTeX source for **Observer Geometry I: Beyond Distance**.

Observer Geometry I formalizes observer comparison beyond single-scalar
distance. It separates projection, basis, and accumulation to analyze
replayability, conflict visibility, and task reliability under resource limits,
with finite checkable witnesses.

## Links

- DOI: [10.5281/zenodo.18868896](https://doi.org/10.5281/zenodo.18868896)
- For more information and additional materials, please see the [AIΩN git repository](https://github.com/flyingrobots/aion).

## Files

- `observer_geometry_1.tex`: main manuscript source
- `observer_geometry_1.refs.bib`: bibliography database
- `Makefile`: build pipeline
- `.zenodo.json`: Zenodo deposition metadata

## Build Pipeline

### Requirements

- `pdflatex`
- `biber`
- `pdftotext` (only required for `make txt`)

### Commands

```bash
make       # same as: make pdf
make pdf   # build PDF to dist/observer_geometry_1.pdf (via .build/)
make txt   # extract text to dist/observer_geometry_1.txt with figure placeholders
make clean # remove .build/ and dist/
```

### Implementation Details

- Intermediate build artifacts are written to `.build/` (gitignored).
- Final artifacts are written to `dist/` (gitignored).

## Release Checklist

```bash
make clean
make pdf
make txt
```

### Expected artifacts

- `dist/observer_geometry_1.pdf`
- `dist/observer_geometry_1.txt`

## License

Licensed under Creative Commons Attribution 4.0 International (`CC BY 4.0`).
See `LICENSE`.

Copyright © 2026 James Ross.

## Citation

See `CITATION.cff` for machine-readable citation metadata.
