# Simulink Model

`HPP_Digital_Twin_Model.slx` is the supplied Simulink model for the hydropower digital-twin study.

The top-level model contains the following subsystems:

- `Hydraulics_and_Reservoir`
- `Turbine_Generator_System`
- `Transformer_and_Grid`
- `Protection_System`

The model also includes signal monitoring blocks such as Scopes and a Display. Open the model in Simulink to inspect the internal subsystems and signal paths. The screenshots in `../Assets/` show the hydraulic-power calculation and the electrical-power conversion chain.

MATLAB/Simulink R2023b or a compatible later release is recommended. Some block parameters or Scope settings may need adjustment in other releases.
