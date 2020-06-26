Build the PetaLinux project with a .bsp file
============================================

This file gives a quick guide on how to create a PetaLinux prject ready to use for Inference on a ZedBoard. If you prefer to build the project step by step, refer to this repository's [wiki](https://github.com/UviDTE-FPSoC/vitis-dnn/wiki) section and go through the [Software Installation](https://github.com/UviDTE-FPSoC/vitis-dnn/wiki/Software-Installation) page, subsection [Petalinux](https://github.com/UviDTE-FPSoC/vitis-dnn/wiki/Software-Installation#petalinux) and the [PetaLinux project configuration to run Deep Neural Networks](https://github.com/UviDTE-FPSoC/vitis-dnn/wiki/Petalinux-project-configuration-to-run-Deep-Neural-Networks) page.

In order to create a new project with the same configuration as the one in the .bsp file, download the ZedBoard_DNNs_DPUv3_0.bsp file in this folder of the repository. Once the file has been downloaded, enter the folder you want to create you project at and enter the following command.

```
petalinux-create -t project -s /<directory_to_bsp_file>/ZedBoard_DNNs_DPUv3_0.bsp
```

Once the project has been created, enter the project's directory with the terminal.

```
cd ZedBoard_DNNs_DPUv3_0
```

From this directory you have to configure and build the project. The configuration of the project has to be done with a file that contains the hardware description of the DPU. This file can be created with a Vivado project, following the repository's [FPSoC hardware description project](https://github.com/UviDTE-FPSoC/vitis-dnn/wiki/FPSoC-hardware-description-project) guide. A copy of the file created with this guide can be found inside the project you just created, under the directory `/<directory_to_your_petalinux_project>/project-spec`. The name of the file is `ZedBoard_2019_2_DPUv3_0_wrapper.xsa`.

To configure the project with this file, enter the following commands.

```
petalinux-config --get-hw-description=project-spec/
```

A window will pop up. You only have to press the `esc` key until the project starts the configuration proccess. If for any reason the `ZedBoard_2019_2_DPUv3_0_wrapper.xsa` file is corrupted, you can find a copy of it in this [link](https://github.com/UviDTE-FPSoC/vitis-dnn/tree/master/ZedBoard_DNNs/hardware_description_file-Vivado).

Finally, build the project and generate the boot image wiht this commands.

```
petalinux-build

petalinux-package --boot --force --fsbl ./images/linux/zynq_fsbl.elf --fpga ./images/linux/system.bit --u-boot
```

Once the boot image is created, you can mount an SD card with it as shown in the wiki's [Configure PetaLinux to boot with SD card](https://github.com/UviDTE-FPSoC/vitis-dnn/wiki/Software-Installation#configure-petalinux-to-boot-with-sd-card) subsection of the [Software Installation](https://github.com/UviDTE-FPSoC/vitis-dnn/wiki/Software-Installation) page.
