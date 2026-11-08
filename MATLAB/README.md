# MATLAB Model

`Plant_Model.m` is the main calculation script for the hydropower digital-twin study. It includes:

- Physical constants and hydraulic parameters
- Unit-level flow and power calculations
- Flow-rate and net-head sensitivity
- Operating scenario comparisons
- Simplified reservoir water balance
- 24-hour unit operating schedule
- Francis turbine efficiency curve
- Generator active/reactive power and current calculations
- Transformer loading and grid-interface calculations
- Illustrative protection and fault scenarios
- Integrated operating-point comparison

## Run

Open `Plant_Model.m` in MATLAB and run the script. The script creates figures and displays result tables in the Command Window.

After a successful run, `Export_Results.m` can export open figures and selected tables to `Results/MATLAB_Output/Auto_Export/`. It reruns `Plant_Model.m` first, so allow the complete calculation script to finish before reviewing the exports.

`Plant_Model.m` is included exactly as written by the author. Review the assumptions and limitations before using its numerical results.
