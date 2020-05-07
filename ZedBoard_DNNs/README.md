This document intends to be a guide which shows the process to use the Xilinx Edge AI tools with a ZedBoard SoC device. Most of the documentation, tutorials and examples provided by Xilinx in order to use their AI libraries and tools have been created for boards with Zynq MPSoCs Ultrascale+ chips and others. Never the less, the hardware IP block created by Xilinx to run DNN inference on their boards, the Deep Learning Procesing Unit (DPU), supports its implementation on Zynq-7000 family chips. ZedBoard mouns a Z-7020 chip, which is compatible with this hardware description block.

In this guide it is preteded to explain the whole process to implement DNN inference on Zedboard. Software tools that have to be installed, creation of the hardware description project, configuration of an Operating System project to use this harware description with the ZedBoard, installation of Edge AI compilation tools and inference of several DNN models such as mobilenetv1, mobilenetv2 and inceptionv1.

### Table of Contents

- [Prerequisites](#prereqisites)
- [Installation of Diligent Board Files](#installation-of-digilen-board-files)
- [Hardware description project](#hardware-description-project)
  - [Create a Vivado Design Suite Project](#create-a-vivado-design-suite-project)
  - [Import DPU IP to the project](#import-dpu-ip-to-the-project)
  - [Import and Interconnect all necessary IP blocks](#import-and-interconnect-all-necessary-ip-blocks)
  - [Assign register address for the design](#assign-register-address-for-the-design)
  - [Generate the bitstream](#generate-the-bitstream)
- [PetaLinux Project Installation and Configuration](#petalinux-project-installation-and-configuration)
  - [Project Creation](#project-creation)
  - [Import and configure DPU drivers and other packages](#import-and-configure-dpu-drivers-and-othr-packages)
    - [DPU drivers](#dpu-drivers)
    - [DPU device tree definition](#dpu-device-tree-definition)
    - [DPU driver individual installation](#dpu-driver-individual-installation)
    - [Driver and packages combined installation](#driver-and-packages-combined-installation)
- [Deep Neural Network Development Kit](#deep-neural-network-development-kit)
  - [Donwload and Installation of the DNNDK](#download-and-installation-of-the-dnndk)
    - [Setting up the host](#setting-up-the-host)




Prerequisites
-------------
- Vivado Design Suite v2019.2. Installation guide [here](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux/2019.2).
- PetaLinux 2019.2. Make sure the Vivado Design Suite and PetaLinux are the same version. The previous guide shows how to install petalinux.

Which Ubuntu I'm using, all tools of Xilinx I'm using ... .
In the Vivado installation, import the board files.





Installation of Digilent Board Files
------------------------------------
In this section we will focus in the installation of the Digilent Board Files for version 2019.2. The guide provided by Diligent [here](https://reference.digilentinc.com/vivado/installing-vivado/v2019.2) is followed.

Download the [archive](https://github.com/Digilent/vivado-boards/archive/master.zip?_ga=2.156349435.1935155676.1585674832-1676906505.1585674832) with the Vivado board files.

Extract this file at any directory and enter the folder within this folder named `/new/board-files/`. Copy all the files that you find in this directory.

Finally, go to the directory you have installed Vivado SDk at, enter the following folswe and copy the previous files to this folder:

```
cd <vivado_installation_directory>/Vivado/2019.2/data/boards/board_files/
```

Vivado has now access to diligent board files, in which ZedBoard is included.



Hardware description project
----------------------------
A project with a hardware description for ZedBoard has to be created in order to perform inference of any DNN. The essential hardware block to be able to implement DNN onto the ZedBoard is the DPU (Deep Learning Procesing Unit), which is an IP block created by Xilinx. In order to be able to import the DPU block to your own project, you have to download the DPU target reference design (TRD) from the Xilinx github repository [here](https://github.com/Xilinx/Vitis-AI).

This TRD has been created by Xilinx to use the DPU with the ZCU102 board, which has a Zynq MPSoC UltraScale+ chip. Therefore, the only part that is needed from this file we download is the DPU IP block, which is going to be impornted into the project created for ZedBoard.



### Create a Vivado Design Suite Project
Open the Vivado tool. One easy way to do this in Ubuntu 18.04 LTS would be to open up a terminal window and type in `Vivado`. Once the software has booted, follow the isntructions:

- Press the `Create Project` option.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/CreateProject.png)

- Give a name to your project, for example *ZedBoard_DPU_2019_2*. Select a directory to save the project at. In this, case the directory doesn't have to be saved to any special location.
- Select an RTL Project

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/RTLProject.png)

- Click next in the `Add Sources` and `Add Constraints` windows.
- In the `Default Part` window, select the boards option and look for *ZedBoard* in the 'Search' menu, as shown in the image. Once you have selected ZedBoard, click next.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/BoardFile.png)

- Once you are in the project summary, click `Finish`.


### Import the DPU IP to the project
The easiest way to proceed would be to clone the Vitis-AI repository, [https://github.com/Xilinx/Vitis-AI](https://github.com/Xilinx/Vitis-AI). This folder should be cloned to the `/home` directory, as the use of the Vitis-AI tools require certain permissions.

```
cd /home/arroas/

git clone https://github.com/Xilinx/Vitis-AI
```

Now, within the cloned folder, enter this directory.

```
cd DPU-TRD/
```

In this directory there is a folder named *dpu_ip*. This is the folder which contains the DPU IP block and which is necesary to import into the previously created project. It is not necessary, but it's recommended to copy this folder into the *ZedBoard_DPU_2019_2* folder project. Open up a terminal in the directory which is shown above and enter the following commands.

```
cp dpu_ip /media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/vitis-dnn/ZedBoard_DNNs/ZedBoard_DPU_2019_2/ZedBoard_DPU_2019_2.ip_user_files/
```

It is possible to now go into the Vivado project and press the `Tools` scroll-down window. Press on the `Settings` option, which will open a new window.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/AddIPBlock.png)

In this window, press the `IP >>> Repository` option. You can now press the add `+` option and search for the directory the *dpu_ip* folder was copied to. After this, press the `Select` button.

This action will import the DPU IP block into you IP cathalog, allowing you to introduce it into an IP Design.



### Import and Interconnect all necessary IP blocks
The implementation of DNN inference into the ZedBoard requires a hardware description that contains not just the DPU IP block. In this section, an IP Block Design will be created, including in it all the necessary IP blocks and interconecting all of them in order to create a hardware description file which will be used to run the DNN inference on ZedBoard.

With the Vivado project *ZedBoard_DPU_Config* opened, go to the `Project Manager`, at the left side of the Vivado software window and press `Create Block Design`, under the `IP INTEGRATOR` option. A new window pops up, which allows giving the block a name, *ZedBoard_DPU_HW*, and specifying a directory and source set for the design. This options shall be left as default.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/IPBlockDesign_Default.png)

The IP Block Design is now created. In order to import a new block, right click in the diagram window and press the `Add IP` option. This action enables a window where it is possible to type in the name of each of the IP blocks which have to be imported. Include the following ones:

- **ZYNQ7 Processing System**. This is the IP block which describes the ZedBoard Z-7020 chip.

The configuration of the Processing System (PS) is now described. First of all, double click the Zynq block that was just imported into the project. Once the `Re-costumize` window pops up, click on the `Presets` option and select the ZedBoard preset. The preset will therefore be applied, which will enable the most common periferics of the ZedBoard such as the UART port.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/ZedBoard_Preset.png)

The preset sets up several signals that will be needed later on in the DPU configuration, but we will indicate the process of activating them all.

> `FCLK_CLK0`. This signal creates a 100 MHz clock signal needed for the DPU register configuration. This signal is a low frequency signal, as the registers are only configured at the beginning of any DPU task.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/100MHz_PS_Signal.png)

> `FCLK_RESET0_N`. Reset signal of the generated FCLK_CLK0 clock signal. It is generated automatically when enabling the previous signal.

> `M_AXI_GP0`. The PS communicates with the Programmable Logic (PL) through a 32-bit instruction to the DPU in order to control the configuration registers of the IP block. With this port, the PS works as the master and the PL, where the DPU is implemented works as slave.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/M_AXI_GP0.png)

> `M_AXI_GP0_ACLK`. When selecting the M_AXI_GP0 port, the aclk signal is added as default. This signal has to be connected to a clock signal that generates the frequency at which the DPU registers have to be configured. This rate would be the one created by `FCLK_CLK0`.

> `IRQ_F2P[0:0]`. Interrupt input port of the PS which enables the PS to receive the interruptions generated by any core of the DPU.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/Interrupt_PS.png)

> `S_AXI_HPx`. It is necessary to add three AXI slave interfaces in order to communicate data and instructions with the DPU. The picture shows how to set up three of the four available ports. The data communicating ports have to be 64 bits, and the instruction port can be 32 bits. Boards with 128-bit support for the AXI interface should use this option as the DPU data ports can work with 64 or 128 bits of width. Once these three ports have been added, two signals for each of the ports are created as well.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/S_AXI_HPx_32_PS.png)

> `S_AXI_HPx_FIFO_CTRL`. Signal that is not going to be used.

> `S_AXI_HPx_ACLK`. Frequency signal at which the DPU is going to exchange instructions and data with the PS.




- **Deep Learning Procesing Unit (DPU)**.
*É posible, en caso de que sexa necesario aumentar a dispoñibilidade de recursos do PL reducir o número de bloques DSP que implementa a DPU. Isto pódese levar a cabo seleccionando low dpu usage.*

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_Configuration1.png)
![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_Configuration2.png)
![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_Configuration3.png)

- **Clock Wizard**. The clock wizard helps creating the circuit for the output clock frequencies needed in the design. *Indicar como fixxen o arreglo da coma ","*.

- **Concat**. This block enables concatenation of different width signals into one bus.
- **AXI Interconnect**.






### Assign register address for the design

Once all the blocks have been imported and interconnected in the design block, it is necessary to assign an address for the DPU register AXI interface.

Click on the `Address Editor` window in the project manager, and select auto-assign addresses, which is the option that is right under the `Address Editor` name.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/AddressAsignment.png)

When the addresses have been asigned, it is important to take note of several information in order to, later on, configure the DPU drivers for the DPU. Therefore, check the following data in the Vivado Project:

- **DPU Base Address**: The DPU base address can be checked out in the address editor. In this case, the offset address of the DPU is `0x4000_0000`, and the high address is `0x40FF_FFFF `.
- **IRQ number**: This number is needed for the Linux device tree description. In order to obtain it, it is necessary to obtain the `GIC IRQ` number and substract 32 from it. The number can be checked in the following image.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/GIC_IIRQ.png)

In this image we see that `[91:84]` and `[68:61]` correspond to each of the 16 interrupt signals that can be attached to the PS. Therefore, as there is only one interrupt signal for the one core of the DPU, the corresponding signal would be `IRQ_F2P[0]`. It's GIC IRQ# would therefore be 61. This can be checked out in table 7-4 of the [UG585 Zynq-7000 SoC Technical Reference Manual, page 231](https://www.xilinx.com/support/documentation/user_guides/ug585-Zynq-7000-TRM.pdf), which is shown in at the top of the following image. A copy of the document has been uploaded to this repository.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/GIC_IRQ_Zynq7000_Manual.png)

The number the DPU interrupt is connected to would be `IRQ_F2P[0]`, which corresponds to *61 - 32 = 29*, `(0x1D)`. This is the number that is needed for the Linux device tree description.



### Generate the bitstream

First of all, it is necessary to validate the IP design.

- Right click on the `Block Design` workspace and select the option `Validate Project`.

If you are using the keyboard layout `es_ES.ud8`, you might get the following error printd in the console.

> Tcl error in validate procedure while setting value '250.000' on parameter 'CLKOUT1_REQUESTED_OUT_FREQ'. unexpected "," outside function argument list
in expression "1000.000 / 2,155".
>
> Tcl error in validate procedure while setting value '450.000' on parameter 'CLKOUT2_REQUESTED_OUT_FREQ'. unexpected "," outside function argument list
in expression "1000.000 / 2,155".

This error is being triggered if your keyboard layout has established the `,` as a decimal separator, rather than the `.`. The problem can be solved by changing this configuration in the `es_ES.ud8` file. Now, open the file:

```
sudo atom /usr/share/i18n/locales/es_ES
```

Find the following section of the script, between *LC_MONETARY* and *END LC_MONETARY*, change `mon_decimal_point` to `.` and `mon_thousands_sep` to `,`. This changes the separators for currency. Now, repeat the operation between *LC_NUMERIC* and *END LC_NUMERIC*, changing `decimal_point` to `.` and `thousand_sep` to `,`. These section of your file should end up looking as follows.

```
....

LC_MONETARY
int_curr_symbol      "EUR "
currency_symbol      "<U20AC>"
mon_decimal_point    "."
mon_thousands_sep    ","
mon_grouping         3;3
positive_sign        ""
negative_sign        "-"
int_frac_digits      2
frac_digits          2
p_cs_precedes        0
p_sep_by_space       1
n_cs_precedes        0
n_sep_by_space       1
p_sign_posn          1
n_sign_posn          1
END LC_MONETARY

LC_NUMERIC
decimal_point        "."
thousands_sep        ","
grouping             3;3
END LC_NUMERIC

....
```

Finally, actuallize the modification in the system by executing this command in the terminal.

```
sudo dpkg-reconfigure locales
```

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/ConfiguringLocales.png)

- Press `enter`.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/ConfiguringLocales2.png)

- Press `enter`.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/ConfiguringLocales3.png)

- Press `enter`.

Now we have to create the HDL wrapper.

- Click the sources tab under the project manager.
- Select the `Hierarchy` tab at the bottom.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/HDL_Wrapper.png)

- Under the design sources, right click `desing_1`, and select the `Create HDL wrapper` option.

The result of this operation should leave you with a top wrapper with the following name.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/HDL_Wrapper_2.png)

The next step would be to right click `design_1_i`, and select the `Generate output products` option. A windown will pop-up where the values shown in the following image should be selected.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/GenerateOutputProducts.png)

The number of jobs selected will determine the ammount of resources your machine uses to perform this operation. Choose a number as high as possible, making sure the machine will be able to handle it.

Finally, click `Generate`. This step builds all required output products for the selected source. For example, constraints do not need to be manually created for the IP processor system. The Vivado
tools automatically generate the XDC file for the processor sub-system when Generate
Output Products is selected.

In the sources tab, by clicking `IP Sources`, next to `Hierarchy`, the output products generated can be checked.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/GenerateOutputProducts_2.png)

Now, to finish the generation of the bitstream, follow the next steps.

- Click the `Run Synthesis` option.
- Click the `Run Implementation` option.
- Click the `Generate bitstream` option.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/RunImplementation.png)

Three windows such as this one shall appear when executing the previous three steps.

Once the bitstream has been generated, export the model to a `.xsa` format file.

- Click `File`
- Click `Export`
- Select `Export Hardware`

Make sure the `Include Bitstream` option has been checked.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/ExportHardware_XSA.png)





PetaLinux Project Installation and Configuration
-------------------------------
PetaLinux is the woking Operating System chosen for this task. The reason is mainly that most of Xilinx documentation an tutorials use this operating system, which will show to be very helpful later on. Installing PetaLinux in the host requires a series of steps that are clearly explained [here](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux/2019.2).

In order to configure PetaLinux perform inference of DNNs, we have to configure the OS in a certain way. First of all, from the previous [guide](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux/2019.2), make sure to complete all the steps in the PetaLinux Configuration section. This section will guide you through the process of setting up your host machine to work with PetaLinux, as well as the creation and configuration of a PetaLinux project for ZedBoard. The creation of the project is done with the Xilinx ZedBoard .bsp file, which includes the ZedBoard drivers needed by PetaLinux.

If you are able to boot PetaLinux on ZedBoard, as explained in the guide, you can continue with the following specific configuration steps.



### Import and configure DPU drivers and other packages
There is two ways of adding drivers and packages. This task can be done with each driver or package individually, or using an adtional script that will make it easier to add or remove drivers and packages. In this section both processes are explained, as they are very similar. First of all, the DPU drivers will be added individually, and later on we'll add a script that includes several needed packages as well as the DPU.



#### DPU drivers
Once the PetaLinux project has been created, it is necessary to import the DPU drivers into the project. In order to do this, go back to the Vitis-Ai repository folder that was cloned when importing the DPU IP block into the Vivado project, [here](#import-dpu-ip-to-the-project). Once in that folder, enter the following directory.

```
cd DPU-TRD/prj/Vivado/dpu_petalinux_bsp/
```

In this directory there is one script that downloads the PetaLinux `.bsp` file for ZCU102. Download the file as follows, as it contains the DPU drivers that are needed for our project.

```
./download_bsp.sh
```

The `.bsp ` file will be downloaded to the current directory. Now it is time to untar the file.

```
$ tar xvzf xilinx-zcu102-v2019.2-final-4dpu-1.4.1.bsp
```

The file contains several folders that would be added to our project if the PetaLinux project was created using this file. This cannot be done though as the project wouldn't contain the needed drivers for ZedBoard. Therefore, it is necessary to copy the DPU drivers from this folder into our project's folder. Enter the following directory.

```
cd xilinx-zcu102-v2019.2-final-4dpu-1.4.1/project-spec/meta-user/recipes-ai/
```

The DPU folder that is found in this directory contains the DPU driver source. With a terminal opened in this directory, copy the `dpu` folder into the PetaLinux project.

```
$ cp dpu /home/arroas/PetaLinux_Projects/ZedBoard_DNN_2019.2/project-spec/meta-user/recipes-ai/
```

Once the DPU driver is in the project directory, there is several more steps to be made. The DPU kernel driver requires that the “version magic” match the kernel that we are building in
the petalinux project. This is accomplished by modifying the LINUX_VERSION_EXTENSION of
the kernel.

- In the PetaLinux project directory, open he following file.

```
cd /project-spec/meta-user/recipes-kernel/linux/

gedit linux-xlnx_%.bbappend
```

Once the file has been opened, insert the following line at the end of it.

> LINUX_VERSION_EXTENSION = "+"

Without this change, the DPU kernel driver (dpu.ko) will fail to be inserted at boot.



#### DPU device tree definition
In addition to loading the DPU kernel driver, it is also needed to define the details of the DPU
instantiation in the device tree content.

According to the [Zynq DPU v3.2 Product Guide, page 43](https://www.xilinx.com/support/documentation/ip_documentation/dpu/v3_2/pg338-dpu.pdf), the DPU device needs to be configured correctly under the PetaLinux device tree so that the DPU driver can work properly. Create a new node for the DPU and place it as the child node of “amba” in the device tree `system-user.dtsi`, which is located under `<plnx-proj-root>/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi`.
The parameters to the DPU and Softmax node are listed and described in the following table, which is *table 15* of the DPU product guide.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DeviceTreeConfig_Table1.png)

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DeviceTreeConfig_Table2.png)

The following node configuration stands for the DPU usage in the ZedBoard, with a Z-7020 chip. Below the example, there is the justification for each of the selected parameters.

``` cpp
/include/ "system-conf.dtsi"
/ {
&amba {
        ....
        dpu {
            compatible = "xilinx,dpu";
            base-addr = <0x40000000>;   //CHANGE THIS ACCORDING TO YOUR DESIGN
            dpucore {
                compatible = "xilinx,dpucore";
                interrupt-parent = <&intc>;
                interrupts = <0x0 0x1D 0x1>;
                core-num = <0x1>;
                };
            };
            ....
};
};
```

- *dpu->compatible*: Fixed value to "xilinx,dpu".
- *dpu->base-addr*: DPU base register address assigned in the Vivado project. This address is the same as the offset address that was obtained in section [assign register address for the design](#assign-register-address-for-the-design). The value of the address would be `0x4000_0000`.
- *dpucore->compatible*: Fixed value to "xilinx,dpucore".
- *dpucore->interrupt-parent*: Point to interrupt control device, which in the case of a Zynq-7000 device should be `&intc`.
- *dpucore->interrupts*: The `0x0` and the `0x1` are fixed values that do not have to be changed. The value that is placed in the middle indicates the Linux IRQ# obtained in section [assign register address for the design](#assign-register-address-for-the-design). The value  would be `0x1D`.
- *dpucore->core-num*: The number of DPU cores. This parameter is configured in section [import and interconnect all necessary IP blocks](#import-and-interconnect-all-necessary-ip-blocks).

The softmax options aren't included as this option is not compatible with Zynq-7000 family chips.



#### DPU driver individual installation
Once the previous configuration has been carried out, it is time to install the drivers in the PetaLinux project. The steps that are now indicated can be found in the `README.md` document within the DPU driver folder, at `<petalinux_project_directory>/project-spec/meta-user/recipes-ai/dpu/`.

- To compile and install the module to the target file system copy on the host, execute the following lines in the petalinux project directory. The first line builds the kernel, and the second one builds the module command.

```
petalinux-build -c kernel

petalinux-build -c dpu
```

- It is also needed to rebuild PetaLinux bootable images so that the images are updated with the updated target filesystem copy.

```
petalinux-build -x package
```

- The PetaLinux command to compile the module, install it to the target filesystem host copy and update the bootable images can be executed.

```
petalinux-build
```

- Finally, the module has to be added to the RootFS file system. First of all go to the directory `<petalinux_project_directory>/project-spec/meta-user/conf/` and add the following line to the file `user-rootfsconfig`. This process is explained in the [Petalinux Tools Documentation. Reference Guide. Page 83](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1144-petalinux-tools-reference-guide.pdf) in the *Add existent recipe into RootFS*.

```
CONFIG_dpu
```

Open now a terminal in the PetaLinux project directory, and add the module to the file system. Enter the following command, and access the folder indicated below.

```
petalinux-config -c rootfs
```

> modules > dpu

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DriverRootFS1.png)

To add the module press the "y" key and select the `<save>` option. Now exit the configuration screen.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DriverRootFS2.png)

- Re-build the project

```
petalinux-build
```

#### Driver and packages combined installation
If there is more than one driver or aditional package that you want to include to the PetaLinux configuration, this method is the most comfortable one. The idea would be to use a script where you can add all the drivers and packages not included in the rootfs of PetaLinux so that you don't have to compile them individually.

The best example can be found in the DPU-TRD `.bsp` file that was used to obtain the DPU drivers. To donload and extract this file, check the section of this guide [DPU drivers](#dpu-drivers). This file, basically, is a pre-configured PetaLinux project for ZCU102 where Xilinx has done all the necessary configuration in order to perform inference with this board. Most of this configuration should be done as well in our ZedBoard project, to ensure the DNN models can be correctly ran.

All the packages that are included in the PetaLinux project can be found in the directory `/<proj_or_bsp_directory>/project-spec/configs/`. The file named rootfs_config contains all the packages that can be included in your configuration, and the ones that are actually included are finished with a `=y`. In the folder where you extracted the `.bsp` file, you can also enter this file, and check the configuration that was made in order to run the DPU with ZCU102. It wouldn't hurt to make sure your ZedBoard project has a similar configuration. The easiest way to change this configuration would be with a console interface you can acces by openning a terminal in your project directory and typing in `petalinux-config -c rootfs`. This is the same we did previously to individually install the DPU drivers, although these drivers are not included by default to PetaLinux, so you have to copy them into the project manually.

In the DPU-TRD `.bsp` file, Xilinx didn't only add the DPU drivers as the only external package, but they added more. The file where all the external packages are included is found in the `/<bso_directory>/project-spec/meta-user/recipes-core/packagegroups/` under the name of `packagegroup-petalinux-xlnx-ai.bb`. The content of this file is now shown.

```
DESCRIPTION = "Xlnx AI Packages"

inherit packagegroup

XLNX_AI_LIBS = " \
	glog \
	gtest \
	gtest-staticdev \
	json-c \
	json-c-dev \
	libeigen-dev \
	libcanberra-gtk3 \
	libdrm \
	libdrm-kms \
	libdrm-tests \
	libx11-locale \
	opencv \
	opencv-dev \
	protobuf \
	protobuf-dev \
	protobuf-c \
	python3-pip \
"

XLNX_AI_UTILS = " \
	apt \
	auto-resize \
	cmake \
	dpkg \
	i2c-tools \
	packagegroup-petalinux-v4lutils \
	xrandr \
"

XLNX_AI_APP = " \
	dhcp-client \
	glmark2 \
	xauth \
	nfs-utils \
	openssh-sftp-server \
"

XLNX_AI_PACKAGES = " \
	ai-camera \
	base-files \
	dpcma \
	dpu \
	dpuclk \
	resolvconf \
	screen-flicker \
	tzdata \
	ntp \
	packagegroup-petalinux-weston \
	xfce4-terminal \
	${XLNX_AI_LIBS} \
	${XLNX_AI_UTILS} \
	${XLNX_AI_APP} \
"

RDEPENDS_${PN} = "${XLNX_AI_PACKAGES}"
```

In the libs tab we can find the libraries that the target could need when running ingerrence. The utils tab includes several command libraries which can be useful. The one that is needed for sure would be `dpkg`, as to install the `vitis-ai-runtime` package for any device, you need to install `.deb` files, for which you need to execute `dpkg`.

In the packages tab, the DPU is included. Therefore, this script can be copied, avoiding having to create one from scrach. Go to `/<ZedBoard_proj_directory>/project-spec/meta-user/` and create the directory `/recipes-core/packagegroups/`, copying the file `packagegroup-petalinux-xlnx-ai.bb` to it. You can now include or remove the packages that you want. The script we end up with is the follwoing.

```
DESCRIPTION = "Xlnx AI Packages"

inherit packagegroup

XLNX_AI_LIBS = " \
	glog \
	gtest \
	gtest-staticdev \
	json-c \
	json-c-dev \
	libeigen-dev \
	libcanberra-gtk3 \
	libdrm \
	libdrm-kms \
	libdrm-tests \
	libx11-locale \
	opencv \
	opencv-dev \
	protobuf \
	protobuf-dev \
	protobuf-c \
	python3-pip \
"

XLNX_AI_UTILS = " \
	apt \
	cmake \
	dpkg \
	i2c-tools \
	packagegroup-petalinux-v4lutils \
	xrandr \
"

XLNX_AI_APP = " \
	dhcp-client \
	glmark2 \
	xauth \
	nfs-utils \
	openssh-sftp-server \
"

XLNX_AI_PACKAGES = " \
	dpu \
	${XLNX_AI_LIBS} \
	${XLNX_AI_UTILS} \
	${XLNX_AI_APP} \
"

RDEPENDS_${PN} = "${XLNX_AI_PACKAGES}"
```

If you haven't included the DPU drivers yet, go back to sections [DPU drivers](#dpu-drivers) and
[DPU device tree definition](#dpu-device-tree-definition). In the directory the DPU drivers are, `/<bsp_directory>/project-spec/meta-user/recipes-ai/`, you can find most of the other packages that we removed from the `XILINX_AI_PACKAGES` section in the file `packagegroup-petalinux-xlnx-ai.bb`.

The installation of this packages is now analog to the DPU drivers individual installation.

- The packages have to be added to the RootFS file system. First of all go to the directory `<petalinux_project_directory>/project-spec/meta-user/conf/` and add the following line to the file `user-rootfsconfig`. This process is explained in the [Petalinux Tools Documentation. Reference Guide. Page 83](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_2/ug1144-petalinux-tools-reference-guide.pdf) in the *Add existent recipe into RootFS*.

```
CONFIG_packagegroup-petalinux-xlnx-ai
```

- To compile and install the modules to the target file system copy on the host, execute the following lines in the petalinux project directory. The first line builds the kernel, and the second one builds the modules command.

```
petalinux-build -c kernel

petalinux-build -c packagegroup-petalinux-xlnx-ai
```

- It is also needed to rebuild PetaLinux bootable images so that the images are updated with the updated target filesystem copy.

```
petalinux-build -x package
```

- The PetaLinux command to compile the module, install it to the target filesystem host copy and update the bootable images can be executed.

```
petalinux-build
```

Open now a terminal in the PetaLinux project directory, and add the module to the file system. Enter the following command, and access the folder indicated below.

```
petalinux-config -c rootfs
```

> user packages > packagegroup-petalinux-xlnx-ai

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DriverRootFS3.png)

To add the module press the "y" key and select the `<save>` option. Now exit the configuration screen.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DriverRootFS4.png)

The environment is also going to need a series of aditional libraries to be able to execute and install all the commands and packages neccesary to work with Vitis-AI. The libraries that would be neccesary are the following, which can be accesed with the previous interface as well.

> Filesystem > base > tar > tar
>
> Filesystem > misc > python3 > python3
>
> Petalinux Package Groups > packagegroup-petalinux-pyton-modules > packagegroup-petalinux-pyton-modules

This last python package is important in order to run and execute pip3 commands, both neccesary in the Vitis-AI runtime and the DNNDK.

- Re-build the project

```
petalinux-build
```



Deep Neural Network Development Kit
-----------------------------------
The Deep Neural Network Development Kit (DNNDK) is a full-stack deep learning SDK for the Deep-
learning Processor Unit (DPU). It provides a unified solution for deep neural network inference
applications by providing pruning, quantization, compilation, optimization, and run time support. The pruning tool can only be utilized with the use of a lincense.

There is a newer tool from Xilinx to work with Deep Neural Network inference on edge devices, which is [Vitis-AI(https://github.com/Xilinx/Vitis-AI)]. The problem with this tool is that the run time support has only been compiled for devices that mount a processor with a armv8-A architecture, that can execute 64-bit instructions, while ZedBoard has a Z-7020 chip, which has a Cortex-9 processor that has an architecture armv7-A, and can only execute 32-bit instructions.

This means that to work with ZedBoard the only option is using the latest release of the DNNDK, version 3.1. The installation of this tool and execution of the first examples is carried out following the [DNNDK User Guide](https://www.xilinx.com/support/documentation/sw_manuals/ai_inference/v1_6/ug1327-dnndk-user-guide.pdf).



### Donwnload and Installation of the DNNDK
The latest version of the DNNDK can be downloaded [here](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge), under `Edge AI Tools`. To download the release that corresponds to the v1.6 documentation you can just click [here](https://login.xilinx.com/app/xilinxinc_f5awsprod_1/exknv8ms950lm0Ldh0x7/sso/saml). The download requires to log into you Xilinx account, but its totally free. Once the package is downloaded, we create the following directory and extract the package.

```
cd /home/arroas/Xilinx-AI_Tools

tar xvzf xilinx_dnndk_v3.1_190809.tar.gz
```



#### Setting up the host
The “host_x86” folder contains the Deep Compression Tool (DECENT) and Deep Neural Network
Compiler (DNNC), the DDump and the DLet host tools, which allow neural networks to be optimized and accelerated on the DPU inference engine.

This release of the DNNDK enables the use of deep neural network models both from `Caffe` and `TensorFlow` framework.

The Caffe models need the installation of a series of dependent libraries.

```
sudo apt-get install -y --force-yes build-essential autoconf libtool libopenblas-dev libgflags-dev libgoogle-glog-dev libopencv-dev protobuf-compiler libleveldb-dev liblmdb-dev libhdf5-dev libsnappy-dev libboost-all-dev libssl-dev
```

Regarding TensorFlow, we create a conda environment to make sure it is not affected by future installations of TensorFlow packages. In this case, the TensorFlow version we are going to install is the CPU version with python 3.6, as we couldn't correctly create the environment fo the GPU version, which has faster execution time when running the decent tools.

```
$ cd /<dnndk_v3.1_extraction_directory>

$ conda create -n decent pip python=3.6

$ source activate decent

(decent)$ pip install /home/arroas/Xilinx-AI_Tools/xilinx_dnndk_v3.1/host_x86/decent-tf/ubuntu18.04/tensorflow-1.12.0-cp36-cp36m-linux_x86_64.whl

(decent)$ pip install numpy opencv-python sklearn scipy progressbar2
```

To check if the decent environment has been correctly created, run the following command.

```
(decent)$ decent_q --help
```

If the libraries and the conda environment have been added, install the DNNDK host tools.

```
cd /<dnndk_v3.1_extraction_directory>/host_x86

sudo ./install.sh
```



#### Setting up the ZedBoard
