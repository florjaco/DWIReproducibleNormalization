#!/bin/sh 

# Call: bash 6_ApplyTransf_FAtoT1_MNI152_1mm.sh <directory>

# Applies transformations to take FA and MD images to MNI152_T1_1mm template.

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
n_jobs=$2

cd $directory

MNI152_Template=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz

AP=${ANTSPATH}/ # path to ANTs binaries

dim=3
#####################################################
# FA<-->FA individual Template<-->MNI152 #
#####################################################
# I will concatenate transform that maps each individual FA for each task and session to the individual FA Template for each subject with the trasnformation that takes FA template to MNI152 Template. In this way, I will be able to normalize each individual FA.

for subj in `ls -d SUBJECT*`; do #list of subject folders
(

	cd ${directory}/${subj}

	cd FA
	list=`ls *ero_padded.nii.gz`	
	cd ..

	for i in $list; do
	(
			
		MOVING=${directory}/${subj}/FA/${i:0:4}_FA_ero_padded.nii.gz
		MD_MOVING_withFA=${directory}/${subj}/MD/${i:0:4}_MD_ero_padded.nii.gz
				
		FIXED=$MNI152_Template

echo "------------------------------------------------------------"
echo "Preparing to concatenate all transformations"
echo "------------------------------------------------------------"	
echo " "
		
# order of application of  transformations (order of application is the inverse to how transformations are calculated, same as a pile, first to be calculated is the last to be applied):

	 	#FATemplatetoMNI152_T1_Template1Warp.nii.gz

		transformation1=`ls ${directory}/${subj}/MNI152_T1_1mm_brain_fixed_${subj}_FA_template0_moving_setting_is_forproduction1Warp.nii.gz`

		#FATemplatetoGroup_FATemplate0Affine.mat
		transformation2=`ls ${directory}/${subj}/MNI152_T1_1mm_brain_fixed_${subj}_FA_template0_moving_setting_is_forproduction0GenericAffine.mat`

echo "------------------------------------------------------------"	
echo " "

echo "Transformation 1:" 
echo $transformation1
echo " "
echo "Transformation 2:"
echo $transformation2
echo " "
		#FAtoIndividualFATemplate Warp(antsMultivariateTemplateConstruction.sh transformation)
#		transformation3=`ls ${directory}/${subj}/${subj}_FA_${i:0:4}_FA_ero_padded?Warp.nii.gz`
		transformation3=`ls ${directory}/${subj}/${subj}_FA_${i:0:4}_FA_ero_padded?Warp.nii.gz 2>/dev/null || true`

if [[ ! -e $transformation3 ]]; then 
		#FAtoIndividualFATemplate Warp(antsMultivariateTemplateConstruction.sh transformation)
		transformation3=`ls ${directory}/${subj}/${subj}_FA_${i:0:4}_FA_ero_padded??Warp.nii.gz`
fi

echo "Transformation 3:"
echo $transformation3
echo " "		
		#FAtoIndividualFATemplate Affine(antsMultivariateTemplateConstruction.sh transformation)
		#transformation4=`ls ${directory}/${subj}/${subj}_FA_${i:0:4}_FA_ero_padded?Affine.txt`
		transformation4=`ls ${directory}/${subj}/${subj}_FA_${i:0:4}_FA_ero_padded?Affine.txt 2>/dev/null || true`
if [[ ! -e $transformation4 ]]; then
		#FAtoIndividualFATemplate Affine(antsMultivariateTemplateConstruction.sh transformation)
		transformation4=`ls ${directory}/${subj}/${subj}_FA_${i:0:4}_FA_ero_padded??Affine.txt`
fi

echo "Transformation 4:" 
echo $transformation4
echo " "

		echo "Applying transformations to take ${i:0:4}_MD image to MNI space"
		${AP}antsApplyTransforms -d $dim -i $MD_MOVING_withFA -r $FIXED -n linear -t $transformation1 -t $transformation2 -t $transformation3 -t $transformation4 -o ${directory}/${subj}/MD/${i:0:4}_MD_warped2MNI152_T1_1mm.nii.gz

		echo "Applying transformations to take ${i:0:4}_FA image to MNI space"
		${AP}antsApplyTransforms -d $dim -i $MOVING -r $FIXED -n linear -t $transformation1 -t $transformation2 -t $transformation3 -t $transformation4 -o ${directory}/${subj}/FA/${i:0:4}_FA_warped2MNI152_T1_1mm.nii.gz

		echo "------------------------------------------------------------"	
		echo " "





	)done 
)done
