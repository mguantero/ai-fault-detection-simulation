# AI-Based Fault Detection in Communication Transmission Lines

This repository contains a MATLAB-based simulation for **fault detection in communication transmission lines** using **AI-based classification and electromagnetic feature analysis**. It enables researchers and engineers to classify common transmission line faults such as Normal, Open, Short, and Mismatch using physically interpretable parameters like the reflection coefficient and VSWR. The simulation leverages Support Vector Machine (SVM) classification to detect and classify these faults with high accuracy.

---

## 🚀 Features

- **Fault Modeling**: Simulates four primary fault types:
  - Normal (Matched Load)
  - Open Faults
  - Short Faults
  - Impedance Mismatch
- **Electromagnetic Feature Extraction**:
  - Reflection coefficient (\(\Gamma\)) — magnitude and phase
  - Voltage Standing Wave Ratio (VSWR)
  - Complex Permittivity (\(\varepsilon' - j\varepsilon''\))
  - Conductivity (\(\sigma\)).
- **Classification**:
  - Multi-class Support Vector Machine (SVM) with Radial Basis Kernel Function.
  - Achieves high classification accuracy with clear decision boundaries.
- **Interactive GUI** (Optional):
  - Users can manually input transmission line parameters or simulate new data.
  - Predicts fault type with intuitive color-coded visualizations.

---

## 🔧 Requirements

- **MATLAB**: Version R2020a or later (tested in R2023a).
- **Toolboxes**:
  - Statistics and Machine Learning Toolbox (for SVM).
  - Signal Processing Toolbox (optional, for advanced visualization).

---

## 📂 Repository Structure

```plaintext
.
├── README.md            # Repository instructions and details.
├── simulate_fault_classification.m  # Main simulation script.
├── matlab_functions/    # Custom helper functions folder.
│   ├── extract_features.m  # Sub-functions for feature processing.
│   ├── svm_train_eval.m     # SVM training and testing.
│   └── plot_results.m       # Visualization utilities.
├── data/                # (Optional) Stores results, datasets, or logs.
└── LICENSE              # License details for open-source usage.
```

---

## 🛠️ Usage

### Clone the Repository
Use the following command to clone this repository:
```bash
git clone https://github.com/mguantero/ai-based-fault-detection
cd ai-based-fault-detection
```

### Run the Main Script
1. Open MATLAB.
2. Navigate to the repository folder.
3. Run the `simulate_fault_classification.m` script:
   ```matlab
   simulate_fault_classification
   ```

---

## 📝 Simulation Details

### 1. Fault Cases
Each fault is modeled with its corresponding impedance and physical properties:
- **Normal (Matched)**:
  - Reflection coefficient (\(|\Gamma| \ll 0.05\)) and VSWR ~1.
- **Open Faults**:
  - Large resistance (\(Z_L \gg Z_0\)) with maximal reflections (\(|\Gamma| \to 1\)).
- **Short Faults**:
  - Small resistance (\(Z_L \ll Z_0\)) with phase inversion (phase ~ \(\pi\)).
- **Mismatch**:
  - Impedance randomly scaled between \(2.5 Z_0\) and \(4 Z_0\).

### 2. Features Extracted:
Key parameters computed for each transmission line configuration include:
- **Reflection Coefficient (\(\Gamma\))**: Derived as \((Z_L - Z_0) / (Z_L + Z_0)\).
- **Voltage Standing Wave Ratio (VSWR)**: Calculated as \((1 + |\Gamma|) / (1 - |\Gamma|)\).
- **Material Loss**:
  - Real Permittivity (\(\varepsilon' = 2\)) and Imaginary Permittivity (\(\varepsilon''\)).
  - Conductivity derived as \(\sigma \approx \omega \varepsilon_0 \varepsilon''\).

### 3. Dataset Generation:
Each fault class contributes 500 synthetic examples with randomized feature perturbations to mimic real-world noise and variability.

---

## 🖼️ Example Outputs

1. **Reflection Coefficient and Fault Separation**:
   ![Sample Output for Reflection Coefficient](./images/reflection_distribution.png)

2. **Classification Results**:
   - Confusion Matrix:
     ```
     Normal  Open  Short  Mismatch
     Normal    100    0     0       0
     Open        0   99     1       0
     Short       0    0    99       1
     Mismatch    0    0     2      98
     ```
   - Accuracy: **99.0%**

---

## 📊 Results and Findings

- **Accuracy**: The simulation achieves 99.0% classification accuracy using SVM.
- **Feature Separation**:
  - Effective feature classes, especially \(|\Gamma|\) and VSWR, offer intuitive diagnostic insights.
  - Incorporating material properties improves interpretability for Short Faults.

---

## 🔗 Quick Access to Code

For the full MATLAB code, visit the corresponding files in the repository:
- Dataset simulation and SVM: [`simulate_fault_classification.m`](./simulate_fault_classification.m)
- Helper functions in: [`matlab_functions/`](./matlab_functions/)

---

## 🤝 Acknowledgements

This simulation is inspired by:
- Pozar, D. *Microwave Engineering* (2011).
- Cortes, C., and Vapnik, V., *Support-Vector Networks* (1995).
- MATLAB documentation for SVMs.

---

## 🔑 License

This repository is licensed under the **MIT License**. See [LICENSE](./LICENSE) for more details.

---

## 📬 Contact

For support or inquiries, please reach out via:
- **GitHub Issues**: [Open an Issue](https://github.com/mguantero/ai-based-fault-detection/issues)
- **Email**: mguantero@example.com (Replace with your email)
