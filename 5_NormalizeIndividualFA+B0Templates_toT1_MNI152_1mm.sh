#!/bin/sh 

# Call: bash 5_NormalizeIndividualFA+B0Templates_toT1_MNI152_1mm.sh <directory> <n_jobs>

# Normalization of FA+B0 Templates to MNI152_T1_1mm template. FA and MD are automatically coregistered because they are calculated at the same time.
# Script based on parameters found on https://github.com/ANTsX/ANTs/blob/master/Scripts/newAntsExample.sh

# Parameters: 
#<directory> is the full path to the folder where FA, MD and B0 images are be stored, all in a SUBJECT folder. Inside the FA and B0 folders we will have the FA and B0 FA-driven individual templates created previously. We will normalize these templates to MNI152 template

# <n_jobs>: number of jobs to be used to parallelize template creation (automatic)

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

for subj in `ls -d SUBJECT*`; do #list of subject folders
(

	cd ${directory}/${subj}

	echo "Normalizing ${subj}_FA_template0 (FA template) + ${subj}_FA_template1 (B0 template)  to MNI152_T1_1mm_brain"
	echo `date`		

		MOVING_FA=${subj}_FA_template0.nii.gz #FA is the Moving image
		B0=${subj}_FA_template1.nii.gz #B0 image

		FIXED=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz # Fixed image: MNI152	

		dim=3 # image dimensionality
		AP=${ANTSPATH}/ # path to ANTs binaries
		ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$n_jobs # controls multi-threading
		export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
		#f=$1 ; m=$2    # fixed and moving image file names
		f=$FIXED ; m=$MOVING_FA    # fixed and moving image file names		
		
		#mysetting=$3 # use this to input parameter setting
		#mysetting="fastfortesting" # use this to select "fastfortesting" parameter setting (fewer iterations), useful to check if script works and fast creation of templates for a first 			approximation to template creation
		
		mysetting="forproduction" # use this to select "forproduction" parameter setting		 

		if [[ ! -s $f ]] ; then echo no fixed $f ; exit; fi
		if [[ ! -s $m ]] ; then echo no moving $m ;exit; fi
		if [[ ${#mysetting} -eq 0 ]] ; then
		echo usage is
		echo $0 fixed.nii.gz moving.nii.gz mysetting
		echo  where mysetting is either forproduction or fastfortesting
		exit
		fi

		nm1=` basename $f | cut -d '.' -f 1 `

		nm2=` basename $m | cut -d '.' -f 1 `
		
		reg=${AP}antsRegistration           # path to antsRegistration

		if [[ $mysetting == "fastfortesting" ]] ; then
			its=10000x0x0
  			percentage=0.1
  			syn="100x0x0,0,5"
		else
 		 	its=10000x111110x11110
  			percentage=0.3
  			syn="100x100x50,-0.01,5"
  			mysetting=forproduction
		fi

# 1) Rigid transformation of template to MNI space

# 2) Affine transformation of template to MNI space

# 3) nonlinear (using greedy SyN) transformation of template to MNI space


nm=${nm1}_fixed_${nm2}_moving_setting_is_${mysetting}   # construct output prefix
echo affine $m $f outname is $nm am using setting $mysetting

$reg --dimensionality $dim --float 0 --verbose 1 \
			--winsorize-image-intensities [0.005,0.995] \
			--initial-moving-transform [ $f, $B0 ,1] \
                        --metric mattes[  $f, $B0 , 1 , 32, regular, $percentage ] \
                        --transform translation[ 0.1 ] \
                        --convergence [$its,1.e-6,20]  \
                        --smoothing-sigmas 4x2x1  \
                        --shrink-factors 6x4x2 --use-estimate-learning-rate-once 1 \
                        --metric mattes[  $f, $B0 , 1 , 32, regular, $percentage ] \
                        --transform rigid[ 0.1 ] \
                        --convergence [$its,1.e-6,20]  \
                        --smoothing-sigmas 4x2x1  \
                        --shrink-factors 3x2x1 --use-estimate-learning-rate-once 1 \
                        --metric mattes[  $f, $B0 , 1 , 32, regular, $percentage ] \
                        --transform affine[ 0.1 ] \
                        --convergence [$its,1.e-6,20]  \
                        --smoothing-sigmas 4x2x1  \
                        --shrink-factors 3x2x1 --use-estimate-learning-rate-once 1 \
			--metric mattes[  $f, $B0 , 1 , 32, regular, $percentage ] \
			--metric mattes[  $f, $m , 1 , 32, regular, $percentage ] \
                        --transform SyN[ .20, 3, 0 ] \
                        --convergence [$syn]  \
                        --smoothing-sigmas 1x0.5x0  \
                        --shrink-factors 3x2x1 --use-estimate-learning-rate-once 1 \
			--use-histogram-matching 0 \
			--collapse-output-transforms 1 \
                        --output [${nm},${nm}_B0_warped.nii.gz,${nm}_inv.nii.gz]

echo "---------------------------------------------------------------------"

)
done
