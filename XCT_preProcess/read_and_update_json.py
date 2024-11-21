
import numpy
import json

def read_and_update_json_dream3d(jsonPath, json_Write_wd, dimns, origin, spacing, Fdst, sln, slz, ABQ_dest):
    
    # open dream3d main file and update accoding to each slices
    # mainJsPath = jsonPath + '/dream3D_pipeline/' + 'dream3d_slices_NCF_XCT.json'

    # print(mainJsPath)

    with open(jsonPath + '/dream3D_pipeline/dream3d_slices_NCF_XCT.json', 'r') as file:

        # read
        dataXC = json.load(file)

        # print(dataXC)

        # Replace field variables 

        # Dimensions of sclices
        dataXC["1"]["Dimensions"]["x"] = int(dimns[0])
        dataXC["1"]["Dimensions"]["y"] = int(dimns[1])
        dataXC["1"]["Dimensions"]["z"] = int(dimns[2])

        # Replace the new co-ordinate origin depends on slice location
        dataXC["1"]["Origin"]["x"] = int(origin[0])
        dataXC["1"]["Origin"]["y"] = int(origin[1])
        dataXC["1"]["Origin"]["z"] = int(origin[2])

        # Replace the spacing between voxel elements
        dataXC["1"]["Spacing"]["x"] = int(spacing[0])
        dataXC["1"]["Spacing"]["y"] = int(spacing[1])
        dataXC["1"]["Spacing"]["z"] = int(spacing[2])

        # Update input file location of each slices
        dataXC["2"]["Wizard_InputFilePath"] = Fdst
        dataXC["2"]["Wizard_NumberOfLines"] = int(dimns[0]*dimns[1]*dimns[2])
        dataXC["2"]["Wizard_TupleDims"] = [
                int(dimns[0]),
                int(dimns[1]),
                int(dimns[2])
                ]

        # Update the class type of each slices
        dataXC["3"]["ScalarArrayPath"]["Data Array Name"] = "angle_class"

        # Update the output file location of dream3D process
        dataXC["4"]["OutputFile"] = str(ABQ_dest) + "/slice_"+str(sln)+"Z"+str(slz+1)+".dream3d"

        # Update the ABAQUS voxel mesh file name and output folder location
        dataXC["5"]["FilePrefix"] = "slice_"+str(sln)+"Z"+str(slz+1)
        dataXC["5"]["OutputPath"] = str(ABQ_dest)

        # Update the output file location for ascii file containing the grain id and features id of each angle calss
        dataXC["6"]["OutputFilePath"] = str(ABQ_dest) + "/ascii_slice"+str(sln)+"Z"+str(slz+1)+".txt"
        dataXC["6"]["OutputPath"] = str(ABQ_dest)

        # # Pipeline flie name for dream3d 
        dataXC["PipelineBuilder"]["Name"] = "dream3d_slices_NCF_XCT"

        newData = json.dumps(dataXC, indent=4)

        # Update the json file into new for each slices
        updateName = str(json_Write_wd) + '/dream3d_slices_NCF_XCT_updated_slice'+str(sln)+"Z"+str(slz+1)+'.json'

        with open(updateName, 'w+') as file:
            # write
            file.write(newData)