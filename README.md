# hmsc-container
Container recipe for Hierarchical Modelling of Species Communities (HMSC)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20664829.svg)](https://doi.org/10.5281/zenodo.20664829)

Apptainer container to run [hmsc-hpc](https://github.com/aniskhan25/hmsc-hpc) (Gibbs sampler for HMSC models) on Olivia's ARM GPU nodes (Grace-Hopper).

## Files

- `Dockerfile`: container definition
- `requirements.txt`: Python dependencies
- `hmsc-hpc-aarch64_0.1.8.sif`: built Apptainer image (aarch64 architecture)

## Container contents

- Base: `nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04`
- Python 3.11
- TensorFlow 2.16.1, tf-keras 2.16, tensorflow-probability 0.24
- `hmsc` package (installed from `github.com/aniskhan25/hmsc-hpc`)
- Additional dependencies: `pandas`, `scipy`, `h5py`, `rdata`, `xarray`, `pyreadr`, etc.

## Getting the container image

The image is published at `ghcr.io/j34ni/hmsc-hpc-aarch64:0.1.8`, and it can be pulled directly using:

```
apptainer pull --arch arm64 docker://ghcr.io/j34ni/hmsc-hpc-aarch64:0.1.8
```

The `.sif` file is also available in a shared folder on Olivia (`/cluster/work/support/container/hmsc-hpc-aarch64_0.1.8.sif`).

## Usage

### 1. Prepare the init file

From R, generate an initialization object with `Hmsc::sampleMcmc(..., engine="HPC")`, then save it with `saveRDS()` (standard RDS format, **without** `to_json()`).

### 2. Run the sampler

```bash
apptainer exec --nv hmsc-hpc-aarch64_0.1.8.sif python3 -m hmsc.run_gibbs_sampler \
    --input  "your_init_file.rds" \
    --output "chain_output" \
    --samples 200 \
    --thin 100 \
    --transient 10000 \
    --verbose 1000 \
    --chain 0
```

Main parameters:
- `--input`: `.rds` init file generated from R
- `--output`: prefix for the output file containing the posterior samples
- `--samples`: number of samples to keep after burn-in
- `--thin`: thinning interval
- `--transient`: number of burn-in iterations
- `--chain`: chain index (0-based)

The `--nv` flag is required to enable GPU access.

### 3. Output

The output (`chain_output`) contains the posterior samples of the model parameters (Beta, Gamma, Lambda, Eta, etc.) for the requested chain.

## Validation test

The container was tested with a real init file (200 samples, thin=100, transient=10000): the sampler runs correctly end-to-end on GPU (~33 seconds).

## Notes

- Rebuild whenever dependencies (`requirements.txt`) or `hmsc-hpc` are updated.
- Container architecture is aarch64 (Olivia's Grace-Hopper GPU nodes).
