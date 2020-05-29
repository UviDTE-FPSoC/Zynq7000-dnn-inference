  This document intends to be a guide which shows the process to use the Xilinx Edge AI tools with a ZedBoard SoC device. Most of the documentation, tutorials and examples provided by Xilinx in order to use their AI libraries and tools have been created for boards with Zynq MPSoCs Ultrascale+ chips and others. Never the less, the hardware IP block created by Xilinx to run DNN inference on their boards, the Deep Learning Procesing Unit (DPU), supports its implementation on Zynq-7000 family chips. ZedBoard mouns a Z-7020 chip, which is compatible with this hardware description block.

In this guide it is preteded to explain the whole process to implement DNN inference on Zedboard. Software tools that have to be installed, creation of the hardware description project, configuration of an Operating System project to use this harware description with the ZedBoard, installation of Edge AI compilation tools and inference of several DNN models such as mobilenetv1, mobilenetv2 and inceptionv1.

> NOTE: In the following sections, this symbol `#` indicates that the commands displayed are being executed in the board, while `$` indicates that commands are being executed in the host.

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
    - [Add libraries to RootFS](#add-libraries-to-rootfs)
- [Deep Neural Network Development Kit](#deep-neural-network-development-kit)
  - [Donwload and Installation of the DNNDK](#download-and-installation-of-the-dnndk)
    - [Setting up the host](#setting-up-the-host)
    - [Setting up the ZedBoard](#setting-up-the-zedboard)
    - [Execute examples](#execute-examples)
  - [Network Deployment of DNNDK host examples](#network-deployment-of-dnndk-host-examples)
    - [TensorFlow version of resnet_v1_50](#tensorflow-version-of-resnet_v1_50)
    - [TensorFlow version of inception_v1](#tensorflow-version-of-inception_v1)
  - [Network Deployment of DNN pre trained model](#network-deployment-of-dnn-pre-trained-model)
    - [Caffe model](#caffe-model)
    - [TensorFlow model](#tensorflow-model)
  - [Model Zoo repository](#model-zoo-repository)
    - [TensorFlow: Inception_v3](#tensoflow:-inception_v3)
    - [TensorFlow: Mobilenet_v1](#tensoflow:-mobilenet_v1)




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
};

&amba {
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

- Re-build the project

```
petalinux-build
```



#### Add libraries to RootFS
The installation and execution of the DNNDK v3.1 package and the DPU need to have certain libraries installed in the OS. Add the following list of libraries:

> - Filesystem > base > tar > tar
>
> - Filesystem > console > utils > grep > grep
>
> - Filesystem > console > utils > pkgconfig > pkgconfig
>
> - Filesystem > libs > opencv > opencv
>
> - Filesystem > libs > opencv > opencv-dev
>
> - Filesystem > libs > opencv > opencv-apps
>
> - Filesystem > libs > opencv > opencv-samples
>
> - Filesystem > libs > opencv > opencv-dbg
>
> - Filesystem > misc > python3 > python3
>
> - Filesystem > devel > make > make
>
> - Petalinux Package Groups > packagegroup-petalinux-pyton-modules > packagegroup-petalinux-pyton-modules
>
> - Petalinux Package Groups > packagegroup-petalinux-opencv > packagegroup-petalinux-opencv

- To add this libraries, follow this procedure:

```
petalinux-config -c rootfs
```

> Filesystem > base > tar > tar

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DriverRootFS5.png)

- Press `enter`.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DriverRootFS6.png)

- Press `enter`.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DriverRootFS.png)

- Press `enter`.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DriverRootFS8.png)

- To add the module press the "y" key and select the `<save>` option. Now exit the configuration screen.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/DPU_DriverRootFS9.png)

The rest of the libraries would be added in an analog manner.

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

It is necessary to copy the ZedBoard package into the board. Execute the following commands with a SSH connection created with the ZedBoard. Check this [guide]() to create this type of connection.

```
cd /<xilinx-dnndk-v3.1_directory>

sudo scp -r ./ZedBoard root@192.168.0.21:~/xilinx-dnndk-v3.1
```

Once the folder has been copied to de board, you are ready to install the package.

```
# cd ~/xilinx-dnndk-v3.1/ZedBoard/

# ./install.sh
```

> NOTE: During the installation of the package, it is necesary that the file `opencv.pc` is located in the RootFS `/usr/lib/pkgconfig/` folder. The only configuration that seems to generate this file at this location is adding the opencv package to the RootFS file system with the command `petalinux-config -c rootfs` at the `> Filesystem > libs > opencv`. The addition of the needed libraries is better explained in section [Add libraries to RootFS](#add-libraries-to-rootfs).



#### Execute examples
After installing the DNNDK ZedBoard package in the board, there is several examples ready to be executed. This way you can see if everything is working properly.

- **Resnet50**: The resnet50 example has been created in C++. In the directory `# ~/xilinx-dnndk-v3.1/ZedBoard/samples/resnet50` there is two folders and a *Makefile*. The makefile is neccesary to create the executable of the model, which is going to have the same name as the model. The *Makefile* is executed with the `make` command. In the `model` folder, there is the DPU model of the used DNN. This file can be created with the DNNDK libraries that can be used in the host machine. In the folder `src`, there is the C++ code for the processor that actually manages the DPU and processor kernels, loads the images, and executes the application. Here is where it is possible to implement in the ZedBoard CPU the execution of DNN layers the DPU has no support for, such as the `softmask` layer.

In order to run this example, execute this lines in a linux console of your host machine connected to the board through ssh. There is a guide on how to stablish this type of conection [here](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux/2019.2#configure-ip-to-connect-to-the-board), in section **SHH connection**.

Once the connection has been established, run the following commands in the board through this connection.

```
# cd ~/xilinx-dnndk-v3.1/ZedBoard/samples/resnet50/

# make

# ./resnet50
```

The result printed in your screen should be similar to this one.

```
Load image : PIC_001.jpg

Run DPU Task for ResNet50 ...
  DPU Task Execution time: 100915us
  DPU Task Performance: 76.4009GOPS
top[0] prob = 0.759646  name = Border collie
top[1] prob = 0.169500  name = collie
top[2] prob = 0.008439  name = Irish wolfhound
top[3] prob = 0.008439  name = borzoi, Russian wolfhound
top[4] prob = 0.006572  name = Saint Bernard, St Bernard
```

The input image in this case whas the following.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/PIC_001.jpg)

----------------------------------------------------------------------



- **inception_v1_mt**: This other example has been created with python. The file `inception_v1_mt` contains the code for the processor of the board, that, similarly to the last example, manages the DPU and processor kernels, loads the images, and executes the application.

To run this example, execute the following comand, indicating the number of threads you want to be used. Depending on the board, the most efficient number of threads can differ.

```
# cd ~/xilinx-dnndk-v3.1/ZedBoard/samples/inception_v1_mt/

# ./inception_v1_mt.py 1
```

The printed result should be the following for one thread:

```
Loading  PIC_001.jpg
Input thread number is: 1
17.65 FPS
```



### Network Deployment of DNNDK host examples
There are two stages for developing deep learning applications, training and inference. The training
stage is used to design a neural network for a specific task (such as image classification) using a huge amount of training data. The inference stage involves the deployment of the previously designed neural network to handle new input data not seen during the training stage.
The DNNDK toolchain provides an innovative workflow to efficiently deploy deep learning inference
applications on the DPU.

In ths secction we guide you throught the creation of an inference application, having an already trained model. In this case we use the already existing models in the `/<dnndk-package-download directory>/xilinx_dnndk_v3.1/host/models/` directory, both for `Caffe` and `TensorFlow` frameworks. The steps followed to generate the application are now listed donw.

1. Compress the neural network model. This is a method to reduce the size of the network by executing pruning or quantization. Pruning consists in modifying the weights and biases that are very close to zero with a zero. Quantization, on the other hand, will switch the data type of the weights and biases, usually from `float32` to `int8`. Both of this opperations have the capability of highly reducing the memory space needed to execute a DNN while barely reducing the efficiency.

The pruning tool is not supported in theis release, and the purchase of a license is needed to be able to use it.

2. Compile the neural network model. Toold used to create the binary file of the model that can be later on used byt the ZedBoard application we create.

3. Program with DNNDK APIs.

4. Compile the hybrid DPU application.

5. Run the hybrid DPU executable.

The execution of all the examples needs a calibration data set of 100 to 1000 images that can be downloaded from the ImageNet dataset [here](http://academictorrents.com/collection/imagenet-2012). In this page you can download a 147 GB file with training images, which you don't need for the DNNDK package, or a 6.74 GB file with validation images. This smaller set should be downloaded, and can be done [here](http://academictorrents.com/details/a306397ccf9c2ead27155983c254227c0fd938e2). The `.tar` arquive you can download here contains up to 50000 images. The problem with this images is that there is no `.txt` file with them that contains a list of all the images with no labels. We are going to create this list with a python script. The content of this file would be the following:

```python
# -*- coding: utf-8 -*-

def main():

    # Open the file for writing and create it if it doewn't exist
    f = open("imagenet_calib.txt","w+")

    # Write the name of the images from 1 to 1000
    i = 1
    while i<10:
        f.write("ILSVRC2012_val_0000000{}.JPEG\n".format(i))
        i = i + 1

    while i<100:
        f.write("ILSVRC2012_val_000000{}.JPEG\n".format(i))
        i = i + 1

    while i<1000:
        f.write("ILSVRC2012_val_00000{}.JPEG\n".format(i))
        i = i + 1

    while i<5001:
        f.write("ILSVRC2012_val_0000{}.JPEG\n".format(i))
        i = i + 1

    #Close the file when finished
    f.close()


if __name__== "__main__":
    main()
```

You can copy this text to a `<name_of_the_file>.py` file and create the `imagenet_calib.txt` file by runing the command `python <name_of_the_file>.py` in the terminal.

To download both the validation data list and training data list for both imagenet datasets, with lists containig the labels, is using the script [here](https://github.com/BVLC/caffe/blob/master/data/ilsvrc12/get_ilsvrc_aux.sh).



#### TensorFlow version of resnet_v1_50
This section guides you through the compression and compilation process of an inference application for a `resnet_v1_50` model in the TensorFlow framework. We will be using the already existing scripts in the `/<xilinx-dnndk-v3.1-download_directory/xilinx_dnndk_v3.1/host/models/TensoFlow/resnet_v1_50` directory. This example follows the steps of the [DNNDK User Guide](https://www.xilinx.com/support/documentation/sw_manuals/ai_inference/v1_6/ug1327-dnndk-user-guide.pdf). The actual creation of each of the scripts needed will be explained with detail in section [Network Deployment of DNN pre trained model](#network-deployment-of-dnn-pre-trained-model).

This example's directory contains several scripts. First of all it has the pre-trained model of resnet_v1_50 in the `float_graph` folder. The files within this folder are used by the `freeze_graph.sh` to generate the `.pb` file used as imput of the quantization tool. This file's content is now displayed.

```
#!/bin/sh
set -e

freeze_graph \
  --input_graph=./float_graph/resnet_v1_50_inf_graph.pb \
  --input_checkpoint=./float_graph/resnet_v1_50.ckpt \
  --input_binary=true \
  --output_graph=./frozen_resnet_v1_50.pb \
  --output_node_names=resnet_v1_50/predictions/Reshape_1
```

In this script we have the `output_node_names` field to fill up, and in future scripts, we will also have the `input_node_names` one. To obtain an estimation of what names you should put in here, run the following command.

```
$ cd /<xilinx-dnndk-v3.1-download_directory/xilinx_dnndk_v3.1/host/models/TensoFlow/resnet_v1_50/float_graph

$ decent_q inspect --input_frozen_graph resnet_v1_50_inf_graph.pb
```

The result should be similar to the following, and as we see, in indicates the possible input and output name that can be used.

```
Op types used: 533 Const, 267 Assign, 267 VariableV2, 267 Identity, 70 Add, 54 Conv2D, 54 Mul, 54 TruncatedNormal, 53 FusedBatchNorm, 49 Relu, 45 Fill, 4 MaxPool, 4 Pad, 2 Reshape, 1 BiasAdd, 1 Mean, 1 Placeholder, 1 Shape, 1 Softmax, 1 Squeeze

Found 1 possible inputs: (name=input, type=float(1), shape=[?,224,224,3])
Found 1 possible outputs: (name=resnet_v1_50/predictions/Reshape_1, op=Reshape)
```

To execute this script, do the following. It is not necessary to execute it though as the directory already contains the output `frozen_resnet_v1_50.pb` file needed by the quantization tool.

```
$ cd /<xilinx-dnndk-v3.1-download_directory/xilinx_dnndk_v3.1/host/models/TensoFlow/resnet_v1_50

$ source activate decent

$ sh freeze_graph.sh
```

- **Prepare floating-point frozen model and dataset**.
The image pre-processing is not included in the `.pb` output of the frozen graph. The application is going to need this pre-processing, therefore it is included in the `resnet_v1_50_input_fn.py` python script. This script crops the images to a `224x224` size and performs mean_image_substraction.

```python
from resnet_v1_50_preprocessing import *

def eval_input(iter, eval_image_dir, eval_image_list, class_num, eval_batch_size):
  images = []
  labels = []
  line = open(eval_image_list).readlines()
  for index in range(0, eval_batch_size):
    curline = line[iter * eval_batch_size + index]
    [image_name, label_id] = curline.split(' ')
    image = cv2.imread(eval_image_dir + image_name)
    image = central_crop(image, 224, 224)
    image = mean_image_subtraction(image, MEANS)
    images.append(image)
    labels.append(int(label_id))
  lb = preprocessing.LabelBinarizer()
  lb.fit(range(0, class_num))
  labels = lb.transform(labels)
  return {"input": images, "labels": labels}

# calib_image_dir = "../../calibration_data/imagenet_images/"
calib_image_dir = "/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/"
# calib_image_list = "../../calibration_data/imagenet_calib.txt"
calib_image_list = "/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_calib.txt"
calib_batch_size = 50
def calib_input(iter):
  images = []
  line = open(calib_image_list).readlines()
  for index in range(0, calib_batch_size):
    curline = line[iter * calib_batch_size + index]
    calib_image_name = curline.strip()
    image = cv2.imread(calib_image_dir + calib_image_name)
    image = central_crop(image, 224, 224)
    image = mean_image_subtraction(image, MEANS)
    images.append(image)
  return {"input": images}
```

The crop and mean_image_substraction funcitons are defined in the `resnet_v1_50_preprocessing.py` script.

```python
import cv2
from sklearn import preprocessing

_R_MEAN = 123.68
_G_MEAN = 116.78
_B_MEAN = 103.94

MEANS = [_B_MEAN,_G_MEAN,_R_MEAN]

def mean_image_subtraction(image, means):
  B, G, R = cv2.split(image)
  B = B - means[0]
  G = G - means[1]
  R = R - means[2]
  image = cv2.merge([R, G, B])
  return image

def central_crop(image, crop_height, crop_width):
  image_height = image.shape[0]
  image_width = image.shape[1]
  offset_height = (image_height - crop_height) // 2
  offset_width = (image_width - crop_width) // 2
  return image[offset_height:offset_height + crop_height, offset_width:
               offset_width + crop_width]

def normalize(image):
  image=image/256.0
  image=image-0.5
  image=image*2
  return image
```

In this script you only need to modify the `calib_image_dir` and the `calib_image_list` to the directory where you downloaded your images.

--------------------------------------------------------------------

- **Quantization**.
To run quantization, execute the `decent_q.sh` script.

```
sh decent_q.sh
```

This script configures the quantization tool, indicating the previously created frozen graph as an input, with the image size after the preprocessing and the input_fn file that creates the preprocesing of the images.

```
decent_q quantize \
    --input_frozen_graph frozen_resnet_v1_50.pb \
    --input_nodes input \
    --input_shapes ?,224,224,3 \
    --output_nodes resnet_v1_50/predictions/Reshape_1 \
    --input_fn resnet_v1_50_input_fn.calib_input \
    --method 1 \
    --gpu 0 \
    --calib_iter 10 \
    --output_dir ./quantize_results \
```

Note that the input_fn graph is a `resnet_v1_50_input_fn.py` file in our directory, but in the script above is indicated as a `resnet_v1_50_input_fn.calib_input` file.

Executing this file though will generate an error if you have downloaded images from the [link](http://academictorrents.com/details/a306397ccf9c2ead27155983c254227c0fd938e2) we previously indicated. The reason is that the `resnet_v1_50_input_fn.py` script shown before has a crop function with size `224x224`, while some of the images in the database of the link are smaller. This will create an error when performing calibration in the quantization script.

To avoid this problem follow these steps.

- In the `resnet_v1_50_input_fn.py` you have selected a batch size of 50, and in the `decent_q.sh`, a number of 10 calibration iterations. This means that you need a total of 500 images to calibrate the model.
- Go to the images list created with the python script shown in section [Network Deployment of DNNDK host examples](#network-deployment-of-dnndk-host-examples), and erase the names wiht the numbers `87, 157, 188, 199, 436, 504`. This way you will ensure that the first 500 images of the list are big enough.
- If you want to use more images for you calibration, check that all the images have a size bigger than `224x224`.
- Execute the quantization tool, `sh decent_q.sh`.

Once the quantization has been performed, the output should be similar to this one:

```
(decent) arroas@arroas-GL65-9SEK:~/Xilinx-AI_Tools/xilinx_dnndk_v3.1/host_x86/models/tensorflow/resnet_v1_50$ sh decent_q.sh
INFO: Checking Float Graph...
INFO: Float Graph Check Done.
INFO: Calibrating for 10 iterations...
100% (10 of 10) |#############################################| Elapsed Time: 0:08:53 Time:  0:08:53
INFO: Calibration Done.
INFO: Generating Deploy Model...
[DEPLOY WARNING] Node resnet_v1_50/predictions/Reshape_1(Type: Reshape) is not quantized and cannot be deployed to DPU,because it has unquantized input node: resnet_v1_50/predictions/Softmax. Please deploy it on CPU.
INFO: Deploy Model Generated.
********************* Quantization Summary *********************      
INFO: Output:       
  quantize_eval_model: ./quantize_results/quantize_eval_model.pb       
  deploy_model: ./quantize_results/deploy_model.pb
```

The quantized model will be saved to the `quantize_results` folder, within the directory of the example.

--------------------------------------------------------------------

- **Compilation**.

To compile the example for ZedBoard, execute the `dnnc_ZedBoard.sh` script:

```
sh dnnc_ZedBoard.sh
```

The content of this script should be the following:

```
#!/usr/bin/env bash

net="resnet_v1_50"
CPU_ARCH="arm64"
DNNC_MODE="debug"
dnndk_board="ZedBoard"
dnndk_dcf="../../../dcf/ZedBoard.dcf"

echo "Compiling Network ${net}"

# Work space directory
work_dir=$(pwd)

# Path of caffe quantization model
model_dir=${work_dir}/quantize_results
# Output directory
output_dir="dnnc_output"

tf_model=${model_dir}/deploy_model.pb

DNNC=dnnc

# Get DNNDK config info
if [ ! -f /etc/dnndk.conf ]; then
    echo "Error: Cannot find /etc/dnndk.conf"
    exit 1
else
    tmp=$(grep "DNNDK_VERSION=" /etc/dnndk.conf)
    dnndk_version=${tmp#DNNDK_VERSION=}
    dnndk_version=${dnndk_version#v}
    echo "DNNDK      : $dnndk_version"
    echo "Board Name : $dnndk_board"
    echo "DCF file   : $dnndk_dcf"
fi

if [ ! -d "$model_dir" ]; then
    echo "Can not found directory of $model_dir"
    exit 1
fi

[ -d "$output_dir" ] || mkdir "$output_dir"

echo "CPU Arch   : $CPU_ARCH"
echo "DNNC Mode  : $DNNC_MODE"
echo "$(dnnc --version)"
$DNNC   --parser=tensorflow                         \
       --frozen_pb=${tf_model}                     \
       --output_dir=${output_dir}                  \
       --dcf=${dnndk_dcf}                          \
       --mode=${DNNC_MODE}                         \
       --cpu_arch=${CPU_ARCH}                      \
       --net_name=${net}
```

You shouldn't need to make any changes to this script. The results of this script should be the files with the kernels of the DPU, for all the layers supported by it, and the kernels of the CPU, for all the layers not supported. The communication between the kernels of DPU and CPU has to be done manually in the application script. In this case, the output of the `dnnc_ZedBoard.sh` should be the following:

```
(decent) arroas@arroas-GL65-9SEK:~/Xilinx-AI_Tools/xilinx_dnndk_v3.1/host_x86/models/tensorflow/resnet_v1_50$ sh dnnc_ZedBoard.sh
Compiling Network resnet_v1_50
DNNDK      : 3.1
Board Name : ZedBoard
DCF file   : ../../../dcf/ZedBoard.dcf
CPU Arch   : arm64
DNNC Mode  : debug
dnnc version v3.00
DPU Target : v1.4.0
Build Label: Aug  9 2019 05:23:25
Copyright @2019 Xilinx Inc. All Rights Reserved.

[DNNC][Warning] layer [resnet_v1_50_SpatialSqueeze] (type: Squeeze) is not supported in DPU, deploy it in CPU instead.
[DNNC][Warning] layer [resnet_v1_50_predictions_Softmax] (type: Softmax) is not supported in DPU, deploy it in CPU instead.

DNNC Kernel topology "resnet_v1_50_kernel_graph.jpg" for network "resnet_v1_50"
DNNC kernel list info for network "resnet_v1_50"
                               Kernel ID : Name
                                       0 : resnet_v1_50_0
                                       1 : resnet_v1_50_1

                             Kernel Name : resnet_v1_50_0
--------------------------------------------------------------------------------
                             Kernel Type : DPUKernel
                               Code Size : 0.99MB
                              Param Size : 24.35MB
                           Workload MACs : 6964.51MOPS
                         IO Memory Space : 2.25MB
                              Mean Value : 0, 0, 0,
                              Node Count : 58
                            Tensor Count : 59
                    Input Node(s)(H*W*C)
            resnet_v1_50_conv1_Conv2D(0) : 224*224*3
                   Output Node(s)(H*W*C)
           resnet_v1_50_logits_Conv2D(0) : 1*1*1000


                             Kernel Name : resnet_v1_50_1
--------------------------------------------------------------------------------
                             Kernel Type : CPUKernel
                    Input Node(s)(H*W*C)
             resnet_v1_50_SpatialSqueeze : 1*1*1000
                   Output Node(s)(H*W*C)
        resnet_v1_50_predictions_Softmax : 1*1*1000

```

The result files would be a .elf kernel, `resnet_v1_50_0`, to deploy in the DPU, and the `resnet_v1_50_1`, which has to be created by the user and deployed in the CPU of your target board.

------------------------------------------------------------------------------

#### TensorFlow version of inception_v1
This section guides you through a whlole inference application creation for a `inception_v1` model in the TensorFlow framework. We will be using the already existing scripts in the `/<xilinx-dnndk-v3.1-download_directory/xilinx_dnndk_v3.1/host/models/TensoFlow/resnet_v1_50` directory. This example follows the steps of the [DNNDK User Guide](https://www.xilinx.com/support/documentation/sw_manuals/ai_inference/v1_6/ug1327-dnndk-user-guide.pdf). The actual creation of each of the scripts needed will be explained with detail in section [Network Deployment of DNN pre trained model](#network-deployment-of-dnn-pre-trained-model).

This example's directory contains several scripts. First of all it has the pre-trained model of inception_v1 in the `float_graph` folder. The files within this folder are used by the `freeze_graph.sh` to generate the `.pb` file used as imput of the quantization tool. This file's content is now displayed.

```
#!/bin/sh
set -e

freeze_graph \
  --input_graph=./float_graph/inception_v1_inf_graph.pb \
  --input_checkpoint=./float_graph/inception_v1.ckpt \
  --input_binary=true \
  --output_graph=./frozen_inception_v1.pb \
  --output_node_names=InceptionV1/Logits/Predictions/Reshape_1
```

To check the input and output node names, which are necesary in this and future scripts, run the following command.

```
$ cd /<xilinx-dnndk-v3.1-download_directory/xilinx_dnndk_v3.1/host/models/TensoFlow/inception_v1/float_graph

$ decent_q inspect --input_frozen_graph inception_v1_inf_graph.pb
```

The result should be the following:

```
Op types used: 529 Const, 231 Identity, 230 Assign, 230 VariableV2, 58 Conv2D, 58 Mul, 58 TruncatedNormal, 58 Add, 57 FusedBatchNorm, 57 Relu, 13 MaxPool, 9 ConcatV2, 2 Reshape, 1 BiasAdd, 1 Fill, 1 AvgPool, 1 Placeholder, 1 Shape, 1 Softmax, 1 Squeeze

Found 1 possible inputs: (name=input, type=float(1), shape=[?,224,224,3])
Found 1 possible outputs: (name=InceptionV1/Logits/Predictions/Reshape_1, op=Reshape)
```

To execute the script that freezes the model, use the following commands. It is not necessary to execute it though, as the directory already contains the output `frozen_inception_v1.pb` file needed by the quantization tool.

```
$ cd /<xilinx-dnndk-v3.1-download_directory/xilinx_dnndk_v3.1/host/models/TensoFlow/resnet_v1_50

$ source activate decent

$ sh freeze_graph.sh
```

Once this operation has finished, you can evaluate the `frozen_inception_v1.pb` freezed model with the `evaluate_frozen_graph.sh`.

```
#!/bin/sh

set -e

# Please set your imagenet validation dataset path here,
IMAGE_DIR=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/
IMAGE_LIST=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/val.txt

# Please set your batch size settings here, #IMAGES = VAL_BATCHES * BATCH_SIZE
# Commonly there are 5w image in total for imagenet validation dataset
EVAL_BATCHES=10     #1000
BATCH_SIZE=50

python inception_v1_eval.py \
  --input_frozen_graph frozen_inception_v1.pb \
  --input_node input \
  --output_node InceptionV1/Logits/Predictions/Reshape_1 \
  --eval_batches $EVAL_BATCHES \
  --batch_size $BATCH_SIZE \
  --eval_image_dir $IMAGE_DIR \
  --eval_image_list $IMAGE_LIST \
  --gpu 0
```

> NOTE: the val.txt with the image names and labels can be downloaded from the link indicated in section [Network Deployment of DNNDK host examples](#network-deployment-of-dnndk-host-examples)

Evalutaion should be run with the 1000 batches, but we don't have that many images. The results with 10 batches are the following.

```
Use tf.gfile.GFile.
Start Evaluation for 10 Batches...
100% (10 of 10) |#############################################| Elapsed Time: 0:00:20 Time:  0:00:20
Accuracy: Top1: 0.6320000052452087, Top5: 0.8519999921321869
```

- **Prepare floating-point frozen model and dataset**.

The image pre-processing is not included in the `.pb` output of the frozen graph. The application is going to need this pre-processing, therefore it is included in the `inception_v1_input_fn.py` python script. This script crops the images to a `224x224` size and performs mean_substraction, but the user can define any preprocesing sequence they need.

```python
from inception_v1_preprocessing import *

def eval_input(iter, eval_image_dir, eval_image_list, class_num, eval_batch_size):
  images = []
  labels = []
  line = open(eval_image_list).readlines()
  for index in range(0, eval_batch_size):
    curline = line[iter * eval_batch_size + index]
    [image_name, label_id] = curline.split(' ')
    image = cv2.imread(eval_image_dir + image_name)
    image = central_crop(image, 224, 224)
    image = mean_image_subtraction(image, MEANS)
    image = normalize(image)
    images.append(image)
    labels.append(int(label_id) + 1)
  lb = preprocessing.LabelBinarizer()
  lb.fit(range(0, class_num))
  labels = lb.transform(labels)
  return {"input": images, "labels": labels}


# calib_image_dir = "../../calibration_data/imagenet_images/"
calib_image_dir = "/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/"
# calib_image_list = "../../calibration_data/imagenet_calib.txt"
calib_image_list = "/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_calib.txt"
calib_batch_size = 1
def calib_input(iter):
  images = []
  line = open(calib_image_list).readlines()
  for index in range(0, calib_batch_size):
    curline = line[iter * calib_batch_size + index]
    calib_image_name = curline.strip()
    image = cv2.imread(calib_image_dir + calib_image_name)
    image = central_crop(image, 224, 224)
    image = mean_image_subtraction(image, MEANS)
    image = normalize(image)
    images.append(image)
  return {"input": images}
```

In this script, it is important to specify the directory where the images you downloaded in section [Network Deployment of DNNDK host examples](#network-deployment-of-dnndk-host-examples) are located. This images have a problem that was already indicated with the `resnet_v1_50` example. Some of them are smaller than `224x224` pixels, therefore an error occurs when performing the crop function to those images. For the first 500 images, the list of images you should get rid of is `87, 157, 188, 199, 436, 504`. If you use any of the remaining 49500 images that you can download, have in mind that there can be more images smaller than the required size for this crop function.

The functions of this script are defined in the `inception_v1_preprocessing.py` script.

```python
import cv2
from sklearn import preprocessing

_R_MEAN = 0
_G_MEAN = 0
_B_MEAN = 0

MEANS = [_B_MEAN,_G_MEAN,_R_MEAN]

def mean_image_subtraction(image, means):
  B, G, R = cv2.split(image)
  B = B - means[0]
  G = G - means[1]
  R = R - means[2]
  image = cv2.merge([R, G, B])
  return image

def central_crop(image, crop_height, crop_width):
  image_height = image.shape[0]
  image_width = image.shape[1]

  offset_height = (image_height - crop_height) // 2
  offset_width = (image_width - crop_width) // 2

  return image[offset_height:offset_height + crop_height, offset_width:
               offset_width + crop_width]

def normalize(image):
  image=image/256.0
  image=image-0.5
  image=image*2
  return image
```

--------------------------------------------------------------------

- **Quantization**.

To run quantization, execute the `decent_q.sh` script.

```
sh decent_q.sh
```

The content of this script should look like below.

```
decent_q quantize \
  --input_frozen_graph frozen_inception_v1.pb \
  --input_nodes input \
  --input_shapes ?,224,224,3 \
  --output_nodes InceptionV1/Logits/Predictions/Reshape_1 \
  --input_fn inception_v1_input_fn.calib_input \
  --method 1 \
  --gpu 0 \
  --calib_iter 100 \
```

It is clearly seen that the input and output nodes are filed with the names obtained from running the `decent_q inspect` command. The `calib_iter` field indicates how many iterations are made. As we are using a batch size of 1, the total images needed for the calibration process are 100. This is better explained in section [TensorFlow model](#tensorflow-model)'s third step.

The output you get from a succesfull quantization should look like this.

```
INFO: Checking Float Graph...
INFO: Float Graph Check Done.
INFO: Calibrating for 100 iterations...
100% (100 of 100) |###########################################| Elapsed Time: 0:00:39 Time:  0:00:39
INFO: Calibration Done.
INFO: Generating Deploy Model...
[DEPLOY WARNING] Node InceptionV1/Logits/Predictions/Reshape_1(Type: Reshape) is not quantized and cannot be deployed to DPU, because it has unquantized input node: InceptionV1/Logits/Predictions/Softmax. Please deploy it on CPU.
INFO: Deploy Model Generated.
********************* Quantization Summary *********************      
INFO: Output:       
  quantize_eval_model: ./quantize_results/quantize_eval_model.pb       
  deploy_model: ./quantize_results/deploy_model.pb
```

Once quantization has been performed, we can evaluate the model again, to see if there is any significant loss in accuracy. We would now use the `evaluate_quantized_graph.sh` script.

```
#!/bin/sh

set -e

# Please set your imagenet validation dataset path here,
IMAGE_DIR=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/
IMAGE_LIST=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/val.txt

# Please set your batch size settings here, #IMAGES = VAL_BATCHES * BATCH_SIZE
# Commonly there are 5w image in total for imagenet validation dataset
EVAL_BATCHES=10		#1000
BATCH_SIZE=50

python inception_v1_eval.py \
  --input_frozen_graph quantize_results/quantize_eval_model.pb \
  --input_node input \
  --output_node InceptionV1/Logits/Predictions/Reshape_1 \
  --eval_batches $EVAL_BATCHES \
  --batch_size $BATCH_SIZE \
  --eval_image_dir $IMAGE_DIR \
  --eval_image_list $IMAGE_LIST \
  --gpu 0
```

> NOTE: the val.txt with the image names and labels can be downloaded from the link indicated in section [Network Deployment of DNNDK host examples](#network-deployment-of-dnndk-host-examples)

The val.text file has to contain a list with all the image names and the labels of each image. The result of the evaluation is now showed, although it would be better to use the 50000 images, and not only 500.

```
Start Evaluation for 10 Batches...
100% (10 of 10) |#############################################| Elapsed Time: 0:00:29 Time:  0:00:29
Accuracy: Top1: 0.6020000040531158, Top5: 0.8339999973773956
```

|Accuracy|Frozen Graph      |Quantized Graph   |
|--------|------------------|------------------|
|Top1    |0.6320000052452087|0.6020000040531158|
|Top5    |0.8519999921321869|0.8339999973773956|

A comparison between the frozen and quantized graph is made in the previous table, and the accuracy drop is lower than a 5%.

After evaluation, we perform the dump operation, to compare the DPU results to the CPU/GPU ones. To dump the quantized model, run the `dump.sh` script. The input of this tool is the quantization output used previously in the evaluation process. For the `input_fn` script, the best idea is to use the same script as for quantization, but changing the batch size to 1.

```
decent_q dump \
  --input_frozen_graph quantize_results/quantize_eval_model.pb \
  --input_fn resnet_v1_50_input_fn.calib_input \
  --max_dump_batches 2 \
  --dump_float 0 \
  --output_dir ./quantize_results \
```

The output of runing the dump functionality, `(decent) $ sh dump.sh`, is now shown.

```
INFO: Start Dumping for 2 batches
INFO: Dumping for batch: 1/2 ...
INFO: Dumping for batch: 2/2 ...
INFO: Dump results are saved in ./quantize_results.
```



--------------------------------------------------------------------

- **Compilation**.

To compile the example for ZedBoard, execute the `dnnc_ZedBoard.sh` script:

```
sh dnnc_ZedBoard.sh
```

The content of this script should be the following:

```
#!/usr/bin/env bash

net="inception_v1"
CPU_ARCH="arm32"
DNNC_MODE="debug"
dnndk_board="ZedBoard"
dnndk_dcf="../../../dcf/ZedBoard.dcf"

echo "Compiling Network ${net}"

# Work space directory
work_dir=$(pwd)

# Path of caffe quantization model
model_dir=${work_dir}/quantize_results
# Output directory
output_dir="dnnc_output"

tf_model=${model_dir}/deploy_model.pb

DNNC=dnnc

# Get DNNDK config info
if [ ! -f /etc/dnndk.conf ]; then
    echo "Error: Cannot find /etc/dnndk.conf"
    exit 1
else
    tmp=$(grep "DNNDK_VERSION=" /etc/dnndk.conf)
    dnndk_version=${tmp#DNNDK_VERSION=}
    dnndk_version=${dnndk_version#v}
    echo "DNNDK      : $dnndk_version"
    echo "Board Name : $dnndk_board"
    echo "DCF file   : $dnndk_dcf"
fi

if [ ! -d "$model_dir" ]; then
    echo "Can not found directory of $model_dir"
    exit 1
fi

[ -d "$output_dir" ] || mkdir "$output_dir"

echo "CPU Arch   : $CPU_ARCH"
echo "DNNC Mode  : $DNNC_MODE"
echo "$(dnnc --version)"
$DNNC   --parser=tensorflow                         \
       --frozen_pb=${tf_model}                     \
       --output_dir=${output_dir}                  \
       --dcf=${dnndk_dcf}                          \
       --mode=${DNNC_MODE}                         \
       --cpu_arch=${CPU_ARCH}                      \
       --net_name=${net}
```

After compilation is succesful, the results should be sabed to the `dnnc_output` folder. The message printed in the terminal is the following.

```
Compiling Network inception_v1
DNNDK      : 3.1
Board Name : ZedBoard
DCF file   : ../../../dcf/ZedBoard.dcf
CPU Arch   : arm32
DNNC Mode  : debug
dnnc version v3.00
DPU Target : v1.4.0
Build Label: Aug  9 2019 05:23:25
Copyright @2019 Xilinx Inc. All Rights Reserved.

[DNNC][Warning] layer [InceptionV1_Logits_SpatialSqueeze] (type: Squeeze) is not supported in DPU, deploy it in CPU instead.
[DNNC][Warning] layer [InceptionV1_Logits_Predictions_Softmax] (type: Softmax) is not supported in DPU, deploy it in CPU instead.

DNNC Kernel topology "inception_v1_kernel_graph.jpg" for network "inception_v1"
DNNC kernel list info for network "inception_v1"
                               Kernel ID : Name
                                       0 : inception_v1_0
                                       1 : inception_v1_1

                             Kernel Name : inception_v1_0
--------------------------------------------------------------------------------
                             Kernel Type : DPUKernel
                               Code Size : 0.26MB
                              Param Size : 6.31MB
                           Workload MACs : 2996.75MOPS
                         IO Memory Space : 0.76MB
                              Mean Value : 0, 0, 0,
                              Node Count : 76
                            Tensor Count : 110
                    Input Node(s)(H*W*C)
InceptionV1_InceptionV1_Conv2d_1a_7x7_Conv2D(0) : 224*224*3
                   Output Node(s)(H*W*C)
InceptionV1_Logits_Conv2d_0c_1x1_Conv2D(0) : 1*1*1001


                             Kernel Name : inception_v1_1
--------------------------------------------------------------------------------
                             Kernel Type : CPUKernel
                    Input Node(s)(H*W*C)
       InceptionV1_Logits_SpatialSqueeze : 1*1*1001
                   Output Node(s)(H*W*C)
  InceptionV1_Logits_Predictions_Softmax : 1*1*1001
```

The compilation process outputs two kernels, one to deploy in the DPU, `inception_v1_0.elf`, and another one to implement in the CPU with the DNNDK APIs. The compilation tool `DNNC` also outputs a graph that ilustrates how to interconnect the kernels.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/inception_v1_kernel_graph.jpg)



--------------------------------------------------------------------

- **Programming the application**.

This section is a guide to create an easy program to run the inception_v1 neural network, that was compiled in the host machine, in ZedBoard. The program is created in C/C++, as the DNNDK APIs have a better performance with this language rather than with Python. Äll the necesary functions needed to run the DPU for one image and establish its communication with the CPU will be explained. The actual code can be found at the end of this section. All the include libraries are indicated with the code.

The code for managing the DPU kernels and tasks is programmed in the `main` function. An example of the structure of this fuction can be found in [DNNDK User Guide, page 51](https://www.xilinx.com/support/documentation/sw_manuals/ai_inference/v1_6/ug1327-dnndk-user-guide.pdf).

- `DPUKernel` is a custom datatype to create a pointer for the DPU kernel.
- `DPUTask` is a custom datatype to create a pointer for the DPU task.
- `dpuOpen()` function that attaches and opens the DPU device before the utilization of DPU resources.
- `dpuLoadKernel()` loads a DPU kernel for the specified neural network from hybrid CPU+DPU binary executable into DPU memory space, including Kernel’s DPU instructions, weight and bias. The function has an argument, which is the name of the DPU kernel outputed by the DNNC compiler. In this case the name would be `inception_v1_0`. The API outputs a pointer to the loaded DPU kernel if succesful.
- `dpuCreateTask()` instantiates a DPU task from DPU Kernel and allocates corresponding DPU memory buffer. It takes a pointer to the kernel as a parameter. It is possible to indicate the mode of the task between the normal mode, which is default, profiling mode, that outputs performance information layer by layer, or dump mode, which dumps raw data for the DPU task. This last two modes are only available if the DNNC tool compiled the model in debug mode.
- `dpuDestroyTask()` destroys the DPU task and releases its resources. It takes the pointer of the task as an argument. Returns a 0 on success or negative value in failure.
- `dpuDestroyKernel()` destroys the DPU kernel and releases its resources. Takes as an argument the pointer to the kernel. Retuns a 0 if success.
- `dpuClose()` detaches and closes the DPU device file.

Once the task has been created, a function is created to run image pre-processing, post-processing, DPU non-supported layers and inference.

- **runInception_v1**

It is the void function where the images are prepared for the neural network and the inference is actually ran. This function is going to call several others that are the ones responsible for performing pre-processing, post-processing and execution of the DPU non-suported layers. An argument containing a pointer to the created task is needed by this function.

- `LoadImageNames` is a void function that takes as argument a string with the path, within the target board, where the inference images are stored. It also takes a vector as an argument, which is going to fill up with the names of the images inside the inputed path.

First of all, in the function is important to check if the path is a valid directory path. The function `lstat()` is used for this matter, from the library `sys/stat.h`. This function returns a `stat` structure:

```
struct stat {
    dev_t     st_dev;     /* ID of device containing file */
    ino_t     st_ino;     /* inode number */
    mode_t    st_mode;    /* protection */
    nlink_t   st_nlink;   /* number of hard links */
    uid_t     st_uid;     /* user ID of owner */
    gid_t     st_gid;     /* group ID of owner */
    dev_t     st_rdev;    /* device ID (if special file) */
    off_t     st_size;    /* total size, in bytes */
    blksize_t st_blksize; /* blocksize for file system I/O */
    blkcnt_t  st_blocks;  /* number of 512B blocks allocated */
    time_t    st_atime;   /* time of last access */
    time_t    st_mtime;   /* time of last modification */
    time_t    st_ctime;   /* time of last status change */
};
```

`lstat()` takes a C-format string with the path of a file and a stat structure object as arguments, and writes information of that file in the object. To check if the path is valid, therefore, if it is a directory, the function `S_SDIR()` can be used. This fuction takes the `st_mode` field of the stat object as an argument, returning a zero if the path indicated in the function `lstat()` is a directory. If the fuction returns a negative value, the `LoadImageNames` function should be exited. Otherwise, the directory is valid and the function can continue executing.

Now you can open the directory with the fuction `opendir()` from the library `sys/types.h` and read it, `readdir()`. This last function returns a dirent structure. If this structure is equal to null (nullptr), this means the directory is empty, or that you reached the end of the directory, so you should close the directory stream with `closedir()`. The dirent structure is defined in the `dirent.h` library:

```
struct dirent {
               ino_t          d_ino;       /* Inode number */
               off_t          d_off;       /* Not an offset; see below */
               unsigned short d_reclen;    /* Length of this record */
               unsigned char  d_type;      /* Type of file; not supported
                                              by all filesystem types */
               char           d_name[256]; /* Null-terminated filename */
           };
```

This structure will contain the name of the content of the directory, which in this case are the images we want a list of. The only thing remaining will be to extract this name and add it to a vector that the actual `runInception_v1` function can use.

- `LoadWords()` is a void function used to obtain the name of all the possible labels in the images directory, where there is a .txt file containing this information.

To open the file, an `fstream` object is used. `fstream` is a datatype that represents the file stream generally, and has the capabilities of both ofstream and ifstream, which means it can create files, write information to files, and read information from files. Using this datatype with the `getline()` function, the whole .txt file can be read.

Once the pre-processing is done, we need to start inference on the DPU. Before this, remember that for this model, the softmax layer has to be programed for the CPU, therefore, it is neccessary to know how many channesl are output by the output node of the DPU kernel.

- `dpuGetOutputTensorCannel()` is the function that enables counting this number. It gets the total number of output tensor for the DPU task. It's arguments are a pointer to the DPU task and the output boundary node name. This name was previously obtained when running the DNNC tool. In this case, the name of the node is `InceptionV1_Logits_Conv2d_0c_1x1_Conv2D`.

Once we know the number, create an array of `float` datatype with enough memory allocated.

Finally, to run inference of all the images in your images directory, create a loop where you need to follow this process.

- Load and do the preprocessing of the image.

- Load the preprocessed image into the DPU with the API `dpuSetInputImage2()`. The image can be loaded to the DPU without specifying its mean value. Its arguments are a pointer to the DPU task, the name of the input node and the image itself as a Mat object. The Mat datatype can be used with the opencv library.                      

- Run inference on the DPU. This operation is executed with the API `dpuRunTask()`, and its only argument is a pointer to the DPU task.

- It can be interesting to obtain the execution time in micro-seconds at the DPU. Use the `dpuGetTaskProfile()` API. This function gets the time value after the running of the task. It's only argument is the DPU task pointer.

- Once the task has been run, we need to get the output tensor. This can be done using the API `dpuGetOutputTensorInHWCFP32`, obtaining the result to be used with the CPU in (Height*Width*Channel) format and with a datatype of float32. Its arguments are a pointer to the DPU task, a pointer to the DPU output node name, the start addres of CPU memory block for storing output Tensor's data, the size of the output in bytes and the index of a sinble output tensor for the Node, with a default value of 0. The best way of indicating the CPU memory address block is creating a float pointer to an array with as many cells as channels the output tensor has. The number of channels were previously obtained with the API `dpuGetOutputTensorCannel()`.

- Calculate spatial squeeze layer.

- Calculate the softmax layer in the DPU, as there is no support for it in the DPU. This function should get the output Tensor array obtained in the previous step, including the size of the array and a new pointer to an array where it is possible to retrieve the solution of the layer. In this fuction it is neccesary to operate the softmax fuction, which can be retrieved from the book [Pattern Recognition and Machine Learning, page 2.9, section 4.3.4, ecuation 4.104](https://www.academia.edu/40339604/Pattern_Recognition_And_Machine_Learning_Information_Science_And_Statistics_by_Christopher_M.-Bish). The ecuation itself is the following, considering `y` is the output array with the size of the Tensor chanels, `a` is the data with the tensor information obtained from the DPU, `k` is the current cell number and `j` is the total number of channels.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/ZedBoard_DNNs/GuideImages/Softmax_Ecuation.png)

- Finally, create a function that shows you the top results of the cells









### Network Deployment of DNN pre trained model
This section tends to explain how the creation of a custom application, similar to the ones showed in the previous sections, has to be created and configured in order to be able to be executed in the ZedBoard. All the necessary steps are going to be indicated for both Caffe and Tensorflow frameworks.



#### Caffe model



#### TensorFlow model
A TensorFlow model has a different working flow than a Caffe model. The whole process of creating a custom application with a pre-trained TensorFlow model is now explained.

- **Download a pre-trained model**.

To download a pre-trained model you can use the model zoo repository [here](https://github.com/Xilinx/AI-Model-Zoo/tree/1387830ef9b846255245c1dc063e7c86ac71498e).

--------------------------------------------------------------------------

- **Network compression**. Network compression consists in reducing the size of the DNN model in order to reduce the memory usage needed by the target device when executing inference. The main compression techniques are pruning and quantization, and to execute this techniques it is necessary to use the `DECENT_Q` conda environment that was created in the [Setting up the host](#setting-up-the-howst) section. In any case, previous to the execution of these techniques, it is necessary to prepare the model.

The `DECENT_Q` environment needs to create a series of files to be able to properly execute pruning and quantization. This files would be the `frozen_graph.pb`, the `calibration dataset` and the `Input_fn`.

1. **Freeze the network.**

The `frozen_graph.pb` is a file which contains the pre-trained DNN model but with all its variables converted to constant values. This file is created from the `.pb` file given by the pre-trained model, and a set of checkpoint files, `.ckpt`. In order to handle this conversion, TensorFlow provides a `freeze_graph.py` script which is installed with `DECENT_Q`. To use this tool, you can execute the following commands or copy them into a `.sh` file, in order to execute them all together.

```
$ freeze_graph \
      --input_graph /tmp/inception_v1_inf_graph.pb \
      --input_checkpoint /tmp/checkpoints/model.ckpt-1000 \
      --input_binary true \
      --output_graph /tmp/frozen_graph.pb \
      --output_node_names InceptionV1/Predictions/Reshape_1
```

> NOTE: To see all the options of the freeze tool, execute the `freeze_graph --help` command.

The `input_graph` and `input_checkpoint` fields have to be filled up, respectively, with a `.pb` and a `.ckpt` model, which are the result of training a neural network. In this guide we always use already trained models, so these two files are always given as the starting point of an application.

The `input_binary` field is not explained in the DNNDK User Guide, but it is always set to `True` in the User Guide's examples.

One of the fields that has to be covered in this step is the `--output_node_names`. Later on, we will also be using the filed `--input_node_names`. The input and output nodes are the name list of input and output nodes, comma separated, that indicate the start and end points of quantization. The subgraph between them will be quantized if quantizable. It is recommended to place the input nodes at the last parto of the pre-processing stage, and the output nodes at the beggining of the post-procesing stage, as these two parts might have some operators that aren't quantizable amd cam caise errors. The definition of both these parameters can be obtained in the [DNNDK User Guide, pages 57-58](https://www.xilinx.com/support/documentation/sw_manuals/ai_inference/v1_6/ug1327-dnndk-user-guide.pdf).

In order to check the possible `input` and `output` node names of the model, which they are necessary to include in the `freeze_graph.sh` script, you can estimate them using the following command with your pre trained model.

```
$ decent_q inspect --input_frozen_graph=/tmp/inception_v1_inf_graph.pb
```

The output of this command would give you a name you can use to fill up the `input_node_names` and `output_node_names` that you will need in several of the steps when creating an aplication for a target board.



2. **Calibration dataset and input function**

The calibration dataset can be obtaind as explained at the end of section [Network Deployment of DNNDK host examples](#network-deployment-of-dnndk-host-examples).

The `input_fn` field of the quantization tool should take a `int` object as input, indicating the calibration step number, and should return a dict`(placeholder_name, numpy.Array)` object for each call, which is fed into the model's placeholder nodes when running inference. The shape of numpy.array should be consistent with the placeholders.
The pseudo code example looks like below:

```
$ “my_input_fn.py”
def calib_input(iter):
  “””A function that provides input data for the calibration
  Args:
  iter: A `int` object, indicating the calibration step number
  Returns:
  dict( placeholder_name, numpy.array): a `dict` object, which will be fed
  into the model
  “””
  image = load_image(iter)
  preprocessed_image = do_preprocess(image)
  return {"placeholder_name": preprocessed_images}
```

Calibration is commonly performed with 100 to 1000 images, but this images aren't preprocessed all together. Usually, at the quantization step you can select the number of iterations of caliration. This indicates how many times you run the `calib_input` function when quantizing a model. Often, the functions within the calibration function used to read and preprocess an image are contained in a loop in order to load more than one image at each iteration. The loop would be run as many times as indicated by a user defined variable known as the `calib_batch_size`, which is defined by the user in the `input_fn.py` function.



3. **Quantization**

Now all the files have been prepared to perform quantization. In order to quantize the model, we are going to use the `decent_q.sh` script.

```
decent_q quantize \
  --input_frozen_graph frozen_inception_v1.pb \
  --input_nodes input \
  --input_shapes ?,224,224,3 \
  --output_nodes InceptionV1/Logits/Predictions/Reshape_1 \
  --input_fn inception_v1_input_fn.calib_input \
  --method 1 \
  --gpu 0 \
  --calib_iter 100 \
```

- The `input_frozen_graph` field has to be the output of the freeze operation.
- The `input_nodes` and `output_nodes` fields have to be filled up with the output of the command previously shown when explaining the freeze function, `decent_q inspect`.
- `input_shapes` field specifies the shape of the input nodes, which must be a four dimension shape for each node. The first dimension would be the batch size, which can be set to unknown `?`. By selecting this option, the batch size can be specified in the `input_fn.py` script as previously specified. The two numbers in the middle, `224x224`, indicates the pixel size of the input images, and the last number indicates the amount of layers of the input node. In the examples of section [Network Deployment of DNNDK host examples](#network-deployment-of-dnndk-host-examples), imaes were formated to RGB, therefore there is only 3 layers.
- `input_fn` indicates a script that contains the preprocessing routine of the application, as the DPU model doesn't do this step. The preprocessing operations can be added to a python script `.py`, but when indicating the script in quantization, the extension at the quantize call should be `.calib_input`. Do not change the `.py` extension in the script though.

These are the main fields that have to be covered in order to perfor the quantization operation. There is other optional fields. They are carefully explained at the [DNNDK User Guide, pages 57-59](https://www.xilinx.com/support/documentation/sw_manuals/ai_inference/v1_6/ug1327-dnndk-user-guide.pdf). We now mention some of the most important ones.

- `weight_bit` field indicates the bit width for weight and bias. Default is 8.
- `activation_bit` field indicates the bit width for quantized activation. Default is also 8.
- The `method` field can be set to 0 ro 1, indicating the method of quantization. Zero stands for non-overflow method, to make sure no values are saturated during quantization, but it might get worse results in the case of outliers. One stands for min-diffs method, allowing saturation to get lower quantization difference and higher tolerance to outliers. Usually ends up with narrower ranges than non-overflow.
- `calib_iter` indicates how many times the calibration function is executed. If the batch size in the quantization tool is set to unknown, being this value specified in the `input_fn` script, for each iteration performed, the calibration fuction will preprocess as many images as the batch size indicates. The total of images calibration is done with would therefore be the product between `calib_iter` and `calib_batch_size`.
- `output_dir` is used to specify the directory where the quantization tool saves its output model.
- `gpu`is where you can indicate the gpu's id when using the `decent` environment for this device. If you aren't using gpu, you can set this field to `0`.



4. **Output and evaluation**

Once the quantization is succesfull, two files are generated in the `output_dir`.

- `deploy_model.pb`. Quantized model to later use with the compilation tool.
- `quantized_eval_model.pb`. Enables evaluation of the quantized model.

Once quantization is done, an evaluation of the frozen and quantized model can be performed in order to compare the loss in accuracy. This same evaluation could be done in the case of pruning the model. To evaluate the model, we are going to use the python script provided by the DNNDK v3.1 package , which is now shown. In this case we display the script of the inception example, but the resnet50 example has the same evaluation script. This script could be used for any other tensorflow model.

```python
"""
Inception_v1 Evaluation Script
"""
import os
import argparse
import sys
import tensorflow as tf
from progressbar import ProgressBar
from inception_v1_input_fn import eval_input
from tensorflow.contrib import decent_q

FLAGS = None


def inception_v1_eval(input_graph_def, input_node, output_node):
  """Evaluate classification network graph_def's accuracy, need evaluation dataset"""
  tf.import_graph_def(input_graph_def, name='')

  # Get input tensors
  input_tensor = tf.get_default_graph().get_tensor_by_name(input_node + ':0')
  input_labels = tf.placeholder(tf.float32, shape=[None, FLAGS.class_num])

  # Calculate accuracy
  output = tf.get_default_graph().get_tensor_by_name(output_node + ':0')
  prediction = tf.reshape(output, [FLAGS.batch_size, FLAGS.class_num])
  correct_labels = tf.argmax(input_labels, 1)
  top1_prediction = tf.nn.in_top_k(prediction, correct_labels, k=1)
  top5_prediction = tf.nn.in_top_k(prediction, correct_labels, k=5)
  top1_accuracy = tf.reduce_mean(tf.cast(top1_prediction, 'float'))
  top5_accuracy = tf.reduce_mean(tf.cast(top5_prediction, 'float'))

  # Start evaluation
  print("Start Evaluation for {} Batches...".format(FLAGS.eval_batches))
  with tf.Session() as sess:
    progress = ProgressBar()
    top1_sum_acc = 0
    top5_sum_acc = 0
    for iter in progress(range(0, FLAGS.eval_batches)):
      input_data = eval_input(iter, FLAGS.eval_image_dir, FLAGS.eval_image_list,
                              FLAGS.class_num, FLAGS.batch_size)
      images = input_data['input']
      labels = input_data['labels']
      feed_dict = {input_tensor: images, input_labels: labels}
      top1_acc, top5_acc = sess.run([top1_accuracy, top5_accuracy], feed_dict)
      top1_sum_acc += top1_acc
      top5_sum_acc += top5_acc
  final_top1_acc = top1_sum_acc / FLAGS.eval_batches
  final_top5_acc = top5_sum_acc / FLAGS.eval_batches
  print("Accuracy: Top1: {}, Top5: {}".format(final_top1_acc, final_top5_acc))


def main(unused_argv):
  os.environ["CUDA_VISIBLE_DEVICES"] = FLAGS.gpu
  input_graph_def = tf.Graph().as_graph_def()
  input_graph_def.ParseFromString(
      tf.gfile.FastGFile(FLAGS.input_frozen_graph, "rb").read())
  inception_v1_eval(input_graph_def, FLAGS.input_node, FLAGS.output_node)


if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument(
      '--input_frozen_graph',
      type=str,
      default='frozen_inception_v1.pb',
      help='frozen pb file.')
  par4er.add_argument(
      '--input_node', type=str, default='input', help='input node.')
  parser.add_argument(
      '--output_node',
      type=str,
      default='InceptionV1/Logits/Predictions/Reshape_1',
      help='output node.')
  parser.add_argument(
      '--class_num', type=int, default=1001, help='number of classes.')
  parser.add_argument(
      '--eval_batches',
      type=int,
      default=1000,
      help='number of total batches for evaluation.')
  parser.add_argument(
      '--batch_size', type=int, default=50, help='number of batch size.')
  parser.add_argument(
      '--eval_image_dir',
      type=str,
      default="/home/shengxiao/dataset/imagenet_image/val_resize_256/",
      help='evaluation image directory.')
  parser.add_argument(
      '--eval_image_list',
      type=str,
      default="/home/shengxiao/dataset/imagenet_image/val.txt",
      help='evaluation image list file.')
  parser.add_argument('--gpu', type=str, default='0', help='gpu device id.')
  FLAGS, unparsed = parser.parse_known_args()
  tf.app.run(main=main, argv=[sys.argv[0]] + unparsed)
```

This script also uses a function from the `input_fn.py` file:

```python
from inception_v1_preprocessing import *

def eval_input(iter, eval_image_dir, eval_image_list, class_num, eval_batch_size):
  images = []
  labels = []
  line = open(eval_image_list).readlines()
  for index in range(0, eval_batch_size):
    curline = line[iter * eval_batch_size + index]
    [image_name, label_id] = curline.split(' ')
    image = cv2.imread(eval_image_dir + image_name)
    image = central_crop(image, 224, 224)
    image = mean_image_subtraction(image, MEANS)
    image = normalize(image)
    images.append(image)
    labels.append(int(label_id) + 1)
  lb = preprocessing.LabelBinarizer()
  lb.fit(range(0, class_num))
  labels = lb.transform(labels)
  return {"input": images, "labels": labels}
```

This function is defined in this script because in this script the functions crop and mean_image_subtraction are imported from the preprocessing script.



5. **Dump quantize simulation quantize results**

Enables comparison of the results between CPU/GPU and the DPU. `Decent_q` supports the dump functionality using the previously created `quantize_eval_model.pb` model from quantization.

The dump tool should be executed as follows:

```
$ decent_q dump \
      --input_frozen_graph quantize_results/quantize_eval_model.pb \
      --input_fn dump_input_fn \
      --max_dump_batches 1 \
      --dump_float 0 \
      --output_dir quantize_reuslts \
```

- At the `input_fn` field we should indicate a similar script than the one used in quantization, but in this case using a batch size of 1, in order to be consistent with deployment on the DPU. The results of this tool writen in the `output_dir`. This directory will contain a dump result for each batch of input data.
- `dump_float` is a field that indicates wheter or not to dump unquatized nodes. Zero stands for not dumping this type of node.

For each quantized node, results will be saved in “*...int8.bin*” and “*...int8.txt*” format.

--------------------------------------------------------------------------

- **Network compilation**.

The architecture of the Deep Neural Network Compiler (DNNC) compiler consists of a parser, an optimizer and a code-generator. The front-end parser is responsible for parsing the Caffe/TensorFlow model and generates an intermediate representation (IR) of the input model. The optimizer handles optimizations based on the IR, and the code generator maps the optimized IR to DPU instructions.

The compilation process has two very important steps:

1. **DLet**

This tool is used to parse and extract varios DPU configuration parameters from the DPU Hardware Handoff file, `HWH`, generated by your vivado projet.

The `HWH` file is located in the following directory, considering that the name of the project created previously in this guide is `ZedBoard_DPU_2019_2`.

```
cd /<vivado_project_location>/ZedBoard_DPU_2019_2.srcs/sources_1/bd/design_1/hw_handoff/
```

> NOTE: The *desing_1* folder has the name of the block design the DPU was icluded into. If you have several, make sure you select the correct one.

The file is going to have the same name as the block desing the DPU was included into, `design_1.hwh` in this case. With this file, DLet is able to generate the configuration `.dfc` file needed by the compiler to corretly create the DPU kernel. To generate this file, enter the directory you want your `.dfc` file to be writen to, and execute the following commands in the terminal.

```
dlet -f /<vivado_project_location>/ZedBoard_DPU_2019_2.srcs/sources_1/bd/design_1/hw_handoff/design_1.hwh
```

The `.dfc` file is created a name that contains the date the `.hwh` was created.

> NOTE: The DPU IP block used in the Vivado project has to come from the DPU TRD v3.0 or higher in order to be compatible with the DNNDK v3.1 package.


2. **Compilation**

When compiling a model, there is several parameters that have to be indicated:

- `parser` can be filled up with two options, *caffe* or *tensorflow*. Depending on the model framework, you have to chose one or the otherone. If using a Caffe model, you have to indicate two more fields, `prototxt` and `caffemodel`, where you have to indicate the location of the prototxt and caffemodel files. If using TensorFlow, you have to indicate the `frozen_pb` field, where you should indicate the location of your deploy_model.pb file.
- `dfc` field indicates the path to the configuration file that was created with the `DLet` tool.
- `mode` establishes the compilation model of the DPU, which can be `debug` or `normal`. The debug option enables to run the layers of the model one by one under the scheduling of the N2Cube. With the DExplorer application, users can perform debugging or performance profiling for each layer. Normal mode packages all the layers of the model into one single DPU execution. With this mode, DPU kernel delibers better performance, and it is recommended for the release phase of an application.
- `cpu_arch` indicates the architecture of the target device. The possibilities are `arm32` or `arm64`.
- `output_dir` establishes the output directory of the compiled model.

There are more parameters that can be set, and they are all specified in the [DNNDK User Guide, pages 65-67](https://www.xilinx.com/support/documentation/sw_manuals/ai_inference/v1_6/ug1327-dnndk-user-guide.pdf).

--------------------------------------------------------------------------

- **Programing with APIs**.

In this section the programing model of the DPU is explainded with detail.

1. **DPU Kernel**.

The DPU kernel is created with the DNNC tool, after compiling a frozen graph with a given DPU configuration. This operation transforms the neural network model into an equivalent DPU assembly file, which is then assembled into an ELF object. From the prespective of the runtime application, this file becomes the execution unit for N2Cube ater invoquint the API `dpuLoadKernel()`. N2Cube loads the DPU kernel, including DPU instructions and network parameters into the DPU dedicated memory space, allocating hardware resources. After that, each DPU kernel can be instantiated into several DPU tasks by calling `dpuCreateTask()` to enable multithreaded programming.

2. **DPU Task**.

Each DPU task used is a running entity of the DPU kernel. It has its own memory space so that multithreaded applications can be used to process several tasks in paralell.

3. **DPU Node**.

A DPU node is a basic element of the network. It's associated to an input, output and some parameters. Each node has a unique name and the APIs are able to access their information. There is three tyes of nodes; boundary input or output node and internal node.

- Boundary input node doesn't have a precursor in the kernel topology. It is usually the first node of the kernel, and there could be more than one.
- Boundary output node doesn have a successor.
- The rest of the nodes would be labeled as internal nodes.

After compilation, the DNNC tool gives information about the input and output nodes of each kernel. An example is now displayed.

```
Compiling Network inception_v1
DNNDK      : 3.1
Board Name : ZedBoard
DCF file   : ../../../dcf/ZedBoard.dcf
CPU Arch   : arm32
DNNC Mode  : debug
dnnc version v3.00
DPU Target : v1.4.0
Build Label: Aug  9 2019 05:23:25
Copyright @2019 Xilinx Inc. All Rights Reserved.

[DNNC][Warning] layer [InceptionV1_Logits_SpatialSqueeze] (type: Squeeze) is not supported in DPU, deploy it in CPU instead.
[DNNC][Warning] layer [InceptionV1_Logits_Predictions_Softmax] (type: Softmax) is not supported in DPU, deploy it in CPU instead.

DNNC Kernel topology "inception_v1_kernel_graph.jpg" for network "inception_v1"
DNNC kernel list info for network "inception_v1"
                               Kernel ID : Name
                                       0 : inception_v1_0
                                       1 : inception_v1_1

                             Kernel Name : inception_v1_0
--------------------------------------------------------------------------------
                             Kernel Type : DPUKernel
                               Code Size : 0.26MB
                              Param Size : 6.31MB
                           Workload MACs : 2996.75MOPS
                         IO Memory Space : 0.76MB
                              Mean Value : 0, 0, 0,
                              Node Count : 76
                            Tensor Count : 110
                    Input Node(s)(H*W*C)
InceptionV1_InceptionV1_Conv2d_1a_7x7_Conv2D(0) : 224*224*3
                   Output Node(s)(H*W*C)
InceptionV1_Logits_Conv2d_0c_1x1_Conv2D(0) : 1*1*1001


                             Kernel Name : inception_v1_1
--------------------------------------------------------------------------------
                             Kernel Type : CPUKernel
                    Input Node(s)(H*W*C)
       InceptionV1_Logits_SpatialSqueeze : 1*1*1001
                   Output Node(s)(H*W*C)
  InceptionV1_Logits_Predictions_Softmax : 1*1*1001
```

The kernel `inception_v1_0`, which is a DPU kernel, has as input node the `InceptionV1_InceptionV1_Conv2d_1a_7x7_Conv2D(0)`, and as an output node the `InceptionV1_Logits_Conv2d_0c_1x1_Conv2D(0)`.

When using the API `dpuGetInputTensor()`, the `nodeName` parameter is required to specify the boundary input node. DNNDK will generate an error if a node which is not a boundary input node is indicated in the `nameNode` field. A similar error will happen when using the `dpuGetOutputTensor()` API.

4. **DPU Tensor**.

The DPU tensor is a set of multidimensional data used to store information while running an application. For DPU, memory storage layout for input tensor and output tensor is in the format of HWC (Height*Width*Channel), while a standard image usually has a CHW format (Channel*Height*Width). This is important when inputing or retreiving information from the DPU.

Applications can be created using C/C++ APIs, for which it is necessary to create the pre and post processing routines as well as the main application. In this release though, there is the posibility of using Python APIs as well, what enables reusing the preprocessing routine used during compression and compilation.

When programming for the DPU, is very common to exchange data between the CPU and the DPU. A clear example happens when data is pre-processed in the CPU and fed into the DPU to execute the neural network compatible layers. This communication also happens if any layers of the neural network aren't compatible with the DPU, in which case they have to be executed in the CPU. To handle this type of operations, DNNDK provides a set of APIs to facilitate the eschange of information.

DNNDK APIs to set input tensor for the computation layer or node:
- dpuSetInputTensor()
- dpuSetInputTensorInCHWInt8()
- dpuSetInputTensorInCHWFP32()
- dpuSetInputTensorInHWCInt8()
- dpuSetInputTensorInHWCFP32()

DNNDK APIs to get output tensor from the computation layer or node:
- dpuGetOutputTensor()
- dpuGetOutputTensorInCHWInt8()
- dpuGetOutputTensorInCHWFP32()
- dpuGetOutputTensorInHWCInt8()
- dpuGetOutputTensorInHWCFP32()

DNNDK provides the following APIs to get the start address, size, quantization factor, and shape info for DPU input and output tensor:
- dpuGetTensorAddress()
- dpuGetTensorSize()
- dpuGetTensorScale()
- dpuGetTensorHeight()
- dpuGetTensorWidth()
- dpuGetTensorChannel()

5. **TensorFlow Model**.

This framework enables using very flexible pre-processing routines, with input images in BGR or RGB format. Therefore, the pre-defined APIs in the library `libdputils.so` cannot be used directly when deploying TenorFlow models. This means the users have to implement the pre-processing code themselves.

Although both languages are suported, C++ gives a better performance, so it is recommended to port the final applications to C++.

--------------------------------------------------------------------------

- **DPU Hybrid Compilation**.

Applications developed for the DPU are heterogeneus programs that have code running on the target CPU and code running on the DPU. The code for CPU can be created with C/C++ language and later on be processed by a compiler such as GCC. The neural network, on the other hand, is compiled by DNNC for the DPU. In the final stage of the application, these codes have to be linked togetherby a linker such as GCC, to produce a single hybrid binary executable..

1. **DPU Shared Library**.

In some cases DPU ELF files cannot be linked with the CPU code. One case is when the CPU code is created with the Python APIs. In these cases, after the Caffe or TensorFlow models are compiled to DPU ELF files, the users have to use ARM GCC toolchain to transform them into DPU shared libraries.

For x64 host system, ARM cross toolchain like `aarch64-linux-gnu-gcc for 64-bit` ARM or `arm-linux-gnu-gcc` for 32-bit ARM can be used. For DNNDK evaluation boards, gcc toolchain can be used. The command samples for ResNet50 look as the followings:

```
aarch64-linux-gnu-gcc -fPIC -shared \
    dpu_resnet50_*.elf -o libdpumodelresnet50.so
```

By using the `*`, all the DPU ELF files are covered and wrapped into the `libdpumodelresnet50.so`. This is useful when the DNNC compiler outputs more than one DPU kernel.  Moreover, for each neural network model, each DPU ELF files should be linked in one unique shared library. If there is more than one neural network model in one DNNDK application, users must create as many shared libraries as models are. This libraries should be placed in the same folder of the DNNDK application.



### Model Zoo repository
This section is dedicated to port model-zoo repository pre-trained models to ZedBoard. The coverage of the section includes the optimization process, compilation and application creation. All the models donwloaded from this repository have already been frozen, therefore there is no need to use the DNNDK v3.1 package `freeze` tool. [Here](https://github.com/Xilinx/AI-Model-Zoo) there is a link to the Xilinx model-zoo repository, source of all the models used in this section.



#### TensorFlow: Inception_v3
The first step to create an application for the TensorFlow inception_v4 model is to donwload the pre-trained model [here](https://www.xilinx.com/bin/public/openDownload?filename=tf_inceptionv3_imagenet_299_299_1.1.zip). The name of this model in the repository is `tf_inceptionv3_imagenet_299_299_11.45G_1.1`. This name indicates that the model uses the TensorFlow framework, `tf`, the name of the network itself, `inceptionv4`, the dataset it was trained with, `imagenet`, the size of the images it was trained with, `299x299`, the computation of the model (how many GPOS per image), `11.45G` and the version of Vitis-AI the network was trained for, `v1.1`.

In this application the target device is a ZedBoard, therefore we are using the DNNDK v3.1 rather than Vitis-AI v1.1, which won't be a problem at all.

-----------------------------------------------------------------------------

**Quantization**.

The quantization of the model requires two main steps. First of all, the pre-processing of the calibration images, due to the fact that they are not pre-processed in the frozen graph. To do this task, we create two python scripts, one with the operations that are going to take place, and another one with the definition of the functions.

```python
from inception_v3_preprocessing import *

# calib_image_dir = "../../calibration_data/imagenet_images/"
calib_image_dir = "/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/"
# calib_image_list = "../../calibration_data/imagenet_calib.txt"
calib_image_list = "/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_calib.txt"
calib_batch_size = 1
def calib_input(iter):
  images = []
  line = open(calib_image_list).readlines()
  for index in range(0, calib_batch_size):
    curline = line[iter * calib_batch_size + index]
    calib_image_name = curline.strip()
    source = cv2.imread(calib_image_dir + calib_image_name)
    image = cv2.resize(source, (299, 299))
    image = mean_image_subtraction(image, MEANS)
    image = normalize(image)
    images.append(image)
  return {"input": images}
```

```python
import cv2
from sklearn import preprocessing

_R_MEAN = 0
_G_MEAN = 0
_B_MEAN = 0

MEANS = [_B_MEAN,_G_MEAN,_R_MEAN]

def mean_image_subtraction(image, means):
  B, G, R = cv2.split(image)
  B = B - means[0]
  G = G - means[1]
  R = R - means[2]
  image = cv2.merge([R, G, B])
  return image

def central_crop(image, crop_height, crop_width):
  image_height = image.shape[0]
  image_width = image.shape[1]

  offset_height = (image_height - crop_height) // 2
  offset_width = (image_width - crop_width) // 2
/* Initialize and self test the private timer of Cortex-A9 */
    TMRConfigPtr = XScuTimer_LookupConfig(TIMER_DEVICE_ID);
    XScuTimer_CfgInitialize(&Timer, TMRConfigPtr,TMRConfigPtr->BaseAddr);
    XScuTimer_SelfTest(&Timer);
  return image[offset_height:offset_height + crop_height, offset_width:
               offset_width + crop_width]

def normalize(image):
  image=image/256.0
  image=image-0.5
  image=image*2
  return image
```

For this pre-processing task the images are going to be resized with the `cv2.resize` function from `OpenCV`. This operation makes sure all input images are `299x299` pixels. After this operation, mean substraction and normalization is applied to convert the images to `RGB` format and to make sure all the image layer values are in the 0 to 1 range.

Once the pre-processing script is ready, a quantization script is going to be created, `decent_q.sh`. It is important to make sure the input and ouput node names are correctly indicated. To check these names, enter the inception_v4 directory downloaded from the model-zoo repository, enter the float folder and execute the following command.

```
cd float

decent_q inspect --input_frozen_graph inception_v3.pb
```

One possibility for both the input and the output node is found.

```
Found 1 possible inputs: (name=input, type=float(1), shape=[?,299,299,3])
Found 1 possible outputs: (name=InceptionV3/Predictions/Reshape_1, op=Reshape)
```

With this information, create the quantization script, making sure you input the correct image sizes, node names and frozen graph input.

```
decent_q quantize \
  --input_frozen_graph ./float/inception_v3.pb \
  --input_nodes input \
  --input_shapes ?,299,299,3 \
  --output_nodes InceptionV3/Predictions/Reshape_1 \
  --input_fn inception_v3_input_fn.calib_input \
  --method 1 \
  --gpu 0 \
  --calib_iter 100 \
```

Run the quantization script, `sh decent_q.sh`, which should print this output if properly executed.

```
INFO: Checking Float Graph...
INFO: Float Graph Check Done.
INFO: Calibrating for 100 iterations...
100% (100 of 100) |######################| Elapsed Time: 0:01:21 Time:  0:01:21
INFO: Calibration Done.
INFO: Generating Deploy Model...
[DEPLOY WARNING] Node InceptionV3/Predictions/Reshape_1(Type: Reshape) is not quantized and cannot be deployed to DPU,because it has unquantized input node: InceptionV3/Predictions/Softmax. Please deploy it on CPU.
INFO: Deploy Model Generated.
********************* Quantization Summary *********************      
INFO: Output:       
  quantize_eval_model: ./quantize_results/quantize_eval_model.pb       
  deploy_model: ./quantize_results/deploy_model.pb
```

Once the quantization model has been correctly created, we are going to evaluate both the frozen and quantized models and compare the loss in accuracy. To do this we use the evaluation script from section [TensorFlow model](#tensorflow-model), subsection 4, Output and Evaluation. Copy the code to a python script in your inception_v4 model directory, and make sure the input_fn.py script call within the code has the correct name, which in this case should be `inception_v3_input_fn.py`, rather than `inception_v1_input_fn.py`. Now, add to the beggining of your `inception_v3_input_fn.py` the following code needed for the evaluation.

```python
from inception_v3_preprocessing import *

def eval_input(iter, eval_image_dir, eval_image_list, class_num, eval_batch_size):
  images = []
  labels = []
  line = open(eval_image_list).readlines()
  for index in range(0, eval_batch_size):
    curline = line[iter * eval_batch_size + index]
    [image_name, label_id] = curline.split(' ')
    image = cv2.imread(eval_image_dir + image_name)
    image = cv2.resize(image, (299, 299))
    image = mean_image_subtraction(image, MEANS)
    image = normalize(image)
    images.append(image)
    labels.append(int(label_id) + 1)
  lb = preprocessing.LabelBinarizer()
  lb.fit(range(0, class_num))
  labels = lb.transform(labels)
  return {"input": images, "labels": labels}

# calib_image_dir = "../../calibration_data/imagenet_images/"
...

```

You are now ready to call the evaluation of the frozen graph with the following script.

```
#!/bin/sh

set -e

# Please set your imagenet validation dataset path here,
IMAGE_DIR=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/
IMAGE_LIST=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/val.txt

# Please set your batch size settings here, #IMAGES = VAL_BATCHES * BATCH_SIZE
# Commonly there are 5w image in total for imagenet validation dataset
EVAL_BATCHES=10		#1000
BATCH_SIZE=50

python inception_v3_eval.py \
  --input_frozen_graph float/inception_v3.pb \
  --input_node input \
  --output_node InceptionV3/Predictions/Reshape_1 \
  --eval_batches $EVAL_BATCHES \
  --batch_size $BATCH_SIZE \
  --eval_image_dir $IMAGE_DIR \
  --eval_image_list $IMAGE_LIST \
  --gpu 0
```

You can copy the avobe code and save it wiht the extension `.sh` and run it with the command `sh <name>.sh` with the `decent` environment activated. The result should be the following.

```
Start Evaluation for 10 Batches...
100% (10 of 10) |########################| Elapsed Time: 0:00:30 Time:  0:00:30
Accuracy: Top1: 0.7519999980926514, Top5: 0.9380000054836273
```

Now, repeat the same proccess -for the quantization model.

```
#!/bin/sh

set -e

# Please set your imagenet validation dataset path here,
IMAGE_DIR=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/
IMAGE_LIST=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/val.txt

# Please set your batch size settings here, #IMAGES = VAL_BATCHES * BATCH_SIZE
# Commonly there are 5w image in total for imagenet validation dataset
EVAL_BATCHES=10		#1000
BATCH_SIZE=50

python inception_v3_eval.py \
  --input_frozen_graph quantize_results/quantize_eval_model.pb \
  --input_node input \
  --output_node InceptionV3/Predictions/Reshape_1 \
  --eval_batches $EVAL_BATCHES \
  --batch_size $BATCH_SIZE \
  --eval_image_dir $IMAGE_DIR \
  --eval_image_list $IMAGE_LIST \
  --gpu 0
```

The result of the evalutaion should be similar to this one.

```
Start Evaluation for 10 Batches...
100% (10 of 10) |########################| Elapsed Time: 0:01:13 Time:  0:01:13
Accuracy: Top1: 0.7440000057220459, Top5: 0.9340000033378602
```

|Accuracy|Frozen Graph      |Quantized Graph   |
|--------|------------------|------------------|
|Top1    |0.7519999980926514|0.7440000057220459|
|Top5    |0.9380000054836273|0.9340000033378602|

-----------------------------------------------------------------------------

**Compilation**.

The compilation process is performed with the DNNC tool, for which we create the following script.

```
##!/usr/bin/env bash

net="inception_v3"
CPU_ARCH="arm32"
DNNC_MODE="debug"
dnndk_board="ZedBoard"
dnndk_dcf="ZedBoard.dcf"

echo "Compiling Network ${net}"

# Work space directory
work_dir=$(pwd)

# Path of tensorflow quantization model
model_dir=${work_dir}/quantize_results
# Output directory
output_dir="dnnc_output"

tf_model=${model_dir}/deploy_model.pb

DNNC=dnnc

# Get DNNDK config info
if [ ! -f /etc/dnndk.conf ]; then
    echo "Error: Cannot find /etc/dnndk.conf"
    exit 1
else
    tmp=$(grep "DNNDK_VERSION=" /etc/dnndk.conf)
    dnndk_version=${tmp#DNNDK_VERSION=}
    dnndk_version=${dnndk_version#v}
    echo "DNNDK      : $dnndk_version"
    echo "Board Name : $dnndk_board"
    echo "DCF file   : $dnndk_dcf"
fi

if [ ! -d "$model_dir" ]; then
    echo "Can not found directory of $model_dir"
    exit 1
fi

[ -d "$output_dir" ] || mkdir "$output_dir"

echo "CPU Arch   : $CPU_ARCH"
echo "DNNC Mode  : $DNNC_MODE"
echo "$(dnnc --version)"
$DNNC   --parser=tensorflow                         \
       --frozen_pb=${tf_model}                     \
       --output_dir=${output_dir}                  \
       --dcf=${dnndk_dcf}                          \
       --mode=${DNNC_MODE}                         \
       --cpu_arch=${CPU_ARCH}                      \
       --net_name=${net}
```

When creating a ZedBoard application it is important to make sure the CPU Arch selected is `arm32`, otherwise the DPU model won't work. It is also important to specify where is your board `.dcf` file located. If you are using the Petalinux Xilinx image for ZedBoard that can be donwloaded [here](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge), you'll find this file in the `<dnndk_package_v3.1_directory>/host_x86/dcf/ZedBoard.dcf`. If you have a custom project, you can generate the `.dcf` file with the `DLet` tool explained in section [TensorFlow model](#tensorflow-model), subsection `Network Compilation >> 1. DLet`. The output of the compilation tool should be the following:

```
Compiling Network inception_v3
DNNDK      : 3.1
Board Name : ZedBoard
DCF file   : ZedBoard.dcf
CPU Arch   : arm32
DNNC Mode  : debug
dnnc version v3.00
DPU Target : v1.4.0
Build Label: Aug  9 2019 05:23:25
Copyright @2019 Xilinx Inc. All Rights Reserved.

[DNNC][Warning] layer [InceptionV3_Logits_SpatialSqueeze] (type: Squeeze) is not supported in DPU, deploy it in CPU instead.
[DNNC][Warning] layer [InceptionV3_Predictions_Softmax] (type: Softmax) is not supported in DPU, deploy it in CPU instead.

DNNC Kernel topology "inception_v3_kernel_graph.jpg" for network "inception_v3"
DNNC kernel list info for network "inception_v3"
                               Kernel ID : Name
                                       0 : inception_v3_0
                                       1 : inception_v3_1

                             Kernel Name : inception_v3_0
--------------------------------------------------------------------------------
                             Kernel Type : DPUKernel
                               Code Size : 0.60MB
                              Param Size : 22.72MB
                           Workload MACs : 11426.44MOPS
                         IO Memory Space : 1.67MB
                              Mean Value : 0, 0, 0,
                              Node Count : 121
                            Tensor Count : 131
                    Input Node(s)(H*W*C)
InceptionV3_InceptionV3_Conv2d_1a_3x3_Conv2D(0) : 299*299*3
                   Output Node(s)(H*W*C)
InceptionV3_Logits_Conv2d_1c_1x1_Conv2D(0) : 1*1*1001


                             Kernel Name : inception_v3_1
--------------------------------------------------------------------------------
                             Kernel Type : CPUKernel
                    Input Node(s)(H*W*C)
       InceptionV3_Logits_SpatialSqueeze : 1*1*1001
                   Output Node(s)(H*W*C)
         InceptionV3_Predictions_Softmax : 1*1*1001
```

With this output we now know the name of the input and output boundary nodes of the DPU (`InceptionV3_InceptionV3_Conv2d_1a_3x3_Conv2D` and `InceptionV3_Logits_Conv2d_1c_1x1_Conv2D` respecively), which we need to comunicate the ZedBoard's CPU with the DPU, the name of the DPU kernel(`inception_v3_0`) and the layers that are not supported by the DPU which have to be included in the CPU kernel (`softmax layer`).

-------------------------------------------------------------------------------

**Programming the application**.


1. Timer to measure DPU and CPU processing time.

The timers of both Cortex-A9 processors are clocked at 1/2 the CPU frequency `CPU_3x2x`. Both processors have each one 32-bit timer, and they also share a 64-bit one.

The equation to select the prescaler of all the processor timers is the following:

`((PRESCALER_value + 1)*(Load_value + 1))/PERIPHCLK`

The equation gives the interval value for a given prescaler, being PERIPHCLK the CPU clock and Load_value the value you have to load into the clock register in order to stablish the required timing.

If CPU clock has been set to 6:2:1, the frequency is 400 MHz, while if the CPU is set to 4:2:1, the frequency is 300 MHz.

This means that `PERIPHCLK = 200 MHz` in the case of the Vivado project presented in this guide. For this application, we are going to create a timer that counts up to 1 second, whith as much precission as possible, as the time we want to count shouldn't ever surpass half a second.

We are therefore going to use the Global timer, as it is 64-bit. Withoug a prescaler, the maximum time we can count is calculated as follows:

`max_time_no_prescaler = ((0 + 1)*(2^32 + 1))/200000000 = 21.47 sec.`

This means that we can set the prescaler to 0 as we can count more than enough time. Anyways, the DPU has a timer with a precision of one microsecond to measure the execution time of the layers ran by the DPU, therefore, the CPU timer is going to be set to the same precission. We want to know the prescale value needed when so that each time the counter is incremented, the time passed is `counted_time = 1 us`.

```
counted_time = ((Prescaler + 1)*(Load_value + 1))/PERIPHCLK

Prescaler = [(counted_time*PERIPHCLK)/(Load_value + 1)] - 1

Prescaler = [( 1us * 200MHz)/(0 + 1)] - 1 = 199
```

If we set a prescaler equal to 199, each time the timer counter is decreased, one us has passed.

The timer is going to be handled with the [xscutimer.h](https://xilinx.github.io/embeddedsw.github.io/scutimer/doc/html/api/xscutimer_8h.html) library. There is several datatypes and functions that are necessary to use this library, which are now detailed.

- **XScuTimer**: it is a driver instance data. It is necessary by the user to allocate a variable of this type for every timer device in the system. The API functions of the variable have a pointer of this variable as an argument. The variable can be declared with the `static` keyword asure the memory space allocated for the variable lasts the lifetime of the program.

- **XScuTimer_Config**: struct datatype that contains information of the timer device. The device unique ID, stored as `u16` and its BaseAddr, stored as `u32`.

-**XScuTimer_LookupConfig(u16 DeviceID)**: Looks up the device configuration based on the unique device ID. The function returns a pointer to the configuration table entry corresponding to the given device ID, or NULL if no match is found.

- **XScuTimer_CfgInitialize(XScuTimer *InstancePtr, XScuTimer_Config *ConfigPtr, u32 EffectiveAddress)**: initialices a timer driver or instance. This function has to be called before the driver is called by other functions. The first parameter is a pointer to a `XScuTimer` object, the second a pointer to the configuration structure and the last one the address of the timer, which is a part of the previous structure. Returns "XST_SUCCESS" if initialization was successful or "XST_DEVICE_IS_STARTED" if the device has already been started.

- **XScuTimer_SelfTest(XScuTimer *InstancePtr)**: Runs a self test on the timer. This test clears the timer enable bit in the control register, writes to the timer load register and verifies the value read back matches the value written and restores the control register and the timer load register. It takes in a pointer to a XScuTimer object as an argument and returns a "XST_SUCCESS" if the test was successful or "XST_FAILURE" if it wasn't.

- **XScuTimer_SetPrescaler(XScuTimer *InstancePtr, u8 PrescalerValue)**: Function that sets the 8-bit prescaler to the timer control register. It's arguments are an instance to the a XScuTimer instance and the prescaler value.

- **XScuTimer_LoadTimer(InstancePtr, Value)**: Write to the timer load register. This also updates the timer counter register with the new value. In fact, if manually programed, unless it is neccesary to use the autoreload mode, it is not neccessary to use the load register, and the starting value can directly be loaded to the counter register. Takes as arguments a pointer to the XScuTimer instance and the value that is going to be loaded, typically in hexadecimal format (TIMER_LOAD_VALUE in the example code).

- **XScuTimer_Start**: starts the timer and has no return value.

- **XScuTimer_Stop**: stops the timer and has no return value.

- **XScuTimer_GetCounterValue(XScuTimer *InstancePtr)**: Returns the current timer counter register value, taking as an argument an instance of `XScuTimer`.

An example code is shown now, stablishing a timer for which each counter decrement is 1 us.


```c++
#include xscutimer.h

/* Timer */
#define TIMER_LOAD_VALUE    "0xFFFFFFFF"
#define TIMER_DEVICE_ID		XPAR_XSCUTIMER_0_DEVICE_ID

static XScuTimer Timer;



void timer_manager(int mode, unsigned long &time_stop) {

  switch (mode) {
    case 0 :  //timer start
      //set prescaler if needed here
      XScuTimer_LoadTimer(&Timer, TIMER_LOAD_VALUE);
      XScuTimer_Start(&Timer);
      break;
    case 1 :
      XScuTimer_Stop(&Timer);
      time_stop = XScuTimer_GetConunterValue(&Timer);
      break;
  }
}

counted_time(unsigned long &time_stop, uint8_t &prescaler) {
  unsigned long time_start = 0xFFFFFFFF;
  unsigned long time_value = time_start - time_stop + 1;
  cout << "\nInference execution time = " << time_value << " us".

}



int main(void) {
  XScuTimer_Config *TMRconfigPtr;
  uint8_t prescaler = 199;

  /* Initialize and self test the private timer of Cortex-A9 */
  TMRConfigPtr = XScuTimer_LookupConfig(TIMER_DEVICE_ID);
  XScuTimer_CfgInitialize(&Timer, TMRConfigPtr,TMRConfigPtr->BaseAddr);
  XScuTimer_SelfTest(&Timer);
  XScuTimer_SetPrescaler(&Timer, prescaler);

  unsigned long stop_value;
  timer_manager(0, stop_value); // start timer
  timer_manager(1, stop_value); // stop timer
  counted_time(stop_value, prescaler);

}
```


-------------------------------------------------------------------------------

**Run the application in the ZedBoard**.

The first step is to copy the application directory to the ZedBoard. Enter the directory that contains the folder with the ZedBoard application and open a terminal. Execute the following commands.

```
sudo scp -r ./ZedBoard_Inception_v3 root@192.168.0.21:~/xilinx-dnndk-v3.1/ZedBoard/samples
```







#### TensorFlow: Mobilenet_v1
The first step to create an application for the TensorFlow inception_v4 model is to donwload the pre-trained model [here](https://www.xilinx.com/bin/public/openDownload?filename=tf_mobilenetv1_1.0_imagenet_224_224_1.1.zip). The name of this model in the repository is `tf_mobilenetv1_1.0_imagenet_224_224_1.14G_1.1`. This name indicates that the model uses the TensorFlow framework, `tf`, the name of the network itself, `mobilenetv1_1.0`, the dataset it was trained with, `imagenet`, the size of the images it was trained with, `224x224`, the computation of the model (how many GPOS per image), `1.14G` and the version of Vitis-AI the network was trained for, `v1.1`.

In this application the target device is a ZedBoard, therefore we are using the DNNDK v3.1 rather than Vitis-AI v1.1, which won't be a problem at all.

-----------------------------------------------------------------------------

**Quantization**.

The quantization of the model requires two main steps. First of all, the pre-processing of the calibration images, due to the fact that they are not pre-processed in the frozen graph. To do this task, we create two python scripts, one with the operations that are going to take place, and another one with the definition of the functions.

```python
from mobilenet_v1_preprocessing import *

# calib_image_dir = "../../calibration_data/imagenet_images/"
calib_image_dir = "/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/"
# calib_image_list = "../../calibration_data/imagenet_calib.txt"
calib_image_list = "/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_calib.txt"
calib_batch_size = 1
def calib_input(iter):
  images = []
  line = open(calib_image_list).readlines()
  for index in range(0, calib_batch_size):
    curline = line[iter * calib_batch_size + index]
    calib_image_name = curline.strip()
    source = cv2.imread(calib_image_dir + calib_image_name)
    image = cv2.resize(source, (224, 224))
    image = mean_image_subtraction(image, MEANS)
    image = normalize(image)
    images.append(image)
  return {"input": images}
```

```python
import cv2
from sklearn import preprocessing

_R_MEAN = 0
_G_MEAN = 0
_B_MEAN = 0

MEANS = [_B_MEAN,_G_MEAN,_R_MEAN]

def mean_image_subtraction(image, means):
  B, G, R = cv2.split(image)
  B = B - means[0]
  G = G - means[1]
  R = R - means[2]
  image = cv2.merge([R, G, B])
  return image

def central_crop(image, crop_height, crop_width):
  image_height = image.shape[0]
  image_width = image.shape[1]

  offset_height = (image_height - crop_height) // 2
  offset_width = (image_width - crop_width) // 2

  return image[offset_height:offset_height + crop_height, offset_width:
               offset_width + crop_width]

def normalize(image):
  image=image/256.0
  image=image-0.5
  image=image*2
  return image
```

For this pre-processing task the images are going to be resized with the `cv2.resize` function from `OpenCV`. This operation makes sure all input images are `224x224` pixels. After this operation, mean substraction and normalization is applied to convert the images to `RGB` format and to make sure all the image layer values are in the 0 to 1 range.

Once the pre-processing script is ready, a quantization script is going to be created, `decent_q.sh`. It is important to make sure the input and ouput node names are correctly indicated. To check these names, enter the inception_v4 directory downloaded from the model-zoo repository, enter the float folder and execute the following command.

```
cd float

decent_q inspect --input_frozen_graph mobilenet_v1_1.0_224.pb
```

One possibility for both the input and the output node is found.

```
Found 1 possible inputs: (name=input, type=float(1), shape=[?,224,224,3])
Found 1 possible outputs: (name=MobilenetV1/Predictions/Reshape_1, op=Reshape)
```

With this information, create the quantization script, making sure you input the correct image sizes, node names and frozen graph input.

```
decent_q quantize \
  --input_frozen_graph ./float/mobilenet_v1_1.0_224.pb \
  --input_nodes input \
  --input_shapes ?,224,224,3 \
  --output_nodes MobilenetV1/Predictions/Reshape_1 \
  --input_fn mobilenet_v1_input_fn.calib_input \
  --method 1 \
  --gpu 0 \
  --calib_iter 100 \
```

Run the quantization script, `sh decent_q.sh`, which should print this output if properly executed.

```
INFO: Checking Float Graph...
INFO: Float Graph Check Done.
INFO: Calibrating for 100 iterations...
100% (100 of 100) |###########################################| Elapsed Time: 0:00:43 Time:  0:00:43
INFO: Calibration Done.
INFO: Generating Deploy Model...
[DEPLOY WARNING] Node MobilenetV1/Predictions/Reshape_1(Type: Reshape) is not quantized and cannot be deployed to DPU,because it has unquantized input node: MobilenetV1/Predictions/Softmax. Please deploy it on CPU.
INFO: Deploy Model Generated.
********************* Quantization Summary *********************      
INFO: Output:       
  quantize_eval_model: ./quantize_results/quantize_eval_model.pb       
  deploy_model: ./quantize_results/deploy_model.pb
```

Once the quantization model has been correctly created, we are going to evaluate both the frozen and quantized models and compare the loss in accuracy. To do this we use the evaluation script from section [TensorFlow model](#tensorflow-model), subsection 4, Output and Evaluation. Copy the code to a python script in your inception_v4 model directory, and make sure the input_fn.py script call within the code has the correct name, which in this case should be `mobilenet_v1_input_fn.py`, rather than `inception_v1_input_fn.py`. Now, add to the beggining of your `mobilenet_v1_input_fn.py` the following code needed for the evaluation.

```python
from mobilenet_v1_preprocessing import *

def eval_input(iter, eval_image_dir, eval_image_list, class_num, eval_batch_size):
  images = []
  labels = []
  line = open(eval_image_list).readlines()
  for index in range(0, eval_batch_size):
    curline = line[iter * eval_batch_size + index]
    [image_name, label_id] = curline.split(' ')
    image = cv2.imread(eval_image_dir + image_name)
    image = cv2.resize(image, (224, 224))
    image = mean_image_subtraction(image, MEANS)
    image = normalize(image)
    images.append(image)
    labels.append(int(label_id) + 1)
  lb = preprocessing.LabelBinarizer()
  lb.fit(range(0, class_num))
  labels = lb.transform(labels)
  return {"input": images, "labels": labels}

# calib_image_dir = "../../calibration_data/imagenet_images/"
...

```

You are now ready to call the evaluation of the frozen graph with the following script.

```
#!/bin/sh

set -e

# Please set your imagenet validation dataset path here,
IMAGE_DIR=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/
IMAGE_LIST=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/val.txt

# Please set your batch size settings here, #IMAGES = VAL_BATCHES * BATCH_SIZE
# Commonly there are 5w image in total for imagenet validation dataset
EVAL_BATCHES=10		#1000
BATCH_SIZE=50

python mobilenet_v1_eval.py \
  --input_frozen_graph float/mobilenet_v1_1.0_224.pb \
  --input_node input \
  --output_node MobilenetV1/Predictions/Reshape_1 \
  --eval_batches $EVAL_BATCHES \
  --batch_size $BATCH_SIZE \
  --eval_image_dir $IMAGE_DIR \
  --eval_image_list $IMAGE_LIST \
  --gpu 0
```

You can copy the avobe code and save it wiht the extension `.sh` and run it with the command `sh <name>.sh` with the `decent` environment activated. The result should be the following.

```
Start Evaluation for 10 Batches...
100% (10 of 10) |#############################################| Elapsed Time: 0:00:24 Time:  0:00:24
Accuracy: Top1: 0.642000013589859, Top5: 0.8519999861717225
```

Now, repeat the same proccess -for the quantization model.

```
#!/bin/sh

set -e

# Please set your imagenet validation dataset path here,
IMAGE_DIR=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/
IMAGE_LIST=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/val.txt

# Please set your batch size settings here, #IMAGES = VAL_BATCHES * BATCH_SIZE
# Commonly there are 5w image in total for imagenet validation dataset
EVAL_BATCHES=10		#1000
BATCH_SIZE=50

python mobilenet_v1_eval.py \
  --input_frozen_graph quantize_results/quantize_eval_model.pb \
  --input_node input \
  --output_node MobilenetV1/Predictions/Reshape_1 \
  --eval_batches $EVAL_BATCHES \
  --batch_size $BATCH_SIZE \
  --eval_image_dir $IMAGE_DIR \
  --eval_image_list $IMAGE_LIST \
  --gpu 0
```

The result of the evalutaion should be similar to this one.

```
Start Evaluation for 10 Batches...
100% (10 of 10) |#############################################| Elapsed Time: 0:00:38 Time:  0:00:38
Accuracy: Top1: 0.013999999687075614, Top5: 0.06199999935925007
```

|Accuracy|Frozen Graph     |Quantized Graph    |
|--------|-----------------|-------------------|
|Top1    |0.642000013589859|0.01399999968707561|
|Top5    |0.851999986171723|0.06199999935925007|



There is a problem with the image preprocesing that has produced a great decrease in accuracy.

-----------------------------------------------------------------------------

**Compilation**.

The compilation process is performed with the DNNC tool, for which we create the following script.

```
##!/usr/bin/env bash

net="mobilenet_v1"
CPU_ARCH="arm32"
DNNC_MODE="debug"
dnndk_board="ZedBoard"
dnndk_dcf="ZedBoard.dcf"

echo "Compiling Network ${net}"

# Work space directory
work_dir=$(pwd)

# Path of tensorflow quantization model
model_dir=${work_dir}/quantize_results
# Output directory
output_dir="dnnc_output"

tf_model=${model_dir}/deploy_model.pb

DNNC=dnnc

# Get DNNDK config info
if [ ! -f /etc/dnndk.conf ]; then
    echo "Error: Cannot find /etc/dnndk.conf"
    exit 1
else
    tmp=$(grep "DNNDK_VERSION=" /etc/dnndk.conf)
    dnndk_version=${tmp#DNNDK_VERSION=}
    dnndk_version=${dnndk_version#v}
    echo "DNNDK      : $dnndk_version"
    echo "Board Name : $dnndk_board"
    echo "DCF file   : $dnndk_dcf"
fi

if [ ! -d "$model_dir" ]; then
    echo "Can not found directory of $model_dir"
    exit 1
fi

[ -d "$output_dir" ] || mkdir "$output_dir"

echo "CPU Arch   : $CPU_ARCH"
echo "DNNC Mode  : $DNNC_MODE"
echo "$(dnnc --version)"
$DNNC   --parser=tensorflow                         \
       --frozen_pb=${tf_model}                     \
       --output_dir=${output_dir}                  \
       --dcf=${dnndk_dcf}                          \
       --mode=${DNNC_MODE}                         \
       --cpu_arch=${CPU_ARCH}                      \
       --net_name=${net}
```

When creating a ZedBoard application it is important to make sure the CPU Arch selected is `arm32`, otherwise the DPU model won't work. It is also important to specify where is your board `.dcf` file located. If you are using the Petalinux Xilinx image for ZedBoard that can be donwloaded [here](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge), you'll find this file in the `<dnndk_package_v3.1_directory>/host_x86/dcf/ZedBoard.dcf`. If you have a custom project, you can generate the `.dcf` file with the `DLet` tool explained in section [TensorFlow model](#tensorflow-model), subsection `Network Compilation >> 1. DLet`. The output of the compilation tool when using the Xilinx Petalinux image is the following, as this image doesn't have the `depthWiseConv` layer enabled. To check if your DPU has this layer enabled, you can also run the command `dexplorer -w` in your board.

```
Compiling Network mobilenet_v1
DNNDK      : 3.1
Board Name : ZedBoard
DCF file   : ../dcf/ZedBoard.dcf
CPU Arch   : arm32
DNNC Mode  : debug
dnnc version v3.00
DPU Target : v1.4.0
Build Label: Aug  9 2019 05:23:25
Copyright @2019 Xilinx Inc. All Rights Reserved.

[DNNC][Error] layer [MobilenetV1_MobilenetV1_Conv2d_1_depthwise_depthwise] (type: DepthWiseConv) is not supported for current DPU configuration file.
```
