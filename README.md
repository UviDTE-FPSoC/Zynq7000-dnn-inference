Neural Network Inference with SoC devices
=========================================

This guide shows the process to perform the inference of a neural network using a SoC device. In this very guide, the inference itself will be done with the aid of a library from Xilinx called Vitis-AI. The installation and configuration process of the software will be displayed in this guide as well, considering the difficulties that might appear during the proccess. Remark that all the software we are using will be mounted on an embedded operating system, PetaLinux in our case, in order to work with the SoC device.
The installation and configuration of all the software needed to use PetaLinux is given this other [repository](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux/2019.2). From this point on, notice that the configuration of all the tools is done in order to meet compatibility with the installation of PetaLinux.

Table of contents:
- [Vitis AI Installation](#vitis-AI-Installation)
   - [Install docker](#install-docker)
      - [Set up the repository](#set-up-the-repository)
      - [Install docker engine community](#install-docker-engine-community)
   - [Ensure the Linux user is in the group docker](#ensure-the-linux-user-is-in-the-group-docker)
      - [Configure docker to start on boot](#configure-docker-to-start-on-boot)
   - [Clone the Vitis AI repository](#clone-the-vitis-ai-repository)
   - [Load and run docker container](#load-and-run-docker-container)
   - [Install Vitis AI Runtime](#install-vitis-ai-runtime)
      - [Prepare the host](#prepare-the-host)
      - [Prepare the board](#prepare-the-board)
   - [Install the DNNDK](#install-the-dnndk)
      - [Install on the computer](#install-on-the-computer)
      - [Install on the board](#install-on-the-board)


Vitis AI Installation
---------------------

In order to download Vitis AI, [click here](https://github.com/Xilinx/Vitis-AI). The link will direct you to a github repository from Xilinx, which provides all the information of how to correctly install the package. This guide is based in the Xilinx documentation and only pretends to remark the most difficult steps of the installation process.

Vitis AI is Xilinx’s development stack for AI inference on Xilinx hardware platforms, including both edge devices and Alveo cards. It consists of optimized IP, tools, libraries, models, and example designs. It is designed with high efficiency and ease of use in mind, unleashing the full potential of AI acceleration on Xilinx FPGA and ACAP.

In order to install this library, you need to perform a series of steps.



### Install docker
The docker installation is done following this [guide](https://docs.docker.com/install/linux/docker-ce/ubuntu/). The installation is going to be done using the docker repository.

First of all, remove old versions of docker.

```
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```



#### Set up the repository

To install using the repository, introduce the following commands:

Update the `apt` package index.

```
$ sudo apt-get update
```

Install packages to allow `apt` to use a repository over *http*.

```
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

Add docker's official GPG.

```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Verify you have the `9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88` fingerprint by searching for the last 8 characters of the fingerprint.

```
$ sudo apt-key fingerprint 0EBFCD88

pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
```

To set up the stable repository, if you have a `x86_64/amd64` distribution, run the following command. Otherwise refer to this [guide](https://docs.docker.com/install/linux/docker-ce/ubuntu/).

```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

#### Install docker engine community

Update the `apt` package index.

```
$ sudo apt-get update
```

Install the latest version of docker engine -community.

```
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Verify that docker engine -community is installed correctly by running the `hello-world` image.

```
$ sudo docker run hello-world
```

Once this step is done, you'll have to install NVIDIA docker runtime.



#### Install NVIDIA docker runtime

 The complete instructions to perform the installationcan be obtained [here](https://nvidia.github.io/nvidia-container-runtime/). To perform the installation in Ubuntu or a debian-based distributuion, insert the following commands.

```
$ curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \  
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update

$ sudo apt-get install nvidia-container-runtime
```

Then, edit the docker config to allow users in the docker group to run docker containers.

```
$ sudo systemctl edit docker
```

This is the content you should add to the file.

```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --group docker -H unix:///var/run/docker.sock --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
```

If your console opens the file with the nano editor, to close it and save it press `ctrl + x`, and indicate `y` to save.

Finally, restart the InitD deamon and restart docker.

```
sudo systemctl daemon-reload
sudo systemctl restart docker
```



### Ensure the linux user is in the group docker
It is recommended to skip this step. In the case you don't manage in the next point to correctly launch the docker cpu image, come back to this step and follow these instructions.
By not follwing this instructions, all `docker` commands should be accessed using `sudo`.

Again, I recommend not creating an Unix Group called docker if you don't know what you are doing, as this could lead to some dangers highlihgted in this [link](https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface). Not creating this group should only means that all `docker` commands can only be accessed using the `sudo` command.

To create the `docker` group and add your user:

```
$ sudo groupadd docker

$ sudo usermod -aG docker $USER
```

To activate the changes to the groups, run the following command and verify you can run `docker` commands without `sudo`.

```
$ newgrp docker

$ docker run hello-world
```

If you get the following warning:

> WARNING: Error loading config file: /home/user/.docker/config.json -
stat /home/user/.docker/config.json: permission denied

Execute the following commands to solve the problem.

```
$ sudo chown "$USER":"$USER" /home/"$USER"/.docker -R

$ sudo chmod g+rwx "$HOME/.docker" -R
```

#### Configure docker to start on boot

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



### Clone the Vitis AI repository

We are going to clone the repository to the `/home` directory, to avoid permission issues.

```
git clone https://github.com/Xilinx/Vitis-AI  

cd Vitis-AI
```



### Run docker container

This step is extremely important if you are going to be using the Vitis-AI tools image, which enables you to use the quantize and other tools. In this case, we are interested only in the runtime image, but we will execute the CPU image to check if the Vitis-AI library has been correctly installed. Here the [guide](https://github.com/Xilinx/Vitis-AI/blob/master/doc/install_docker/load_run_docker.md), in case you need to use the CPU or GPU image.

```
# Load the CPU image from dockerhub

sudo ./docker_run.sh xilinx/vitis-ai-cpu:latest

Or

# Build the CPU image and load it

cd Vitis-AI/docker
sudo ./docker_build_cpu.sh
cd ..
sudo ./docker_run.sh xilinx/vitis-ai-cpu:latest
```

> NOTE: If you have added your user to the docker user, you wouldn't have to use the `sudo` clause. This step is not recommended though, as explained [here](#ensure-the-linux-user-is-in-the-group-docker).



### Install Vitis AI Runtime

In order to use Vitis-AI with an edge device, we need to prepare the host as well as the board that is going to be used. In this section we will explain all the steps that are neccesary to use the Vitis-AI Runtime image on a ZedBoard with a Zynq7000 chip on it.



#### Prepare the host

First of all, you'll need to perform a series of installations on your computer.

Download the [skd.sh](https://www.xilinx.com/bin/public/openDownload?filename=sdk.sh) file.

In our case, we download it to the Downloads directory, from where we run the file.

```
./sdk.sh
```

Now, the file asks where you want to install the software, which should be in a directory within `/home`, to make sure it has all the neccessary permissions.

```
/home/arroas/PetaLinux/petalinux_sdk
```

We created a folder within the PetaLinux installation folder to carry out the installation of the sdk.

Once the installation is done, you have to source the software.

```
source /home/arroas/PetaLinux/petalinux_sdk/environment-setup-aarch64-xilinx-linux
```

You can also introduce this line of code into the `.bachrc` file at `/home/arroas/` to avoid having to do it by hand every time you open a new shell.

![alt text](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/GuideImages/petalinux_sdk_sourcing.png)

Now, you have to download the [vitis_ai_2019.2-r1.1.0.tar.gz](https://raw.githubusercontent.com/UviDTE-FPSoC/vitis-dnn/master/GuideImages/petalinux_sdk_sourcing.png) and install it to the PetaLinux system.

```
tar -xzvf vitis_ai_2019.2-r1.1.0.tar.gz -C /home/arroas/PetaLinux/petalinux_sdk/sysroots/aarch64-xilinx-linux
```

You now have to update glog to the version 0.4.0. We install this version in the PetaLinux directory as well.

```
cd /home/arroas/PetaLinux/

curl -Lo glog-v0.4.0.tar.gz https://github.com/google/glog/archive/v0.4.0.tar.gz

tar -zxvf glog-v0.4.0.tar.gz

cd glog-0.4.0
```

Once you have downloaded the software, install it.

```
mkdir build_for_petalinux

cd build_for_petalinux

unset LD_LIBRARY_PATH

source /home/arroas/PetaLinux/petalinux_sdk/environment-setup-aarch64-xilinx-linux

cmake -DCPACK_GENERATOR=TGZ -DBUILD_SHARED_LIBS=on -DCMAKE_INSTALL_PREFIX=$OECORE_TARGET_SYSROOT/usr ..

make && make install

make package
```

If the software was install correctly, cross compile the sample resnet50 to check it works.

```
cd /home/arroas/Vitis-AI/VART/samples/resnet50

bash –x build.sh
```

If the compilation process does not report any error and the executable file resnet50 is generated, the host environment is installed correctly.



#### Prepare the board

First of all you need to install an operating system in the board. In this case we are using a ZedBoard with PetaLinux 2019.2 installed in an SD card. You can find a tutorial of how to prepare the SD card OS [here](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux/2019.2).
The environment is also going to need a series of different libraries to be able to execute and install all the commands and packages neccesary to work with Vitis-AI. In the previous link there is an example of how to add a library to PetaLinux. The libraries that would be neccesary are the following:

> Filesystem > base > tar > tar
>
> Filesystem > misc > python3 > python3
>
> Petalinux Package Groups > packagegroup-petalinux-pyton-modules > packagegroup-petalinux-pyton-modules

This last python package is important in order to run and execute pip3 commands, both neccesary in the Vitis-AI runtime and the DNNDK.

Once the environment is setup, it is neccessary to install [vitis_ai_runtime_library_r1.1](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux/2019.2).

Now, connect the board to your machine using a SSH connection. You can find how to establish this connection [here](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux/2019.2).

Untar the file you just downloaded. We are going to untar it in the following directory.

```
cd /home/arroas/Vitis-AI/
```

Now, copy the following files from the directory where you did the untar action to your board using the following commands.

```
scp <path_to_untar'd_runtime_library>/unilog/aarch64/libunilog-1.1.0-Linux-build46.deb root@IP_OF_BOARD:~/

scp <path_to_untar'd_runtime_library>/XIR/aarch64/libxir-1.1.0-Linux-build46.deb root@IP_OF_BOARD:~/

scp <path_to_untar'd_runtime_library>1/VART/aarch64/libvart-1.1.0-Linux-build46.deb root@IP_OF_BOARD:~/
```

As an aexample, in our case the exact commands we introduce are the following.

```
sudo scp /home/arroas/Vitis-AI/vitis-ai-runtime-1.1.0/unilog/aarch64/libunilog-1.1.0-Linux-build46.deb root@192.168.0.21:~/

sudo scp /home/arroas/Vitis-AI/vitis-ai-runtime-1.1.0/XIR/aarch64/libxir-1.1.0-Linux-build46.deb root@192.168.0.21:~/

sudo scp /home/arroas/Vitis-AI/vitis-ai-runtime-1.1.0/VART/aarch64/libvart-1.1.0-Linux-build46.deb root@192.168.0.21:~/
```

These commands will copy the files to your board's `/home/root` directory.

Now open the directory you installed glog-0.4.0 and copy the .tar.gz file to the board as well.

```
cd /home/arroas/PetaLinux/glog-0.4.0/build_for_petalinux

sudo scp glog-0.4.0-Linux.tar.gz root@192.168.0.1:~/
```

To finish, access the board using SSH or an UART connection. Through a console window, update the glog to version 0.4.0.

In order to execute the `tar` command, you have to previously install the library in your PetaLinux configuration, as shown [here](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux/2019.2).

```
cd /home/root/

tar -xzvf glog-0.4.0-Linux.tar.gz --strip-components=1 -C /usr
```

Once this is done, proceed with the installation of vitis runtime.

```
dpkg –i --force-all libunilog-1.1.0-Linux-build46.deb

dpkg –i libxir-1.1.0-Linux-build46.deb

dpkg –i libvart-1.1.0-Linux-build46.deb
```



### Install the DNNDK

This directory contains instructions and examples for running DPU-v2 on Zynq Ultrascale+ MPSoC platforms. It can also be applied to Zynq-7000 platforms. DPU-v2 is a configurable computation engine dedicated for convolutional neural networks. It includes a set of highly optimized instructions, and supports most convolutional neural networks, such as VGG, ResNet, GoogleNet, YOLO, SSD, MobileNet, FPN, and others. With Vitis-AI, Xilinx has integrated all the edge and cloud solutions under a unified API and toolset. The original information and repository is found [here](https://github.com/Xilinx/Vitis-AI/blob/master/mpsoc/README.md).

The examples are created to use with the boards ZCU102 and ZCU104, therefore if you compile the examples, this compilation is configured to work in this devices and not in other different ones, as for example a ZedBoard, which uses a Zynq7000 chip. For this reason, to run inference on another type of device, you would have to change your compilation *.sh* files, in order to adapt to your board.

#### Install on the computer

Before installing the DNNDK runtime package, it is recommended to install pip3.

```
sudo apt Update

sudo apt install pyton3-pip
```

In order to install the DNNDK, we have to install the cross compilation sdk, which has been already done when installing Vitis-AI runtime. Now, download the DNNDK runtime package [here](https://www.xilinx.com/bin/public/openDownload?filename=vitis-ai_v1.1_dnndk.tar.gz). Copy this package to the following directory and install it.

```
cd /home/arroas/PetaLinux/petalinux_sdk/sysroots/

tar -xzvf vitis-ai_v1.1_dnndk.tar.gz

cd vitis-ai_v1.1_dnndk

sudo ./install.sh $SDKTARGETSYSROOT
```

To make sure the software was correctly installed, cross-compile the following examples. First, enter the following directory.

```
cd Vitis-AI/mpsoc/vitis_ai_dnndk_samples/resnet50
```

Once you are in the directory, run the command `ls` and make sure there is no executalbe files with the name *resten50*.
Now, compile an example with one of the commands below.

```
# For ZCU102 evaluation board
  ./build.sh zcu102

# or for ZCU104 evaluation board
./build.sh zcu104
```



#### Install on the boards

Copy the [package](https://www.xilinx.com/bin/public/openDownload?filename=vitis-ai_v1.1_dnndk.tar.gz) you previously  installed in the computer to your board using a SSH connection. You can check out how to establish this type of connection [here](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux).
To copy the *.tar.gz* file to the board's `/home/root/` directory, use the following command.

```
sudo scp /home/arroas/PetaLinux/petalinux_sdk/sysroots/vitis-ai_v1.1_dnndk.tar.gz root@192.168.0.21:~/vitis-ai_dnndk
```

Once the file is in the board, from an UART or SSH connection, execute the following commands.

```
tar -xzvf vitis-ai_v1.1_dnndk.tar.gz

cd vitis-ai_v1.1_dnndk

./install.sh
```

If you get an error that pip3 command cannot be found, you should go to your petalinux project directory and open a terminal prompt.

```
petalinux-config -c rootfs
```

Once the petalinux configuration manager opens up, add the folowing package.

> Petalinux Package Groups > packagegroup-petalinux-pyton-modules > packagegroup-petalinux-pyton-modules

This should get you around that error. You would have to build your linux image again and copy the new version to your SD card.

Once the software is installed, go into the Vitis-AI folder and compress the folder with all the dnndk examples in it, which is the folder `vitis_ai_dnndk_samples`.

```
cd /home/arroas/Vitis-AI/mpsoc/

tar -zcvf vitis_ai_dnndk_samples.tar.gz vitis_ai_dnndk_samples
```

Copy the compressed folder to the board.

```
sudo scp /home/arroas/Vitis-AI/mpsoc/vitis_ai_dnndk_samples.tar.gz root@192.168.0.21:~/
```

Go back to the terminal connected to the board and run the following command.

```
tar -xzvf vitis_ai_dnndk_samples.tar.gz
```

The folder that we just uncompressed contains all the DNNDK examples you can do inference with.

Finally, download the image samples [here](https://www.xilinx.com/bin/public/openDownload?filename=vitis-ai_v1.1_dnndk_sample_img.tar.gz), and copy them as well to the board. We saved the *.tar.gz* file to the `/home/arroas/Vitis-AI/mpsoc/` directory. Now we copy it in the board as follows.

```
sudo scp /home/arroas/Vitis-AI/mpsoc/vitis-ai_v1.1_dnndk_sample_img.tar.gz root@192.168.0.21:~/
```

In the board again, execute the following.

```
tar -xzvf vitis-ai_v1.1_dnndk_sample_img.tar.gz
```

These image samples are the ones that the board is going to use in order to execute the inference of the selected example.

You can now run an example in the evaluation board.

```
cd /home/root/vitis-ai_v1.1_dnndk_sample/resnet50
./resnet50
```

Note that all this proccess works out if you have one of the boards Xilinx has support to, the ZCU102 or ZCU104. Otherwise, we would need to compile the examples for our board and then repeat the proccess of copying the example files and example images into the board.
