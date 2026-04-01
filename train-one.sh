#!/bin/bash -x
#SBATCH -N 1
#SBATCH --ntasks-per-node=1          # Only 1 task (you launch manually)
#SBATCH --gres=gpu:2
#SBATCH --cpus-per-task=8
#SBATCH -p gpu
#SBATCH -J multilingual-en-xx-en
#SBATCH -t 2-00:00:00
#SBATCH -o logs/%x-%j.out
#SBATCH -e logs/%x-%j.err
#SBATCH --mem=160000

############################
# Environment Setup
############################
module purge
module load miniconda

source ~/.bashrc
conda activate open-nmt

############################
# Sanity Checks
############################
echo "Running on node: $(hostname)"
echo "CUDA devices: $CUDA_VISIBLE_DEVICES"

nvidia-smi

############################
# Manual Training (Single-node, multi-GPU)
############################
# Explicitly control GPUs
export CUDA_VISIBLE_DEVICES=0,1

# Optional: debugging
export NCCL_DEBUG=INFO

# Run training manually
onmt_train -config yamls/train.multilingual.en-xx-en.yaml

############################
# Cleanup
############################
conda deactivate