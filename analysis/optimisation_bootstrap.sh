#!/bin/bash
echo 'optimisation apoptosis models with bootstrap'

output_dir=./output/o_bootstrap/

for cellLineFile in $(ls ./MIDAS_files);
do 
for indexRep in $(seq 1 500);
do
	bsub -q research-rh7 -M 16384 -R "rusage[mem=16384]" -o $output_dir/output_${cellLineFile}_${indexRep}.txt -e $output_dir/error_${cellLineFile}_${indexRep}.txt optimisation_bootstrap.R $cellLineFile $indexRep
	echo "the cell line is $cellLineFile"
	echo "repetition $indexRep"
done
done
