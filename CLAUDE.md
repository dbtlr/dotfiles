# Dotfiles Repo

*NOTE: This repository's git is maintained by an auto snapshot script.*

This repository contains dotfiles that contain common scripts and shell configuration for Drew's computers.

## How We Work (local addendum)

It runs at a cadence different than standard software repository, so the "How We Work" advisement in the global CLAUDE.md applies differently here.

- It is okay to allow small changes to be committed directly to main, they will do so automatically, without your intervention required.
- This repository does not require a PR flow or an adversarial review by default. These should only be used when explicitly requested by the user.
- If writing and testing local scripts, it is advised to disable the local snapshot while work is being done, to avoid half changes being propagated. Otherwise, moving changes into a local worktree is also a fine alternative, as it will pull things out of the local snapshot.

## The Fleet

These are the computers that are currently running the dotfiles repository, this is expected to grow and change over time. All computers should be linked on a tailscale network.

### `DB-MBP`

- Description: Drew's MacBook Pro Laptop.
- Tailscale id: `db-mbp`
- Specs
  - Processor: Apple M1 Max
  - Memory: 32 GB
  - HDD: 1TB
  - OS: 26.5.2 (Tahoe)

### `Valhalla`

- Description: Mac Mini that acts as a local home server. Runs local docker processes. Accessed primarily via ssh. Acts as a persistent runner for Coding Agents, as well as a persistent Hermes Agent.
- Tailscale id: `valhalla`
- Specs:
  - Processor: Apple M4
  - Memory: 16GB
  - HDD: 2TB
  - OS: 26.5.2 (Tahoe)
