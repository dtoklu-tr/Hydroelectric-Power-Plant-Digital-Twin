# Modelling Methodology

## 1. Hydraulic power

The available hydraulic power is calculated from:

$$
P_h = \rho g Q H_n
$$

where $\rho$ is water density, $g$ is gravitational acceleration, $Q$ is flow rate, and $H_n$ is net head.

## 2. Energy conversion

The simplified conversion chain is:

$$
P_m = P_h\eta_t, \qquad P_e = P_m\eta_g
$$

where $\eta_t$ and $\eta_g$ are turbine and generator efficiencies. The model applies an installed-capacity limit where specified.

## 3. Unit-level modelling

Three main Francis units and one ecological-flow unit are represented using their reference installed ratings. Nominal unit flow is estimated from rated electrical power, net head, and assumed overall efficiency.

## 4. Time-dependent operation

A 24-hour example schedule represents selected unit outages. Hourly energy is calculated using one-hour intervals. Reservoir volume is updated using a simplified continuity equation:

$$
V_{k+1}=V_k+(Q_{in,k}-Q_{out,k})\Delta t
$$

## 5. Electrical interface

The generator, transformer, and grid interface calculations use standard three-phase relationships for apparent power and current. Transformer and line-loss cases are illustrative scenarios.

## 6. Protection examples

Threshold checks demonstrate how abnormal voltage, frequency, current, or transformer loading can be flagged. They are not protection coordination studies and must not be treated as operational settings.
