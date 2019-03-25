#!/bin/sh 

# Call: bash 3_CreateInitialFATemplateANTs_MVTs.sh <directory> <n_jobs>

# Initial template creation using antsMultivariateTemplateConstruction tool
# ATENTION! Use AntsMVTC (Multivariate template creation) instead of buildtemplateparallel.sh (BTP.sh) for template creation. AntsMVTC replaced BTP and BTP is no longer maintained

#https://github.com/ANTsX/ANTs/issues/291
#https://sourceforge.net/p/advants/discussion/840261/thread/d459895d/

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
# Modality weights used in the similarity metric (w) is set to produce an FA-driven template and an accompanying B0 template, according to the order of the Multi-modal_images.txt file

echo "Creating Initial Template for subject $subj" 
echo `date`

    antsMultivariateTemplateConstruction.sh -d 3 \
			     	             -i 4 \
  					     -g 0.2 \
					     -c 2 -j $n_jobs \
  					     -k 2 \
                                             -w 1x0 \
					     -m 1x0x0x0 \
                                             -n 0 \
                                             -r 1 \
                                             -s CC \
                                             -t GR \
                                             -o INIT_FA_MVT_ \
                                             ${directory}/${subj}/Multi-modal_images.txt

echo "Initial Template created for subject $subj"
echo "-------------------------------------------"
echo " "
    
)
done

