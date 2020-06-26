This file gives a quick guide on how to create a PetaLinux prject ready to use for Inference on a ZedBoard. If you prefer to build the project step by step, refer to this repository's [wiki]()page and go through the [Software Installation](https://github.com/UviDTE-FPSoC/vitis-dnn/wiki/Software-Installation#petalinux) page, subsection Petalinux and the [PetaLinux Configuration]() page.

In order to create a new project with the same configuration as the one in the .bsp file, download the ZedBoard_DNNs_DPUv3_0.bsp file in this folder of the repository. Once the file has been downloaded, enter the folder you want to create you project at and enter the following command.

```
petalinux-create -t project -s /<directory_to_bsp_file>/ZedBoard_DNNs_DPUv3_0.bsp
```
