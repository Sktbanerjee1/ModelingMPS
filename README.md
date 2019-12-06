# ModelingMPS
code use for modeling data from Microfluidics Perturbation Screenings (MPS)

Code and data to derive patient specific logic models as described in https://www.biorxiv.org/content/10.1101/422998v1

Input data for the model optimization are:

- data/PKN_curated.sif prior knowledge network of intrinsic and extrinsic apoptosis pathway
- data/MIDAS_files csv files in MIDAS format with the MPS perturbation data formatted as required by CellNOptR

Model optimization can be run using CNORode2017 (https://github.com/saezlab/CNORode2017) with the script analysis/optimisation_bootstrap.R. With optimisation_bootstrap.sh the optimization can be run multiple times on the cluster. Bootstrap is used to derive a distribution of the model parameters as described in the manuscipt. To run the optimization without bootstrap just set paramsSSm$bootstrap=F.




