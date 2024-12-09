# PermXCT: A Novel Framework for Image-Based Virtual Permeability Prediction
The global overview of the PermXCT:
![PermXCT_globalOverview](https://github.com/user-attachments/assets/4ded2a74-4d40-453f-a306-93821d9f74aa)

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
Permeability prediction from XCT scan of the porous composite preform. The workflow starts from the segmentation classification of the XCT fiber class, creation of FE mesh then update to OpenFOAM blockMesh and finally the running simulation of the test and predicted permeability is demonstrated in the flow chart below.

![FLowchart](https://github.com/user-attachments/assets/2ef80d7f-1fdd-4a1e-8d08-5a70a836fa4c)

The XCT dataset is presented in the https://zenodo.org/uploads/14228043 link.
