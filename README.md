# PermXCT: A Novel Framework for Image-Based Virtual Permeability Prediction
The global overview of PermXCT:
![GlobalOverview](https://github.com/user-attachments/assets/df0cee59-f1c1-4596-9732-179163fc0eba)

## Acknowledgement
The work of Debabrata Adhikari and Jesper Henri Hattel has received funding from Horizon Europe, the European Union’s Framework Programme for Research, and Innovation, under Grant Agreement No. 101058054 (TURBO) https://turboproject.eu/. The work of Jesper Lisegaard and Sankhya Mohanty has been supported by the Energy Technology Development and Demonstration Programme: Automated Lay-up processes in blade Manufacturing (ALMA) project (Grant No. 640222-495998).

<img src="https://github.com/user-attachments/assets/d46062e3-6250-49d9-b62e-41350cc712e3" width="300" height="150" />

## How to cite PermXCT?
You can cite the paper: 
```
## Software development:
Debabrata Adhikari, Jesper J. Lisegaard, Jesper H. Hattel, and Sankhya Mohanty (2025). "PermXCT: A Novel Framework for Image-Based Virtual Permeability Prediction". SoftwareX (submitted for publication)
## Research interest and application:
1.Debabrata Adhikari, Jesper J. Lisegaard, Robert S. Pierce, Lars Pilgaard Mikkelsen, Jesper H. Hattel, and Sankhya Mohanty. "Meso-scale permeability prediction from the multi-block 3D reconstruction of fiber reinforced polymer composite with experimental measurement". Composite Science and Technology (submitted for publication)
2.Debabrata Adhikari, Jesper J. Lisegaard, Jesper H. Hattel, and Sankhya Mohanty. "An efficient approach for mesoscale virtual permeability predictions using realistic fiber geometry extracted via micro-ray computed tomography." In 21st European Conference on Composite Materials, pp. 467-474. 2024.
```
# Overview
PermXCT is a framework for virtual permeability prediction in fiber-reinforced polymer (FRP) composites using X-ray computed tomography (XCT). It automates geometry extraction, finite element (FE) mesh generation, flow simulation, and permeability prediction while integrating mesoscale and microscale features, such as intra- and inter-yarn porosity and fiber orientation, for large-domain XCT scans. Utilizing open-source tools like DREAM3D, OpenFOAM, Python, and MATLAB, PermXCT ensures computational efficiency through domain-size reduction and mesh optimization. This platform overcomes respectabilities in experimental measurements and has significant applications in predicting virtual permeability during infusion and potential used in the structural performance prediction simulation of post-cured FRP composites. The flow chart of the workflow is shown below.

![FLowchart](https://github.com/user-attachments/assets/2ef80d7f-1fdd-4a1e-8d08-5a70a836fa4c)

1. `Pyhton notebook`: Extract the data from the XCT scan and perform structure tensor analysis
2. `DREAM3D`: Create the finite element mesh (FE) from the segmented scan of fiber and matrix
3. `MATLAB`: Transform the FE mesh to blockMesh and required file of porosityPorpertis, interfaces and boundary condition for OpenFOAM
4. `OpenFOAM`: Create and perform flow simulations for three principal permeability
5. `Shell script`: Automate the process from DREAM3D until the prediction of permeability

The XCT dataset is presented in the https://zenodo.org/uploads/14228043 link. Users can use any type of XCT data format ready by Python libraries and perform the same for the prediction of virtual permeability.

# Preparation Phase
## Download PermXCT repository
1. Clone OR download the **PermXCT** repository to your local directory - click the green "Code" button on the **PermXCT** main page and choose "Download ZIP". 
Then save the `PermXCT` project in your working folder/home directory (e.g., the path to the `PermXCT` project could be: `/yourpath/home/PermXCT_Master`). 

2. Download the XCT_dataset and DREAM3D file from the Zenodo link.
3. Copy the `dream3D_pipeline` folder and the XCT data file `JCB-11-14-19_LFOV-B2-10s-LE3-60kV-10w_recon.txm` from the Zenodo repository to ´PermXCT/XCT_preProcess´ folder. 

>[!NOTE]
>Remember to update the folder directory name in both the `runstepsx.sh` to execute the rest of the code. Update the python notebook file `UD_TURB0_CST2025.ipynb` in XCT_dataset to locate XCT data file.
>Update file name path in `MATLAB` file `mainblockMeshDict_UD_from_XCT_parallel.m` in `/yourpath/home/Permeability/CodeBlockMeshMatlab`

## Install dependencies
1. `Install Python libraries`: Use pip install in the designated Anaconda environment. See the requirement.txt file.
2. `Install DREAM3D`: Unzip the dream3D_pipeline.zip from the Zenodo link and install it in the WSL Linux environment
3. `Install OpenFOAM`: Download OpenFOAM V2212 from "https://www.openfoam.com/news/main-news/openfoam-v2212"

# Run a Case in PermXCT
## Using VScode to Run Segmentation of XCT DATA
Install Visual Studio Code: Download [VScode](https://code.visualstudio.com/) and [install](https://code.visualstudio.com/docs/setup/setup-overview) it. A short video tutorial on how to install VScode and add Julia to it can be found [here](https://www.youtube.com/watch?v=oi5dZxPGNlk).

1. Open the VScode, click the 'File' tab, select 'Open Folder...', and navigate to your home working directory:`/yourpath/home/PermXCT/XCT_preProcess` where the XCT data is located. 
![OpenCondaEnvironment](https://github.com/user-attachments/assets/c17ec8e1-18b5-4190-87f6-fe08b8a8cffe)

2. Update the file path name `path_wd` (for Windows `"C:/Users/yourpath/home/Permeability"`) and `path_unix` (for Linux WSL `"/mnt/c/yourpath/PermXCT/Permeability"`) to generate the file path of each slice for permeability prediction. Then run the notebook `UD_TURB0_CST2025.ipynb` in VS code within the dedicated environment where you have installed all the dependencies.
![WSLPath](https://github.com/user-attachments/assets/3a9cd483-621e-420d-a17b-f01f1933df9f)

3. At the end of execution, the VS-code window looks like this.
![EndOfXCT_segmentation](https://github.com/user-attachments/assets/eeeeb7ca-c3db-4a28-b0d1-ae5c3f24f447)

 ## Using the shell script to perform automated permeability prediction
 1. Open a cmd prompt terminal in WSL-Linux and navigate to `PermXCT/Permeability` folder. Make sure the DREAM3D and OpenFOAM are available in the terminal window. Run `icoFOAM` to see if this is available and OpenFOAM is ready to use.
 ![selectWSL_terminal](https://github.com/user-attachments/assets/20971f3c-f515-4c91-b4fb-a5c65a884e5a)
 
 2. Look at the XCT data set of slices in the `Permeability` folder which VSCode creates.
 ![FolderDirectoryPerm](https://github.com/user-attachments/assets/6b5ca0d3-e76b-4842-9302-7dec966b0d52)

 3. Update ´dir´, `thresholdWD` and update the filed of Vf, NX, NY, NZ and SKIP accordingly from the VSCode.
![ShellDirectory](https://github.com/user-attachments/assets/e45d9d94-1793-439b-bd52-c291e2cc015b)

 4. Update the Matlab file path in the shell script `runstepsx.sh
![{D612AABE-0D8A-4065-B65D-7A16C786F89B}](https://github.com/user-attachments/assets/de957fe5-e3d0-4a19-968a-41f994181986)

and in the DIR name in `/mnt/c/yourpath/PermXCT/Permeability/CodeBlockMeshMatlab/mainblockMeshDict_UD_from_XCT_parallel.m` file as follows:
![{19DDC094-4F11-4624-9CEC-3AD1C6B9793A}](https://github.com/user-attachments/assets/1d3995fd-2ee1-4797-8594-f6078435bacd)

6. Then execute the `runstepsx.sh` script.
Wile running it looks like these
![{D92AB542-0DDB-42B1-9FAE-9ED1E14B3E43}](https://github.com/user-attachments/assets/22828673-bf74-4194-bf59-d19f301d4cf7)



# Documentation
Check PermXCT (SoftwareX) paper for the functionality of individual code and details of the test cases for scientific development and research interest in the "Meso-scale permeability prediction from the multi-block 3D reconstruction of fiber reinforced polymer composite with experimental measurement" Composite Science and Technology paper.
