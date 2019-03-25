#!/bin/sh 

# Call: bash 4_CreateIndividualFATemplateANTs_MVTs.sh <directory> <n_jobs>
# Individual template creation using antsMultivariateTemplateConstruction tool

#http://biabl.github.io/tutorials/structural/template/
#https://sourceforge.net/p/advants/discussion/840261/thread/632cee1e/?limit=25

# Parameters: 
#<directory> is the full path to the folder where FA, MD and B0 images will be stored. FA images that will be used as input for template creation should be in a named FA in <directory>, MD images in a folder called MD and B0, in a folder named B0, all in a SUBJECT folder 
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

echo "Creating Initial Template using ANTs antsMultivariateTemplateConstruction.sh with 1 iteration of affine registration" 
echo `date`


for subj in `ls -d SUBJECT*`; do #list of subject folders
(

	cd ${directory}/${subj}

# AntsMVTC parameters:
# Affine Rigid transformation
# Cross correlation similarity metric
# use n_jobs
# don't do bias correction on the images
# GR greedy Type of transformation model used for registration
# SY = SyN with time (default) with arbitrary number of time points in time discretization
# Modality weights used in the similarity metric (w) is set to produce an FA-driven template and an accompanying B0 template, according to the order of the Multi-modal_images.txt file
# use initial templates as seeds: INIT_FA_MVT_template0.nii.gz as seeds (FA template) and INIT_FA_MVT_template1.nii.gz (B0 template)

echo "Creating Individual Template for subject $subj" 
echo `date`

     antsMultivariateTemplateConstruction.sh -d 3 \
			     	             -i 4 \
  					     -g 0.2 \
					     -c 2 -j $n_jobs \
  					     -k 2 \
                                             -w 1x0 \
					     -m 30x50x20 \
                                             -n 0 \
                                             -s CC \
                                             -t GR \
	                            	     -o ${subj}_FA_ \
		             		     -z INIT_FA_MVT_template0.nii.gz \
                 			     -z INIT_FA_MVT_template1.nii.gz \
                                             ${directory}/${subj}/Multi-modal_images.txt
    
echo "Individual Template created for subject $subj"
echo "-------------------------------------------"
echo " "

)
done

