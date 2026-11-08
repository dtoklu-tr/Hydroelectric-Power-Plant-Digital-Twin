# Validation Status

## Checked while assembling this repository

- `Simulink/HPP_Digital_Twin_Model.slx` is a readable Simulink archive (saved with R2023b) containing hydraulic/reservoir, turbine-generator, transformer/grid, and protection subsystems.
- `MATLAB/Plant_Model.m` is included exactly as written by the author. The 37 figures in `Results/MATLAB_Output/Figures/` were exported by the author from MATLAB after running the script.
- The MATLAB figures were cross-checked against the Python calculations in `Results/Tables/`:
  - 191.28 MW at the 237.55 m³/s reference flow, and 129.33 MW / 160.6 m³/s with one main unit out of service.
  - 86.4 % overall efficiency for the normal, reduced-flow and reduced-head scenarios, and 79.9 % for the reduced-efficiency cases.
  - Hydraulic, mechanical and electrical power for the five integrated scenarios (for example 221 / 199 / 191 MW for normal operation).
  - Reservoir volume and level falling to about 45 million m³ and 99.0 m after 24 hours.
  - Generator apparent power (about 68.8 MVA), transformer low/high-voltage currents (about 2,880 A / 258 A) and loading (about 86 % ONAN, 69 % ONAF).
- The English and Turkish DOCX reports are provided with PDF copies for easy viewing.
- `Results/generate_figures.py` runs end to end and reproduces the Python figures and tables.

## Not independently executed in this repository

- The Simulink model has not been simulated while preparing the repository.
- The MATLAB result tables (command-window outputs) are not included as files.

## Recommended before presenting as fully validated

1. Open and simulate `Simulink/HPP_Digital_Twin_Model.slx` and compare its outputs with the report values.
2. Optionally run `MATLAB/Export_Results.m` to add MATLAB result tables as CSV files.
