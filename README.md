# WRF/WPS installer

Installation scripts for WRF and WPS under Linux. All the scripts found here, builds the WRF and the main dependencies from source code.

### Sumary

- [How to use the installers](#how-to-use-the-installers)
  * [Running the installers](#running-the-installers)
  * [Available installations](#available-installations)
- [Submiting a new installer](#submiting-a-new-installer)

## How to use the installers

### Running the installers

An exemple bellow, shows how to install the WRF 4.4.2 on Ubuntu 20.04 LTS.

```shell
$ git clone https://github.com/i4sea/wrf-installer.git
$ cd wrf-installer
$ chmod +x ubuntu/focal/4.4.2-gcc-mpich-x86.sh
$ ./ubuntu/focal/4.4.2-gcc-mpich-x86.sh
```

### Available installations

| Operational System | WRF Version | WPS Version | Compilers | MPI | Script |
|-|-|-|-|-|-|
| Ubuntu Focal (20.04 LTS) | v4.4.2 | v4.4 | gcc v9.4.0  | mpich v4.1.1 | [ubuntu/focal/4.4.2-gcc-mpich-x86.sh](./ubuntu/focal/4.4.2-gcc-mpich-x86.sh) |

## Submiting a new installer

- Take care to use good practices to write the script, like use functions to improve readability.
- Follow the folders structure:
  * `<operational system>`/`<version>`/`<wrf version>`-`<compiler>`-`<mpi>`-`<architecture>`.sh
  * e.g.: `ubuntu`/`focal`/`4.4.2`-`gcc`-`mpich`-`x86`.sh
- Fork and submit a pull request.