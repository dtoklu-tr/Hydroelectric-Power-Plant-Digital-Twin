# Model Assumptions and Limitations

## Reference parameters

| Parameter | Value | Status |
|---|---:|---|
| Main Francis units | 3 | Reference configuration supplied for the project |
| Main unit rating | 61.95 MW each | Reference input; not independently verified here |
| Ecological unit rating | 5.43 MW | Reference input; not independently verified here |
| Total installed capacity | 191.28 MW | Derived from the unit ratings |
| Gross head | 100 m | Model assumption |
| Hydraulic losses | 5 m | Model assumption |
| Net head | 95 m | Derived value |
| Turbine efficiency | 0.90 | Model assumption |
| Generator efficiency | 0.96 | Model assumption |
| Reference total flow | about 237.55 m³/s | Derived from ratings and assumed efficiency/head |

## Important limitations

1. No verified plant SCADA data or historical operating time series are included.
2. Efficiency values are simplified and may vary with flow, head, loading, and machine condition.
3. Reservoir dynamics use a simplified volume balance and constant surface-area approximation.
4. Water hammer, detailed penstock dynamics, governor response, and generator electromagnetic transients are not fully represented.
5. Transformer and line calculations use illustrative equipment and impedance assumptions; the plant single-line diagram must be checked before any real-world interpretation.
6. Protection thresholds are examples for learning only. They are not relay settings, protection coordination, or operating procedures.
7. Results from different loading scenarios must not be combined unless they refer to the same operating point and assumptions.

All reported values should be interpreted as educational model results, not guaranteed plant performance or measured data.
