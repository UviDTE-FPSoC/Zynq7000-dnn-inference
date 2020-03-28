Neural Network Inference with SoC devices
=========================================
This guide shows the process to perform the inference of a neural network using a SoC device. In this very guide, the inference itself will be done with the aid of a library from Xilinx called Vitis-AI. The installation and configuration process of the software will be displayed in this guide as well.

Table of contents:
- [Vitis-AI Installation](#vitis---AI-Installation)
   - [Install docker](#install-docker)
   - [Ensure the Linux user is in the group docker](#ensure-the-linux-user-is-in-the-group-docker)
   - [Load and run docker container](#load-and-run-docker-container)


Vitis-AI Installation
---------------------
In order to download Vitis AI, [click here](https://github.com/Xilinx/Vitis-AI). The link will direct you to a github repository from Xilinx which provides all the information of how to correctly install the package.


Vitis AI is Xilinx’s development stack for AI inference on Xilinx hardware platforms, including both edge devices and Alveo cards. It consists of optimized IP, tools, libraries, models, and example designs. It is designed with high efficiency and ease of use in mind, unleashing the full potential of AI acceleration on Xilinx FPGA and ACAP.

In order to install this library, you need to perform a series of steps.

- Clone the Vitis AI repository to obtain the examples, reference code and scripts.
```
git clone https://github.com/Xilinx/Vitis-AI
cd Vitis-AI
```

- [Install docker](https://github.com/Xilinx/Vitis-AI/blob/master/doc/install_docker/README.md)
- [Ensure the linux user is in the group docker](https://docs.docker.com/install/linux/linux-postinstall/)
- [Load and run docker container](https://github.com/Xilinx/Vitis-AI/blob/master/doc/install_docker/load_run_docker.md)
- Get started with examples
  - [ZU+ MPSoC/Zynq-7000](https://github.com/Xilinx/Vitis-AI/blob/master/mpsoc/README.md)



### Ensure the linux user is in the group docker
This step is highlighted as some instructions might from the provided link might result into some confusion.

First of all, I recommend not creating an Unix Group called docker if you don't know what you are doing, as this could lead to some dangers highlihgted in this [link](https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface). Not creating this group only means that all `docker` commands can only be accessed using the `sudo` command.

Configuring docker to start on boot, if you run a Ubuntu 16.04 or higher, is as easy as typing in the following command.
```
sudo systemctl enable docker
```

To disable this option:
```
sudo systemctl disable docker
```



#### Configure default logging driver
Configuring this driver is recommended to avoid the log file from expanding in size over time. To do this, you have to access the `/etc/docker/` file in your machine, and set the logging driver to the `syslog` file:

```json
{
  "log-driver": "syslog"
}
```
