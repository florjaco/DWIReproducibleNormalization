#!/bin/sh 

# Call: bash 1_Erode_PadImages.sh <directory>
# This script will erode brilliant voxels on the border of FA images, caused by eddy currents in CSF and pad FA, MD and B0 images for better template creation

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

# Erode FA images

	images=`ls *.nii.gz`
	for im in $images; do
	(
		# erosion with spherical kernel 6mm radius (equivalent to the size of 3 voxels, to erode brilliant voxels on the border of FA images, caused by eddy currents in CSF)
		fslmaths $im -kernel sphere 6 -ero ${im%???????}_ero.nii.gz
		bet ${im%???????}_ero.nii.gz ${im%???????}_ero_brain.nii.gz  -f 6.938893903907228e-17 -g 0 -m # brain extraction in FA and generate brain mask
		
	)done

# Apply erosion mask to MD and B0
	cd ${directory}/${subj}/MD

	images=`ls *.nii.gz`
	for im in $images; do
	(
	# Apply mask generated from bet of erorded FA
	fslmaths $im -mas ${directory}/${subj}/FA/${im%?????????}FA_ero_brain_mask.nii.gz ${im%???????}_ero.nii.gz
	)done

	cd ${directory}/${subj}/B0

	images=`ls *.nii.gz`
	for im in $images; do
	(
	# Apply mask generated from bet of erorded FA
	fslmaths $im -mas ${directory}/${subj}/FA/${im%?????????}FA_ero_brain_mask.nii.gz ${im%???????}_ero.nii.gz
	)done

 # Now pad eroded images
	cd ${directory}/${subj}

DTI="FA \
MD \
B0"

	for k in $DTI; do
	(
	cd ${directory}/${subj}/${k}

	images=`ls *_ero.nii.gz`

	
		for im in $images; do
		(
			# Using ImageMath to add a 10 voxel padding all around the images. 
			#ImageMath is part of ANTS registration suite
		
			#ImageMath <ImageDimension=3> <OutputImage> <operation = PadImage> <InputImage> <PadNumber = 10 voxels>
			ImageMath 3 ${im%???????}_padded.nii.gz PadImage $im 10
		)done
	
	)done
	
)done
