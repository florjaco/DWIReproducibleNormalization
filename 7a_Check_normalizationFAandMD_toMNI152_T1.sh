#!/bin/sh 

# Create gifs for quality control of normalization.

# Parameters: 
#<directory> is the full path to the folder where FA, MD and B0 images are be stored, all in a SUBJECT folder. Inside the FA and B0 folders we will have the FA and B0 FA-driven individual templates created previously. We will normalize these templates to MNI152 template

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

	cd ${directory}/${subj}
	
	cd FA

	list=`ls *ero_padded.nii.gz`	

	cd ..

	for i in $list; do
	(

slices MD/${i:0:4}_MD_warped2MNI152_T1_1mm.nii.gz ${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz -o ${i:0:4}_MDoverMNI152_T1.gif

slices FA/${i:0:4}_FA_warped2MNI152_T1_1mm.nii.gz ${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz -o ${i:0:4}_FAoverMNI152_T1.gif

)
done
)
done

