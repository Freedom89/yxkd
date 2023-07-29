---
title: Setting up my own deep learning rig
date: 2023-07-29 0000:00:00 +0800
categories: [Knowledge, Engineering]
tags: [engineering, server, deeplearningrig]     # TAG names should always be lowercase
math: true
toc: true
mermaid: true
---

## Personal Note

Currently I am pursuing a [online masters in computer science from Georgia Tech](https://omscs.gatech.edu/home). Part of the coursework (that I intend to take) such as [Deep Learning](https://omscs.gatech.edu/cs-7643-deep-learning) and [Reinforcement Learning](https://omscs.gatech.edu/cs-7642-reinforcement-learning) recommends a [CUDA](https://en.wikipedia.org/wiki/CUDA) compatible GPU. In addition, based on my personal experience, the downside of using cloud technologies is that it can be a hassle to start/shut down instances (or if you forgot to!), which introduces a barrier when trying simple experiments. Furthermore, [colab](https://colab.research.google.com/?) recently switched to a credits model instead of a subscription model. 

This, combined with the recent surge of interest in generative Ai, made me decide to invest in my own deep learning rig.

I decided to mimic my workplace setup (which is also similar to how you spin up an [EC2](https://docs.aws.amazon.com/dlami/latest/devguide/gpu.html) or [GCE](https://cloud.google.com/compute/docs/gpus) instance), which is a remote desktop called ([Google's Cloudtop](https://www.cnbc.com/2021/04/12/google-cloudtop-virtual-desktop-tool-for-employees-only.html)) that used to use [Goobuntu](https://en.wikipedia.org/wiki/Goobuntu) and later switched over to [gLinux](https://en.wikipedia.org/wiki/GLinux). For developmental work, employees would ssh to their remote desktop :smile:.

## Dualboot ubuntu

This [post](https://whatsabyte.com/reasons-dual-boot-computer/) highlights the main reasons why I decided to use dualboot, I tried [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) but found the experience subpar (which is partly motivated by my workplace design). Another huge advantage is the ability to add multiple users (each with a new environment) with it's own installations.

I bought my PC from [aftershock](https://www.aftershockpc.com/) with Windows 11 pro. I mainly got windows for edge cases (or insurance?) in the event that ubuntu is not compatiable with certain software required for my masters. Also, as recommended by the [ubuntu website](https://help.ubuntu.com/community/WindowsDualBoot), windows should be installed first.

This [guide](https://www.xda-developers.com/dual-boot-windows-11-linux/) is the one I followed to install dual boot ubuntu. I download the ubuntu desktop version instead of the server function, just incase I ever need the UI.

> ### Tips
> * You need to prepare a thumbdrive to function as an [ISO image](https://en.wikipedia.org/wiki/Optical_disc_image).
> * I set my ubuntu to be
>   * Default OS
>   * Login automatically.
>
> This is so that I can place my desktop anywhere in the house, and I just need to turn the power on. For heavy debugging tasks I will connect it to a monitor :smile:. For shutting down or rebooting, it can be done with `sudo reboot` and `sudo shutdown now`.
{: .prompt-info }

## Configuring users

These are the commands I found useful when configuring users / deleting users.

* Add user
    * ```bash
    sudo adduser <username>
    ```
* Add user to sudoers group (Giving new users admin/root access):
    * [Online Guide on how to addd sudoers in ubuntu](https://linuxize.com/post/how-to-add-user-to-sudoers-in-ubuntu/)
    * ```bash
      usermod -aG sudo <username>
      ```
* Delete user
  * [askubuntu.com - How to delete a user & its home folder safetly](https://askubuntu.com/questions/459365/how-to-delete-a-user-its-home-folder-safely) 
  * ```bash
    sudo userdel username
    # Or to delete the home directory as well
    sudo deluser --remove-home user
    ```

## Configuring ssh

To setup your ubuntu desktop to allow ssh is incredibily easy:

```bash
sudo apt update && sudo apt install build-essential
sudo apt install openssh-server
```

Verify that ssh has been installed correctly:

```
sudo systemctl status ssh
```

### Allow SSH from another device.

To allow ssh, you need to configure your router. In my case I am using the linksys velop network and the guide can be found [here](https://www.linksys.com/in/support-article/?articleNum=138535). I used single port forwarding and both `external` and `internal` port should be set to `22` which is the default port.

To figure out your Device IP address, just type this on your ubuntu Desktop:

```bash
Hostname -I
```

It should come out as `192.168.x.y` and just populate this ip on your router settings. Afterwards, you should be able to ssh by doing this on your mac's terminal:

```bash
ssh <username>@192.168.x.y -p 22
```

If you know your own ip address, it can also be done with `ssh <username>@<your ip address> -p 22`.

The following sections can now be done from your mac (or external machine)!

```bash
❯ ssh <myusername>@<my ip> -p 22
<myusername>@<my ip>'s password:
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.19.0-50-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

 * Introducing Expanded Security Maintenance for Applications.
   Receive updates to over 25,000 software packages with your
   Ubuntu Pro subscription. Free for personal use.

     https://ubuntu.com/pro

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

Last login: Sat Jul 29 16:57:03 2023 from 192.168.3.112
lowyx:~$
```

## Configuring Python

I followed this [guide](https://linuxhint.com/install-anaconda-ubuntu-22-04/) to install anaconda, as it is my preferred method to manage different python environments locally. (Will try to attempt this with [Docker](../docker) in the future). The instructions are pretty straight forward:

Look at the [official anaconda repo site](https://repo.anaconda.com/archive/) and select the version you need. I happen to be using the intel x64 architecture:

```bash
curl --output anaconda.sh https://repo.anaconda.com/archive/Anaconda3-2023.07-1-Linux-x86_64.sh
bash anaconda.sh
```

Then, reload your terminal (by exiting and ssh in again), you should be able to run conda:

```bash
conda env list
```

To create a new conda environment:

```bash
conda create -n pyt python=3.10
conda activate pyt
```

## Configuring GPU for Pytorch

In my opinion, configuring Cuda and Nvidia for deep learning is a little tricky, I watched the following youtube video (below) but I found certain steps to be missing but it should give you a high level idea of the steps required:

{% include embed/youtube.html id='c0Z_ItwzT5o' %}

* Install nvidia drivers (nvidia-smi)
* Configure Cuda
* Install pytorch

### Nvidia-smi

First check if your desktop has a nvidia gpu and then install the driver:

```bash
lowyx:~$ lspci | grep -i nvidia
01:00.0 VGA compatible controller: NVIDIA Corporation Device 2684 (rev a1)
01:00.1 Audio device: NVIDIA Corporation Device 22ba (rev a1)
```

Then, check the available drivers avaliable:

```bash
lowyx:~$ ubuntu-drivers list
nvidia-driver-535-open, (kernel modules provided by linux-modules-nvidia-535-open-generic-hwe-22.04)
nvidia-driver-525-server, (kernel modules provided by linux-modules-nvidia-525-server-generic-hwe-22.04)
nvidia-driver-525-open, (kernel modules provided by linux-modules-nvidia-525-open-generic-hwe-22.04)
nvidia-driver-525, (kernel modules provided by linux-modules-nvidia-525-generic-hwe-22.04)
nvidia-driver-535, (kernel modules provided by linux-modules-nvidia-535-generic-hwe-22.04)
nvidia-driver-535-server, (kernel modules provided by linux-modules-nvidia-535-server-generic-hwe-22.04)
nvidia-driver-535-server-open, (kernel modules provided by linux-modules-nvidia-535-server-open-generic-hwe-22.04)
```

I installed the `525` version, do note that you need to reboot afterwards.

```bash
sudo apt-get install nvidia-driver-525
sudo reboot
```

Then, on the terminal run `nvidia-smi` and this should be the output:

```bash
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 525.125.06   Driver Version: 525.125.06   CUDA Version: 12.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0  On |                  Off |
|  0%   36C    P8    17W / 450W |    216MiB / 24564MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|    0   N/A  N/A      1556      G   /usr/lib/xorg/Xorg                 64MiB |
|    0   N/A  N/A      1808      G   /usr/bin/gnome-shell              134MiB |
|    0   N/A  N/A      2165      G   ...bexec/gnome-initial-setup        6MiB |
+-----------------------------------------------------------------------------+
```

### Cuda toolkit

If you see the `nvidia-smi` output above, you will notice that the CUDA Version is version 12. However, it is important for you to check the latest distribution of [pytorch cuda version](https://pytorch.org/get-started/locally/), for example in my case the stable build only supports up till 11.8.

![image](../../../assets/posts/dlrig/pytorch_site.png)

So, it is important that we install the cuda 11.8 version. I just searched Google with `nvidia driver for cuda 11.8` and it brought me to the nvidia developer page [here](https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=runfile_local). 

![image](../../../assets/posts/dlrig/nvidia.png)

Select the required OS, architecture, distribution and version, `runfile` as installer type which will give you the instructions:

```bash
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run
sudo sh cuda_11.8.0_520.61.05_linux.run
```

When you run the bash scripts, it warns you that you already have an earlier of driver installed, click `Continue`:

![image](../../../assets/posts/dlrig/install1.png)

Accept the terms and conditions:

![image](../../../assets/posts/dlrig/install2.png)

And unselect the driver installation:

![image](../../../assets/posts/dlrig/install3.png)

After this step, reboot your desktop (`sudo reboot`). It will show you an output that your cuda has been added to `/usr/local/cuda` directory.

To make sure everything is working correctly:

* Navigate to `/user/local` and look for `cuda-11.8` (Or the version you are using):
* Navigate to `cuda-11.8/bin`, you should see a `nvcc` binary

```bash
lowyx:/usr/local/cuda-11.8/bin$ ./nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2022 NVIDIA Corporation
Built on Wed_Sep_21_10:33:58_PDT_2022
Cuda compilation tools, release 11.8, V11.8.89
Build cuda_11.8.r11.8/compiler.31833905_0
```

Once this is verified, add this to your bashrc script:

```bash
export CUDA_HOME=/usr/local/cuda-11.8   # Modify the path if necessary
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
```

Now, reboot your bash script/terminal and you should be able to run `nvcc --version`:

```bash
lowyx:~$ nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2022 NVIDIA Corporation
Built on Wed_Sep_21_10:33:58_PDT_2022
Cuda compilation tools, release 11.8, V11.8.89
Build cuda_11.8.r11.8/compiler.31833905_0
```

### Pytorch

As mentioned, the pytorch installation instructions can be found in [pytorch.org website](https://pytorch.org/get-started/locally/). Since I am using linux with Conda, this are my installation steps provided:

```bash
conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
```

To check if your pytorch is able to access the gpu, I found this [stackoverflow](https://stackoverflow.com/questions/48152674/how-do-i-check-if-pytorch-is-using-the-gpu) to be a good guide:

```bash
lowyx:~$ ipython
Python 3.11.4 (main, Jul  5 2023, 13:45:01) [GCC 11.2.0]
Type 'copyright', 'credits' or 'license' for more information
IPython 8.12.0 -- An enhanced Interactive Python. Type '?' for help.

In [1]: import torch
torch
In [2]: torch.cuda.is_available()
Out[2]: True
```

### Delete Driver + Cuda

During my process, I found myself running wrong steps and had to attempt to reinstall certain drivers. This [stackoverflow](https://stackoverflow.com/questions/56431461/how-to-remove-cuda-completely-from-ubuntu) provided me with the details required to remove cuda from ubuntu.

```bash
sudo apt-get purge nvidia*
sudo apt-get autoremove
sudo apt-get autoclean
sudo rm -rf /usr/local/cuda*
```

## Future work

I have a couple more things I like to figure out but it involves around the developer experience.

1. Use [vscode remote development](https://code.visualstudio.com/docs/remote/ssh) to link to my remote desktop instead of just the terminal shell as point of interaction.
2. Then instead of using the terminal shell, use a [docker container instead](https://code.visualstudio.com/docs/devcontainers/containers).
