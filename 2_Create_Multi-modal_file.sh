#!/bin/sh 

# Call: bash 2_Create_Multi-modal_file.sh <directory>

#This script will create the txt file required to supply it to ANTs-MultivariateTemplateCreation algorithm for the creation of two templates: an FA template (created by driving template creation using FA images) and a B0 template (created by applying the transformations to B0, to have an accompanying B0 template). This could be done with MD as well, by adding MD images to the txt file.

# Parameters: <directory> is the full path to the folder where FA, MD and B0 images will be stored. FA images should be in a named FA in <directory>, MD images in a folder called MD and B0, in a folder named B0, all in a SUBJECT folder 

#<directory>
#  |
#  |
#  |_SUBJECT0001
#     |
#     |___>FA: 0001_FA.nii.gz, 0002_FA.nii.gz, etc. (Multiple sessions per subject)
#     |
#     |___>MD: 0001_MD.nii.gz, 0002_MD.nii.gz, etc.
#     |
#     |___>B0: 0001_B0.nii.gz, 0002_B0.nii.gz, etc.


directory=$1

cd $directory

for subj in `ls -d SUBJECT*`; do #list of subject folders
(

	cd ${directory}/${subj}/FA

	list=`ls *ero_padded.nii.gz`	

	for i in $list; do
	(
		echo "${directory}/${subj}/FA/${i} , ${directory}/${subj}/B0/${i:0:4}_B0_ero_padded.nii.gz ">> ${directory}/${subj}/Multi-modal_images.txt #one file per subject

	)
	done

)done
