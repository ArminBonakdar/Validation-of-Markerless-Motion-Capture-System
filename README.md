# Validation-of-Markerless-Motion-Capture-System

Ergonomic-Risk-Assessment-using-ML-OMC

This project focuses on validating a markerless optical motion capture (ML-OMC) system for ergonomic risk assessment during manual lifting tasks. The system was benchmarked against a marker-based OMC (MB-OMC) and inertial measurement units (IMUs).


## 📄 Publication

This project resulted in a peer-reviewed open-access paper:

> Bonakdar, A., et al. (2024). *Ergonomic Risk Assessment in Manual Handling Tasks Using Markerless Optical Motion Capture*. **Journal of NeuroEngineering and Rehabilitation**.  
> 🔗 [Read the full article here](https://doi.org/10.1016/j.ergon.2025.103734)

Study Overview:
Work-related musculoskeletal disorders (WMSDs) often result from awkward postures and heavy lifting. This project aimed to assess the potential of ML-OMC systems to estimate joint kinematics and calculate ergonomic scores accurately in such scenarios.

Methodology
Inputs:
Participants
- 8 healthy individuals (4 males, 4 females)
- Age: 25 ± 3 years
- Height: 166 ± 7 cm
- Body Mass: 61 ± 7 kg

Measurement Systems:
- ML-OMC: Vision-based markerless optical motion capture
- MB-OMC: Vicon, Oxford Metric, UK | Sampling Frequency: 100 Hz
- IMUs: MTws, Xsens Technologies, NL | Sampling Frequency: 40 Hz
- Force Plate: AMTI OR6-7-OP, USA | Sampling Frequency: 1200 Hz

Task: Lifting a 28 lbs. (12.7 kg) box from the floor to pelvis height while standing with each foot on a force plate.

- Joint Angles Recorded: Back, neck, knee, elbow, shoulder
  
- Biomechanical Modeling: Joint reaction forces estimated using joint angle data and ground reaction forces.

Data Processing:
- All datasets were downsampled to 40 Hz for synchronization.
- Alignment was performed using the hip joint angle peak as a reference across systems.

