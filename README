# SLURM Instructions

---

## Table of Contents

1. [GPU Partition](#1-gpu-partition)
2. [How to Get Partitions](#2-how-to-get-partitions)
3. [Partition & Cluster Information](#3-partition--cluster-information)
4. [Job Submission & Testing](#4-job-submission--testing)
5. [Resources](#5-resources)
6. [Job Monitoring & Queue Utilities](#6-job-monitoring--queue-utilities)
7. [Viewing & Modifying Job Details](#7-viewing--modifying-job-details)
8. [Checking GPU Usage](#8-checking-gpu-usage)
9. [Opening a Shell Inside a Worker Node](#9-opening-a-shell-inside-a-worker-node)
10. [Cancel / Modify Jobs](#10-cancel--modify-jobs)
11. [Debugging & Logs](#11-debugging--logs)
12. [Useful Tips & Common Pitfalls](#12-useful-tips--common-pitfalls)
13. [Training](#13-training)

---

## 1. GPU Partition

The GPU partition includes nodes equipped with **NVIDIA A100 GPUs**. Jobs submitted to this partition will run on nodes that can leverage the high-performance computing capabilities of A100 GPU cards for parallel processing tasks.

The GPU partition **exclusively contains GPU nodes**. If a user wishes to submit a job only on GPU nodes, they must specify both the partition name **and** the number of GPU cards required.

---

## 2. How to Get Partitions

List all available partitions:
```bash
sinfo
```

Show only partition names:
```bash
sinfo -h -o "%P"
```

Detailed view (state, nodes, time limits):
```bash
sinfo -o "%P %a %l %D %t %N"
```

Show specific partition info:
```bash
scontrol show partition <partition_name>
```

---

## 3. Partition & Cluster Information

View all partitions and their status:
```bash
sinfo
```

Detailed partition information (nodes, GPUs, time limits):
```bash
sinfo -o "%P %N %G %l %c %m"
```

Show specific partition details:
```bash
scontrol show partition <partition_name>
```

Show node-level details:
```bash
scontrol show node <node_name>
```

---

## 4. Job Submission & Testing

Submit a job:
```bash
sbatch job_script.sh
```

Run an interactive job:
```bash
srun --pty bash
```

Test job without submitting (dry run):
```bash
sbatch --test-only job_script.sh
```

> **Note:** To check the estimated time when the job will run, add the `--test-only` flag or use the `checktime` command (uses `check-time.sh`).

---

## 5. Resources

Request GPUs on GPU compute nodes:
```bash
--gres=gpu:2
```

Users must specify the following in their job script to use 1 or 2 GPU cards on GPU nodes:
```bash
#SBATCH --gres=gpu:1   # for 1 GPU
#SBATCH --gres=gpu:2   # for 2 GPUs
```

Memory size options:
```bash
--mem=[MB]            # Total memory per node
--mem-per-cpu=[MB]    # Memory per CPU core
```

### ⚠️ Important Resource Guidelines

Always check the resources used (from another server), as insufficient resources will prevent the job from running. Key recommendations:

- **Number of CPUs in GPU environment** — `8` is a safe choice.
- **RAM (`--mem`)** — Always allocate at least as much RAM as total GPU memory.  
  Example: For 2 × A100 (80 GB each), use `--mem=160000` (160 GB) as a safe value.
    - `--mem` 0    # Allocate all available memory

---

## 6. Job Monitoring & Queue Utilities

View all jobs in queue:
```bash
squeue
```

View only your jobs:
```bash
squeue --me
```

Custom formatted queue view:
```bash
squeue -o "%.18i %.9P %.8j %.8u %.2t %.10M %.6D %R"
```

View completed jobs (historical):
```bash
sacct
```

Detailed job accounting:
```bash
sacct -j <jobid> --format=JobID,JobName,Partition,AllocCPUS,State,Elapsed
```

---

## 7. Viewing & Modifying Job Details

View details of a specific job:
```bash
scontrol show job <jobid>
```

Update the time limit of a running or pending job:
```bash
scontrol update jobid=106 TimeLimit=4-00:00:00
```

---

## 8. Checking GPU Usage

**Step 1.** Check your Job ID:
```bash
squeue --me
```

**Step 2.** Run `nvidia-smi` within your allocated job:
```bash
srun --jobid=<jobid> nvidia-smi
```
> The `--jobid` flag attaches `srun` to an already-allocated job.

---

## 9. Opening a Shell Inside a Worker Node

Use the following to open an interactive bash shell inside the allocated worker node:
```bash
srun --jobid=<jobid> --pty -i bash
```
This allows you to inspect the node environment, check GPU state, validate paths, and debug issues directly.

---

## 10. Cancel / Modify Jobs

Cancel a specific job:
```bash
scancel <jobid>
```

Cancel all your jobs:
```bash
scancel -u $USER
```

Hold a job (prevent it from starting):
```bash
scontrol hold <jobid>
```

Release a held job:
```bash
scontrol release <jobid>
```

---

## 11. Debugging & Logs

Check the default job output file:
```bash
cat slurm-<jobid>.out
```

Follow logs live:
```bash
tail -f slurm-<jobid>.out
```

Check node allocation and job errors:
```bash
scontrol show job <jobid>
```

---

## 12. Useful Tips & Common Pitfalls

- Always match requested resources with cluster limits (CPU, GPU, RAM).
- If a job is in **pending (PD)** state, check the reason using:
  ```bash
  squeue -j <jobid> -o "%i %t %r"
  ```

**Common pending reasons:**

| Reason | Description |
|---|---|
| `Resources` | Requested resources are not yet available |
| `PartitionTimeLimit` | Requested time exceeds partition's maximum |
| `Priority` | Other jobs have higher priority |
| `QOSMaxGRESPerUser` | GPU limit per user reached |
| `NodeDown` | Allocated node is unavailable/down |
| `ReqNodeNotAvail` | Specific requested node is unavailable |

**Other common pitfalls:**

- **Do not over-request memory** — jobs may be rejected or delayed if the requested memory exceeds node capacity.
- **Avoid long `--time` values** — unnecessarily high time limits reduce scheduling priority.
- **Module environment mismatch** — ensure all required modules (`module load`) are loaded inside your job script, not just in your interactive shell.
- **Path issues** — always use absolute paths in job scripts; relative paths may break depending on the working directory at submission time.
- **Job array pitfalls** — when using job arrays (`--array`), ensure each task writes to a unique output file using `%A` (array job ID) and `%a` (task index) in the filename.
- **NCCL errors in multi-GPU jobs** — usually caused by incorrect `--ntasks-per-node` settings. See the [Training](#13-training) section.

---

## 13. Training

### Single Node Training

For initial experimentation and debugging, training should be run **manually inside a single Slurm task**.

#### Configuration

```bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:2
```

#### Why `--ntasks-per-node=1`?

- Slurm allocates **multiple GPUs**, but launches only **1 process**.
- You manually control GPU usage (via `CUDA_VISIBLE_DEVICES` or framework configs).

This is ideal for:
- Debugging
- Validating training correctness
- Avoiding distributed setup issues

---

#### ⚠️ Important Warning

If you set:
```bash
#SBATCH --ntasks-per-node=2
```
without a proper distributed setup (`srun` / DDP), it can lead to:
- Duplicate training processes
- GPU contention
- NCCL crashes / hangs

---

### Should I use `--ntasks-per-node=4` if my script spawns 4 processes?

**No — keep `--ntasks-per-node=1`.**

---

### Key Principle

There are **two independent ways processes can be created**:

1. **Slurm** — via `--ntasks-per-node`
2. **Your training script** — via manual spawning or framework internals

> Use **only ONE of these at a time.**

---

### Your Setup (Manual Launch)

```bash
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:4
```

Then inside your script:
```bash
onmt_train ... -world_size 4 -gpu_ranks 0 1 2 3
```

**What happens:**
- Slurm launches **1 process**
- Your script spawns **4 training processes** (DDP)
- Each process uses **1 GPU**

✅ This is correct.

---

### What if you set `--ntasks-per-node=4`?

```bash
#SBATCH --ntasks-per-node=4
```

**What happens:**
- Slurm launches **4 processes**
- **Each** of those processes runs your script
- Each script may spawn **4 more processes**

**Result:** `4 (Slurm) × 4 (script) = 16 processes`

This causes:
- GPU oversubscription
- Multiple processes fighting for the same GPU
- NCCL crashes / hangs
- Completely broken training

See [Single Training Script](train-one.sh) for reference.

---

### Multi-Node Training

```bash
#!/bin/bash
#SBATCH -N 2                        # 2 nodes
#SBATCH --ntasks-per-node=2         # 2 processes per node (1 per GPU)
#SBATCH --gres=gpu:2                # 2 GPUs per node
#SBATCH --cpus-per-task=8
#SBATCH --mem=0

# ---- Distributed Setup ----
export MASTER_ADDR=$(scontrol show hostnames $SLURM_JOB_NODELIST | head -n 1)
export MASTER_PORT=29500
export WORLD_SIZE=$(($SLURM_NNODES * $SLURM_NTASKS_PER_NODE))

echo "MASTER_ADDR=$MASTER_ADDR"
echo "WORLD_SIZE=$WORLD_SIZE"

# ---- Launch ----
srun onmt_train -config yamls/a40.train.multilingual.en-xx-en.yaml
```

#### Critical Differences from Single-Node

**Nodes & GPUs:**
```bash
#SBATCH -N 2
#SBATCH --ntasks-per-node=2
#SBATCH --gres=gpu:2
```
Each GPU gets exactly 1 process. Slurm spawns **4 processes total** across both nodes.

**Do NOT manually set `CUDA_VISIBLE_DEVICES`:**
```bash
# ❌ DO NOT do this in multi-node jobs:
# CUDA_VISIBLE_DEVICES=0,1,2
```
Slurm automatically assigns GPUs per process. Setting this manually will break the mapping.

**Use `srun` to launch:**
```bash
srun onmt_train ...
```
This is critical — `srun` launches processes across nodes and sets `RANK`, `LOCAL_RANK`, and other required environment variables automatically.

**`MASTER_ADDR` / `MASTER_PORT`:**
```bash
export MASTER_ADDR=$(scontrol show hostnames $SLURM_JOB_NODELIST | head -n 1)
```
Ensures all nodes communicate through node 0.

---

### Mental Model

**Single-node:**
```
1 machine → multiple GPUs → shared memory
```

**Multi-node:**
```
Node 0  <---network--->  Node 1
 GPU  GPU              GPU  GPU
```
Communication is over the network (NCCL backend). The bottleneck shifts from **compute → network communication**.


See [Multinode Training](train-multinode.sh) for reference.


---

### Final Checklist (Before Running Multi-Node Jobs)

- [ ] Nodes can communicate (test with `ping`)
- [ ] Same software environment on all nodes (modules, conda envs, etc.)
- [ ] Shared filesystem accessible from all nodes (for data & checkpoints)
- [ ] `CUDA_VISIBLE_DEVICES` is **not** manually set
- [ ] Training is launched using `srun`
- [ ] `MASTER_ADDR` and `MASTER_PORT` are exported correctly