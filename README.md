# PermXCT: A Novel Framework for Image-Based Virtual Permeability Prediction
The global overview of PermXCT:
![GlobalOverview](https://github.com/user-attachments/assets/df0cee59-f1c1-4596-9732-179163fc0eba)

## Acknowledgement
The work of Debabrata Adhikari, Jesper Henri Hattel has received funding from Horizon Europe, the European Union’s Framework Programme for Research, and Innovation, under Grant Agreement No. 101058054 (TURBO) https://turboproject.eu/. The work of Jesper Lisegaard and Sankhya Mohanty has been supported by the Energy Technology Development and Demonstration Programme: Automated Lay-up processes in blade Manufacturing (ALMA) project (Grant No. 640222-495998).

<img src="https://github.com/user-attachments/assets/d46062e3-6250-49d9-b62e-41350cc712e3" width="300" height="150" />

## How to cite PermXCT?
You can cite the paper: 
```
Debabrata Adhikari, Jesper J. Lisegaard, Jesper H. Hattel, and Sankhya Mohanty. "An efficient approach for mesoscale virtual permeability predictions using realistic fiber geometry extracted via micro-ray computed tomography." In 21st European Conference on Composite Materials, pp. 467-474. 2024.
Debabrata Adhikari, Jesper J. Lisegaard, Jesper H. Hattel, and Sankhya Mohanty (2025). "PermXCT: A Novel Framework for Image-Based Virtual Permeability Prediction". SoftwareX (submitted for publication)
Debabrata Adhikari, Jesper J. Lisegaard, Robert S. Pierce, Lars Pilgaard Mikkelsen, Jesper H. Hattel, and Sankhya Mohanty. "Meso-scale permeability prediction from the multi-block 3D reconstruction of fiber reinforced polymer composite with experimental measurement". Composite Science and Technology (submitted for publication)
```
# Overview
PermXCT is a framework for virtual permeability prediction in fiber-reinforced polymer (FRP) composites using X-ray computed tomography (XCT). It automates geometry extraction, finite element (FE) mesh generation, flow simulation, and permeability prediction while integrating mesoscale and microscale features, such as intra- and inter-yarn porosity and fiber orientation, for large-domain XCT scans. Utilizing open-source tools like DREAM3D, OpenFOAM, Python, and MATLAB, PermXCT ensures computational efficiency through domain-size reduction and mesh optimization. This platform overcomes respectabilities in experimental measurements and has significant applications in predicting virtual permeability during infusion and potential used in the structural performance prediction simulation of post-cured FRP composites. The flow chart of the workflow is shown below.
1. `Pyhton notebook`: Extract the data from XCT scan and perform structure tensor analysis
2. `DREAM3D`: Create the finite element mesh (FE) from the segmented scan of fiber and matrix
3. `MATLAB`: Transform the FE mesh to blockMesh and required file of porosityPorpertis, interfaces and boundary condition for OpenFOAM
4. `OpenFOAM`: Create and perform flow simulations for three principal permeability
5. `Shell script`: Automate the process from DREAM3D until the prediction of permeability

![FLowchart](https://github.com/user-attachments/assets/2ef80d7f-1fdd-4a1e-8d08-5a70a836fa4c)

The XCT dataset is presented in the https://zenodo.org/uploads/14228043 link.
