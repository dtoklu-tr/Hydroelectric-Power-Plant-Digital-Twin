"""Regenerate the companion figures and CSV tables of the
Hydroelectric Power Plant Digital Twin project.

All values are computed from the reference parameters and equations used in
``MATLAB/Plant_Model.m`` and in the project reports. The outputs are
educational model results, not measured plant data.

Usage (from the repository root):
    python Results/generate_figures.py
"""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
FIG_DIR = ROOT / "Results" / "Figures"
TAB_DIR = ROOT / "Results" / "Tables"
FIG_DIR.mkdir(parents=True, exist_ok=True)
TAB_DIR.mkdir(parents=True, exist_ok=True)

plt.rcParams.update({
    "font.size": 11,
    "axes.titlesize": 15,
    "axes.labelsize": 12,
    "axes.grid": True,
    "grid.alpha": 0.3,
})

# ---------------------------------------------------------------------------
# Reference parameters (model inputs / assumptions)
# ---------------------------------------------------------------------------
RHO, G = 1000.0, 9.81                       # kg/m^3, m/s^2
GROSS_HEAD, HEAD_LOSS = 100.0, 5.0          # m
NET_HEAD = GROSS_HEAD - HEAD_LOSS           # 95 m
ETA_T, ETA_G = 0.90, 0.96
ETA = ETA_T * ETA_G                         # 0.864

UNIT_NAMES = ["Francis Unit 1", "Francis Unit 2", "Francis Unit 3", "Ecological Unit"]
UNIT_MW = np.array([61.95, 61.95, 61.95, 5.43])
INSTALLED = UNIT_MW.sum()                   # 191.28 MW

# Nominal flow of each unit, from rated electrical power, net head and efficiency
unit_flow = UNIT_MW * 1e6 / (RHO * G * NET_HEAD * ETA)
TOTAL_FLOW = unit_flow.sum()                # ~237.55 m^3/s

# ---------------------------------------------------------------------------
# Tables
# ---------------------------------------------------------------------------
# 1) Unit performance
hydraulic = RHO * G * unit_flow * NET_HEAD / 1e6
mechanical = hydraulic * ETA_T
electrical = mechanical * ETA_G
pd.DataFrame({
    "Unit": UNIT_NAMES,
    "Installed_Power_MW": UNIT_MW,
    "Flow_Rate_m3_s": unit_flow,
    "Hydraulic_Power_MW": hydraulic,
    "Mechanical_Power_MW": mechanical,
    "Electrical_Power_MW": electrical,
}).to_csv(TAB_DIR / "unit_performance.csv", index=False)

# 2) Flow and net-head sensitivity
q = np.linspace(0, TOTAL_FLOW * 1.2, 150)
p_flow = np.minimum(RHO * G * q * NET_HEAD * ETA / 1e6, INSTALLED)
pd.DataFrame({"Flow_Rate_m3_s": q, "Electrical_Power_MW": p_flow}) \
    .to_csv(TAB_DIR / "flow_sensitivity.csv", index=False)

h = np.linspace(70, 110, 150)
p_head = np.minimum(RHO * G * TOTAL_FLOW * h * ETA / 1e6, INSTALLED)
pd.DataFrame({"Net_Head_m": h, "Electrical_Power_MW": p_head}) \
    .to_csv(TAB_DIR / "net_head_sensitivity.csv", index=False)

# 3) 24-hour unit availability schedule (as in Plant_Model.m)
hours = np.arange(24)
schedule = np.ones((24, 4))
schedule[6:12, 2] = 0       # Francis Unit 3 out, hours 06-11
schedule[18:24, 1] = 0      # Francis Unit 2 out, hours 18-23
hourly_power = schedule @ UNIT_MW
hourly_flow = schedule @ unit_flow
pd.DataFrame({
    "Hour": hours,
    "Total_Flow_m3_s": hourly_flow,
    "Electrical_Power_MW": hourly_power,
    "Energy_MWh": hourly_power,          # one-hour intervals
}).to_csv(TAB_DIR / "hourly_operating_schedule.csv", index=False)

# 4) Integrated operating scenarios (Stage 12)
scenarios = ["Normal Operation", "Reduced Flow", "Reduced Net Head",
             "Reduced Efficiency", "Combined Degradation"]
q12 = np.array([237.55, 190, 237.55, 237.55, 190])
h12 = np.array([95, 95, 85, 95, 85])
eta_t12 = np.array([0.90, 0.90, 0.90, 0.85, 0.85])
eta_g12 = np.array([0.96, 0.96, 0.96, 0.94, 0.94])
ph12 = RHO * G * q12 * h12 / 1e6
pm12 = ph12 * eta_t12
pcalc12 = pm12 * eta_g12
pe12 = np.minimum(pcalc12, INSTALLED)
eff12 = pe12 / ph12 * 100
pd.DataFrame({
    "Scenario": scenarios,
    "Flow_m3_s": q12,
    "Net_Head_m": h12,
    "Hydraulic_Power_MW": ph12,
    "Mechanical_Power_MW": pm12,
    "Calculated_Electrical_Power_MW": pcalc12,
    "Capacity_Limited_Electrical_Power_MW": pe12,
    "Overall_Efficiency_percent": eff12,
}).to_csv(TAB_DIR / "integrated_scenarios.csv", index=False)

# 5) Simplified reservoir water balance (constant surface area)
DT = 3600.0                  # s
AREA = 5e6                   # m^2
V0, L0 = 50e6, 100.0         # m^3, m
inflow = 180 + 20 * np.sin(2 * np.pi * np.arange(25) / 24)
volume = np.zeros(25)
level = np.zeros(25)
volume[0], level[0] = V0, L0
for k in range(24):
    volume[k + 1] = max(volume[k] + (inflow[k] - TOTAL_FLOW) * DT, 0)
    level[k + 1] = L0 + (volume[k + 1] - V0) / AREA
pd.DataFrame({
    "Hour": np.arange(25),
    "Inflow_m3_s": inflow,
    "Outflow_m3_s": TOTAL_FLOW,
    "Reservoir_Volume_m3": volume,
    "Reservoir_Level_m": level,
}).to_csv(TAB_DIR / "reservoir_balance_example.csv", index=False)

# 6) Transformer rated currents (13.8 / 154 kV)
S_MVA = np.array([80, 100])
V_LV, V_HV = 13.8, 154.0
i_lv = S_MVA * 1e6 / (np.sqrt(3) * V_LV * 1e3)
i_hv = S_MVA * 1e6 / (np.sqrt(3) * V_HV * 1e3)
pd.DataFrame({
    "Rated_Power_MVA": S_MVA,
    "LV_Voltage_kV": V_LV,
    "HV_Voltage_kV": V_HV,
    "LV_Current_A": i_lv,
    "HV_Current_A": i_hv,
}).to_csv(TAB_DIR / "transformer_rated_currents.csv", index=False)

# 7) Compact project summary
pd.DataFrame({
    "Metric": ["Installed capacity", "Reference net head", "Reference total flow",
               "Overall efficiency", "Reference hydraulic power",
               "Reference electrical power", "Daily energy (24-hour schedule)"],
    "Value": [INSTALLED, NET_HEAD, TOTAL_FLOW, ETA * 100,
              RHO * G * TOTAL_FLOW * NET_HEAD / 1e6,
              min(RHO * G * TOTAL_FLOW * NET_HEAD * ETA / 1e6, INSTALLED),
              hourly_power.sum()],
    "Unit": ["MW", "m", "m³/s", "%", "MW", "MW", "MWh"],
}).to_csv(TAB_DIR / "project_summary.csv", index=False)


# ---------------------------------------------------------------------------
# Figures
# ---------------------------------------------------------------------------
def finish(name, title, xlabel, ylabel):
    plt.title(title, pad=12)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.tight_layout()
    plt.savefig(FIG_DIR / name, dpi=220, bbox_inches="tight")
    plt.close()


# 01 Electrical power by unit
plt.figure(figsize=(10, 5.8))
plt.bar(UNIT_NAMES, electrical)
plt.xticks(rotation=12, ha="right")
finish("01_unit_electrical_power.png", "Electrical Power by Generating Unit",
       "Generating Unit", "Electrical Power (MW)")

# 02 Flow distribution
plt.figure(figsize=(10, 5.8))
plt.bar(UNIT_NAMES, unit_flow)
plt.xticks(rotation=12, ha="right")
finish("02_unit_flow_distribution.png", "Water Flow Distribution by Generating Unit",
       "Generating Unit", "Flow Rate (m³/s)")

# 03 Power vs flow
plt.figure(figsize=(9, 5.6))
plt.plot(q, p_flow, linewidth=2)
plt.axvline(TOTAL_FLOW, linestyle="--", label=f"Reference flow: {TOTAL_FLOW:.2f} m³/s")
plt.axhline(INSTALLED, linestyle=":", label=f"Installed capacity: {INSTALLED:.2f} MW")
plt.legend()
finish("03_flow_power_sensitivity.png", "Plant Power vs Total Flow Rate",
       "Total Flow Rate (m³/s)", "Electrical Power (MW)")

# 04 Power vs net head
plt.figure(figsize=(9, 5.6))
plt.plot(h, p_head, linewidth=2)
plt.axvline(NET_HEAD, linestyle="--", label=f"Reference net head: {NET_HEAD:.1f} m")
plt.axhline(INSTALLED, linestyle=":", label=f"Installed capacity: {INSTALLED:.2f} MW")
plt.legend(loc="lower right")
finish("04_net_head_sensitivity.png", "Plant Power vs Net Head",
       "Net Head (m)", "Electrical Power (MW)")

# 05 24-hour power profile (each value holds for its full hour)
plt.figure(figsize=(10, 5.6))
plt.step(hours, hourly_power, where="post", linewidth=2)
plt.scatter(hours, hourly_power, s=18, zorder=3)
plt.xticks(range(0, 24, 2))
finish("05_24_hour_power_profile.png", "24-Hour Electrical Power Profile",
       "Hour of day", "Electrical Power (MW)")

# 06 Integrated conversion by scenario
plt.figure(figsize=(12, 6))
x, w = np.arange(len(scenarios)), 0.25
plt.bar(x - w, ph12, w, label="Hydraulic")
plt.bar(x, pm12, w, label="Mechanical")
plt.bar(x + w, pe12, w, label="Electrical (capacity limited)")
plt.xticks(x, scenarios, rotation=17, ha="right")
plt.legend()
finish("06_integrated_power_conversion.png",
       "Integrated Hydraulic-to-Electrical Power Conversion",
       "Operating Scenario", "Power (MW)")

# 07 Overall efficiency by scenario
plt.figure(figsize=(11, 5.6))
plt.bar(scenarios, eff12)
plt.xticks(rotation=17, ha="right")
plt.ylim(0, 100)
finish("07_scenario_efficiency.png", "Overall Efficiency by Operating Scenario",
       "Operating Scenario", "Overall Efficiency (%)")

# 08 Reservoir level
plt.figure(figsize=(9, 5.6))
plt.plot(np.arange(25), level, linewidth=2)
plt.scatter(np.arange(25), level, s=16, zorder=3)
finish("08_reservoir_level_example.png", "Illustrative Reservoir Level Variation",
       "Hour", "Reservoir Level (m)")

# 09 Transformer rated currents
plt.figure(figsize=(8, 5.5))
x, w = np.arange(2), 0.34
plt.bar(x - w / 2, i_lv, w, label="13.8 kV side")
plt.bar(x + w / 2, i_hv, w, label="154 kV side")
plt.xticks(x, ["80 MVA", "100 MVA"])
plt.legend()
finish("09_transformer_rated_currents.png", "Transformer Rated Current Comparison",
       "Transformer Rating", "Current (A)")

print(f"Generated {len(list(FIG_DIR.glob('*.png')))} figures and "
      f"{len(list(TAB_DIR.glob('*.csv')))} tables.")
print(f"Installed: {INSTALLED:.2f} MW | Reference flow: {TOTAL_FLOW:.2f} m3/s | "
      f"Daily energy: {hourly_power.sum():.2f} MWh")
