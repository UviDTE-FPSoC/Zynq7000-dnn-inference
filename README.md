Neural Network Inference with SoC devices
=========================================
This guide shows the process to perform the inference of a neural network using a SoC device. In this very guide, the inference itself will be done with the aid of a library from Xilinx called Vitis-AI. The installation and configuration process of the software will be displayed in this guide as well, considering the difficulties that might appear during the proccess. Remark that all the software we are using will be mounted on an embedded operating system, PetaLinux in our case, in order to work with the SoC device.
The installation and configuration of all the software needed to use PetaLinux is given this other [repository](https://github.com/UviDTE-FPSoC/Zynq7000-examples/tree/master/SD-operating-system/PetaLinux/2019.2). From this point on, notice that the configuration of all the tools is done in order to meet compatibility with the installation of PetaLinux.

Table of contents:
- [Vitis-AI Installation](#vitis---AI-Installation)
   - [Install docker](#install-docker)
      - [Set up the repository](#set-up-the-repository)
      - [Install docker engine -community](#install-docker-engine---community)
   - [Ensure the Linux user is in the group docker](#ensure-the-linux-user-is-in-the-group-docker)
      - [Configure docker to start on boot](#configure-docker-to-start-on-boot)
   - [Clone the Vitis-AI repository](#clone-the-vitis-ai---repository)
   - [Load and run docker container](#load-and-run-docker-container)


Vitis-AI Installation
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

#### Install docker engine -community

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



### Clone the Vitis-AI repository

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
