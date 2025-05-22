# POSSR
# Patch-Based Optimization for Noise-Robust Reconstruction of Specular Surfaces

This repository provides the implementation and dataset for the paper:

> **Patch-Based Optimization for Noise-Robust Reconstruction of Specular Surfaces**  
> *Saed Moradi, M. Hadi Sepanj, Amir Nazemi, Claire Preston, Anthony M. D. Lee, and Paul Fieguth*  
>  2025  
> [📄 PDF]() | [📊 Data](https://github.com/moradisaed/POSSR/blob/main/reconstruction/threePlaneData4X.mat)

---

## 🔍 Overview

Reconstructing specular (mirror-like) surfaces from a single camera view is a highly challenging problem in computer vision. This work proposes a **patch-based optimization framework** that leverages geometric and optical constraints to produce a dense and robust depth map, even under significant noise in point correspondences.

---

## 🔧 Methodology

We formulate the inverse problem of specular surface reconstruction as a local optimization problem that aligns:

- Normals estimated from reflection geometry
- Normals obtained via local plane fitting

The reconstruction proceeds **patch-wise** to maintain computational feasibility and robustness.

![Surface geometry and reflection overview](https://github.com/moradisaed/POSSR/blob/main/ProblemFormulation.png)

---

## 📊 Results

We conducted extensive experiments using synthetically generated data. The proposed method is:

- **Robust to noise** in both 2D and 3D reflection point correspondences
- Effective with **a single camera and a single pattern plane**
- Competitive with existing multi-plane methods under ideal conditions

### Qualitative Comparison

![Qualitative reconstruction vs. baseline](https://github.com/moradisaed/POSSR/blob/main/recResults.png)

### Quantitative Evaluation

![Figure 6: Robustness to noise](fig6.png)

---

## 📂 Repository Structure

```bash
├── data/                 # Synthetic datasets
├── src/                  # Main MATLAB source code
├── results/              # Reconstructed surfaces and logs
├── README.md             # This file
```

---

## 📌 Citation

If you find this repository useful in your research, please cite:

```bibtex
@article{moradi2025poss,
  title     = {Patch-Based Optimization for Noise-Robust Reconstruction of Specular Surfaces},
  author    = {Moradi, Saed and Sepanj, M. Hadi and Nazemi, Amir and Preston, Claire and Lee, Anthony M. D. and Fieguth, Paul},
  journal   = {IEEE Access},
  year      = {2025}
}
```

---

## 📬 Contact

For questions, please contact [Saed Moradi](mailto:saed.moradi@uwaterloo.ca).
