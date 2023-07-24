#!/bin/bash -l

#$ -P llamagrp       # Specify the SCC project name you want to use
#$ -l h_rt=12:00:00   # Specify the hard time limit for the job
#$ -N arceditnedit           # Give job a name
#$ -j y               # Merge the error and output streams into a single file
#$ -m a             # Send email when job begins, ends and aborts
#$ -pe omp 4          # Specify the parallel environment and the number of cores
#$ -l gpus=1           # Request GPU
#$ -l gpu_memory=48G  # Request 48GB of GPU memory per GPU
#$ -l gpu_c=6.0		# Request GPU compute capability
#$ -t 1-2

source /projectnb/llamagrp/feyzanb/anaconda3/etc/profile.d/conda.sh
conda activate dune

cnt=0
for MODELNAME in xl xxl; do
    for EDIT in "no_edit"; do
        (( cnt++ ))
        if [[ $cnt -eq $SGE_TASK_ID ]]; then
            OUTDIR="/projectnb/llamagrp/feyzanb/dune/outputs/ARC_locality/${EDIT}_flan-t5-${MODELNAME}"
            CACHE="/projectnb/llamagrp/feyzanb/dune/cache/ARC"
            mkdir -p $OUTDIR
            mkdir -p $CACHE
            python eval.py \
            --model_name google/flan-t5-$MODELNAME \
            --dataset_name ARC \
            --output_dir $OUTDIR \
            --generations_cache $CACHE/flan-t5-${MODELNAME}.json \
            --filename_queries "/projectnb/llamagrp/feyzanb/dune/source/arc/arc_locality_processed.json" \
            --$EDIT > ${OUTDIR}/log${edit}.txt 2>&1
        fi
    done
done

# "/projectnb/llamagrp/feyzanb/dune/source/arc/chat_prompt_dict.json"

# EDIT="with_edit"
# MODELNAME="small"
# OUTDIR="/projectnb/llamagrp/feyzanb/dune/outputs/ARC/${EDIT}_flan-t5-${MODELNAME}"
# CACHE="/projectnb/llamagrp/feyzanb/dune/cache/ARC"
# mkdir -p $OUTDIR
# mkdir -p $CACHE
# python eval.py \
# --model_name google/flan-t5-$MODELNAME \
# --dataset_name ARC \
# --output_dir $OUTDIR \
# --generations_cache $CACHE/flan-t5-${MODELNAME}.json \
# --filename_queries "/projectnb/llamagrp/feyzanb/dune/source/arc/arc_processed.json" \
# --$EDIT