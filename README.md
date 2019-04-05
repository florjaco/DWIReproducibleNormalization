# DWIReproducibleNormalization
Pipeline for reproducible normalization in DWI

This procedure involves the normalization of FA and MD images through a pipeline that minimizes across-session test-retest reproducibility error (Jacobacci et al., 2019 see https://www.biorxiv.org/content/10.1101/590521v1).


Normalization of DTI images to MNI152_T1_1mm template is performed using ANTs (antsRegistration command) via an intermediate individual FA template also created using ANTs (antsMultivariateTemplateConstructionTool). 

For this script to work correctly, DWI images must already be pre-processed and the DTI model fitted. FSL and ANTs need to be previously installed and $FSLDIR and $ANTSPATH variables need to be set. These scripts were tested using FSL version 5.0.9 and ANTs version 2.2.0

For more information, on how to run scripts, check for README_v2.docx file
