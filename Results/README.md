# Results

This folder contains selected CSV tables and presentation-ready PNG figures.

- `Tables/` – unit performance, flow/head sensitivity, 24-hour operation, reservoir balance, transformer rated currents, integrated operating scenarios, and a compact project summary.
- `Figures/` – nine Python plots that summarise the key relationships and example scenarios.
- `MATLAB_Output/` – the 37 figures exported from MATLAB (`Plant_Model.m`) with a figure index.
- `generate_figures.py` – regenerates all figures and tables from the stated reference parameters.

## Regenerate

From the repository root:

```bash
pip install -r requirements.txt
python Results/generate_figures.py
```

## Notes

- **Provenance:** `MATLAB_Output/` holds figures exported from MATLAB. `Figures/` and `Tables/` are computed in Python from the same equations and reference parameters (`MATLAB/Plant_Model.m` and the reports) and are not MATLAB execution logs.
- **Rounding:** the integrated scenarios use a rounded reference flow of 237.55 m³/s, so *Normal Operation* gives 191.28 MW (191.276 MW before rounding), while the unit-level table uses the exact flow (≈ 237.5545 m³/s) and gives exactly 191.28 MW.
- **Scope:** all values are educational model results, not measured plant data.
