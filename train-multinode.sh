#!/bin/bash
#SBATCH -N 2                          # 2 nodes
#SBATCH --ntasks-per-node=2           # 2 processes per node (1 per GPU)
#SBATCH --gres=gpu:2                  # 2 GPUs per node
#SBATCH --cpus-per-task=8
#SBATCH --mem=0
#SBATCH -J mn-l40-multilingual-indicMT
#SBATCH --error=logs/l40.multinode.%J.err
#SBATCH --output=logs/l40.multinode.%J.out
#SBATCH --time=2-00:00:00
#SBATCH --partition=l40
#SBATCH --qos=l40
# ##SBATCH --test-only

# ---- Environment ----
source /lustre-flash/apps/spack/share/spack/setup-env.sh
spack load miniconda3
source ~/.bashrc
conda activate onmt3.0

# ---- Distributed Setup ----
export MASTER_ADDR=$(scontrol show hostnames $SLURM_JOB_NODELIST | head -n 1)
export MASTER_PORT=29500

export WORLD_SIZE=$(($SLURM_NNODES * $SLURM_NTASKS_PER_NODE))

echo "MASTER_ADDR=$MASTER_ADDR"
echo "WORLD_SIZE=$WORLD_SIZE"


echo "RANK=$SLURM_PROCID LOCAL_RANK=$SLURM_LOCALID WORLD_SIZE=$WORLD_SIZE"

# ---- Launch ----
srun onmt_train -config yamls/l40.multinode.train.multilingual.en-xx-en.yaml
