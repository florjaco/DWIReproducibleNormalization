# DWIReproducibleNormalization
Pipeline for reproducible normalization in DWI

## Introduction
This procedure involves the normalization of FA and MD images through a pipeline that minimizes across-session test-retest reproducibility error (Jacobacci et al., 2019).

Normalization of DTI images to MNI152_T1_1mm template is performed using ANTs (antsRegistration command) via an intermediate individual FA template also created using ANTs (antsMultivariateTemplateConstructionTool). 

For this script to work correctly, DWI images must already be pre-processed and the DTI model fitted. FSL and ANTs need to be previously installed and $FSLDIR and $ANTSPATH variables need to be set. These scripts were tested using FSL version 5.0.9 and ANTs version 2.2.0

## File organization
Files must be organized in the following way:
One subjects directory folder, which will contain one folder per subject.
Each subject folder will contain: 
one folder called FA, with all FA images for that subject (multiple sessions)
one folder called MD, with all MD images for that subject (multiple sessions)
one folder called B0, with all B0 images for that subject (multiple sessions)

FA, MD and B0 images need to be in the same space (i.e., coregistered). FA and MD maps are coregistered because they are produced from the DTI model fitting step. However, this is particularly important for the B0 image. If you extract the B0 after eddy correction, the FA and MD images will be aligned to it.

<Subjects_directory>
 |
 |
 |_SUBJECT0001
 |  |
 |  |___>FA: 0001_FA.nii.gz, 0002_FA.nii.gz, etc. (Multiple sessions per subj.)
 |  |
 |  |___>MD: 0001_MD.nii.gz, 0002_MD.nii.gz, etc.
 |  |
 |  |___>B0: 0001_B0.nii.gz, 0002_B0.nii.gz, etc.
 |
 |
 |_SUBJECT0002
 ... etc

NOTE: Scripts are written so that images are read using the format specified here: i.e. Subject folder names maintaining the format SUBJECTXXXX and images inside maintaining the format XXXX_FA.nii.gz, XXXX_MD.nii.gz, XXXX_B0.nii.gz
Script execution
The main script is executed on the terminal via bash with the following input parameters:

<Subjects_directory> is the full path to the folder where subject folders are stored. Inside each subject folder FA, MD and B0 folders are required. These folders will contain the FA, MD and B0 images, respectively, for all the sessions of that subject. 

If your CPU allows for multi-threading you can perform several jobs in parallel. You can check the number of jobs in your CPU by opening the terminal and typing nproc

<n_jobs> is the number of jobs to be used to parallelize template creation (paralellization is automatic)

Example call: 

First, make sure you are on the directory where the scripts are located.

For example, if the scripts are located in /home/mycomputer/path-to-dir/SCRIPTS then type in terminal the following:
cd /home/mycomputer/path-to-dir/SCRIPTS

Once you are placed in the correct directory, set the subjects directory. To do this, type in terminal the following:
Subjects_directory=/home/mycomputer/path-to-dir/SUBJECTS_FOLDER

n_jobs=8

bash 0_MainScript_DTINormalizationtoMNI152T1ViaIndividualFATemplate.sh $Subjects_directory $n_jobs

NOTE: All scripts must be in executable mode. Type in terminal: 
chmod +x <script-name>.sh
Script details
The main script will perform these steps:

Step number
Script name
Description
Input parameters
Input files
Output files
1
1_Erode_PadImages.sh
This script will erode brilliant voxels on the border of FA images, caused by eddy currents in CSF and apply the same erosion to the corresponding MD and B0 images. It will also pad FA, MD and B0 images with 10 voxels all around. 
directory
FA, MD and B0 images

$Subjects_directory/SUBECT0001/FA/0001_FA.nii.gz
$Subjects_directory/SUBECT0001/MD/0001_MD.nii.gz
$Subjects_directory/SUBECT0001/B'0/0001_B0.nii.gz
Eroded and padded FA, MD and B0 images

$Subjects_directory/SUBECT0001/FA/0001_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/MD/0001_MD_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/B0/0001_B0_ero_padded.nii.gz
2
2_Create_Multi-modal_file.sh
This script will create the txt file required to supply it to ANTs-MultivariateTemplateCreation algorithm for the creation of the intermediate template/s
directory
Eroded and padded FA, MD and/or B0 images

$Subjects_directory/SUBECT0001/FA/0001_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/MD/0001_MD_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/B0/0001_B0_ero_padded.nii.gz
One txt file per subject with all the images that will be used for template creation on steps 3 and 4

$Subjects_directory/SUBECT0001/Multi-modal_images.txt 
3
3_CreateInitialFATemplateANTs_MVT.sh
This script will create an initial FA template to be used as seed using antsMultivariateTemplateConstruction tool
directory, n_jobs
All eroded and padded FA images from each subject

$Subjects_directory/SUBECT0001/FA/0001_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/FA/0002_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/FA/0003_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/FA/0004_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/FA/0005_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/FA/0006_FA_ero_padded.nii.gz

etc
One initial FA individual template per subject

$Subjects_directory/SUBECT0001/INIT_FA_MVT_template0.nii.gz

One initial b0 individual template per subject

$Subjects_directory/SUBECT0001/INIT_FA_MVT_template1.nii.gz
4
4_CreateIndividualFATemplateANTs_MVT.sh
This script will create an Individual FA template to be used as seed using antsMultivariateTemplateConstruction tool
directory, n_jobs
All FA images from each subject

$Subjects_directory/SUBECT0001/FA/0001_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/FA/0002_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/FA/0003_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/FA/0004_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/FA/0005_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/FA/0006_FA_ero_padded.nii.gz

etc
One individual FA template per subject

$Subjects_directory/SUBECT0001/SUBJECT0001_FA_template0.nii.gz

One individual b0 template per subject

$Subjects_directory/SUBECT0001/SUBJECT0001_FA_template1.nii.gz
5
5_NormalizeIndividualFATemplates_toT1_MNI152_1mm.sh
This script will perform normalization of FA Templates to MNI152_T1_1mm template using ANTs' antsRegistration command
directory, n_jobs
Individual FA templates from each subject

$Subjects_directory/SUBECT0001/SUBJECT0001_FA_template0.nii.gz
Normalized individual FA template and tranformations

$Subjects_directory/SUBECT0001/MNI152_T1_1mm_brain_fixed_SUBJECT0001_FA_template0_moving_setting_is_forproduction_SUBJECT0001_FA_template0.nii.gz_warped.nii.gz

$Subjects_directory/SUBECT0001/MNI152_T1_1mm_brain_fixed_SUBJECT0001_FA_template0_moving_setting_is_forproduction_inv.nii.gz

$Subjects_directory/SUBECT0001/MNI152_T1_1mm_brain_fixed_SUBJECT0001_FA_template0_moving_setting_is_forproduction1InverseWarp.nii.gz

$Subjects_directory/SUBECT0001/MNI152_T1_1mm_brain_fixed_SUBJECT0001_FA_template0_moving_setting_is_forproduction1Warp.nii.gz

$Subjects_directory/SUBECT0001/MNI152_T1_1mm_brain_fixed_SUBJECT0001_FA_template0_moving_setting_is_forproduction0GenericAffine.nii.gz

6
6_ApplyTransf_FAtoT1_MNI152_1mm.sh
This script applies transformations to take FA and MD images to MNI152_T1_1mm template
directory
Eroded and padded FA and MD images

$Subjects_directory/SUBECT0001/FA/0001_FA_ero_padded.nii.gz
$Subjects_directory/SUBECT0001/MD/0001_MD_ero_padded.nii.gz
FA and MD images warped to MNI152 space

$Subjects_directory/SUBECT0001/FA/0001_FA_warped2MNI152_T1_1mm.nii.gz
$Subjects_directory/SUBECT0001/MD/0001_MD_warped2MNI152_T1_1mm.nii.gz

7
7a_Check_normalizationFAandMD_toMNI152_T1.sh
This script creates gifs for quality control of the normalization.
directory
FA and MD images warped to MNI152 space

$Subjects_directory/SUBECT0001/FA/0001_FA_warped2MNI152_T1_1mm.nii.gz
$Subjects_directory/SUBECT0001/MD/0001_MD_warped2MNI152_T1_1mm.nii.gz
Gif images of normalized FA and MD over MNI152 T1 template

$Subjects_directory/SUBECT0001/0001_FAoverMNI152_T1.gif
$Subjects_directory/SUBECT0001/0001_MDoverMNI152_T1.gif

7b_CheckNormalizationFA_toMNI152_T1_HTML.sh
This script creates an HTML webpage, to be opened in any browser, showing normalization results for FA for quality control.
directory
Gif images of normalized FA and MD over MNI152 T1 template

$Subjects_directory/SUBECT0001/0001_FAoverMNI152_T1.gif
$Subjects_directory/SUBECT0001/0001_MDoverMNI152_T1.gif
It will produce an html web page

$Subjects_directory/check_FAoverMNI152.html 

7c_CheckNormalizationMD_toMNI152_T1_HTML.sh
This script creates an HTML webpage, to be opened in any browser, showing normalization results for MD for quality control.
directory
Gif images of normalized FA and MD over MNI152 T1 template

0001_FAoverMNI152_T1.gif
0001_MDoverMNI152_T1.gif
In the <directory> folder, it will produce an html web page

$Subjects_directory/check_MDoverMNI152.html 

Florencia JACOBACCI 2019
