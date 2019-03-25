#!/bin/sh 

# Main Script
# Normalization of DTI images to MNI152_T1_1mm template via an intermediate individual FA template. 

# Input Parameters: 
#<directory> is the full path to the folder where FA, MD and B0 images are be stored, all in a SUBJECT folder. Inside the FA and B0 folders we will have the FA and B0 FA-driven individual templates created previously. We will normalize these templates to MNI152 template

# <n_jobs>: number of jobs to be used to parallelize template creation (paralellization is automatic)


# For this script to work correctly, DWI images must be pre-processed and the DTI model fitted

# Files must be organized in the following way:
# One main directory folder, with one folder per subject.
# Inside each subject folder: one folder called FA, with all FA images for that subject (multiple sessions)
#			      one folder called MD, with all MD images for that subject (multiple sessions)
#			      one folder called B0, with all B0 images for that subject (multiple sessions)
# FA, MD and B0 images need to be in the same space (i.e., coregistered). FA and MD maps are coregistered because they are produced from the DTI model fitting step. However, it is particularly important for the B0 image.

#<directory>
#  |
#  |
#  |_SUBJECT0001
#  |  |
#  |  |___>FA: 0001_FA.nii.gz, 0002_FA.nii.gz, etc. (Multiple sessions per subject)
#  |  |
#  |  |___>MD: 0001_MD.nii.gz, 0002_MD.nii.gz, etc.
#  |  |
#  |  |___>B0: 0001_B0.nii.gz, 0002_B0.nii.gz, etc.
#  |
#  |
#  |_SUBJECT0002
# ... etc

# Florencia JACOBACCI 2019

directory=$1
n_jobs=$2

bash 1_Erode_PadImages.sh $directory

bash 2_Create_Multi-modal_file.sh $directory

bash 3_CreateInitialFATemplateANTs_MVT.sh $directory $n_jobs

bash 4_CreateIndividualFATemplateANTs_MVT.sh $directory $n_jobs

bash 5_NormalizeIndividualFATemplates_toT1_MNI152_1mm.sh $directory $n_jobs

bash 6_ApplyTransf_FAtoT1_MNI152_1mm.sh $directory

bash 7a_Check_normalizationFAandMD_toMNI152_T1.sh $directory

bash 7b_CheckNormalizationFA_toMNI152_T1_HTML.sh $directory

bash 7c_CheckNormalizationMD_toMNI152_T1_HTML.sh $directory
