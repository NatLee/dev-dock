
# GUI Container using Xfce with VNC

> Only support x86/64.

This repo is creating a common GUI image by using docker for developing.

The image included the following components:

* Xfce Desktop
* VNC Server (default VNC port: 5901)
* VNC Client with HTML5 support (default http port: 6901)
* OpenSSH (default SSH port: 22)
* Git
* Mini Conda
* VScode
* Google Chrome
* Anydesk

## Run docker without sudo

```bash
sudo groupadd docker && gpasswd -a $USER docker
```

**＊ You can change $USER to match your preferred user name if you do not want to use your current user**

## Usage

- Build an image.

```bash
docker-compose build
```

- Run a container with the image build recently.

```bash
docker-compose up
```

## Connection

If you have not change the default port yet, you can use the services with the following ports.

* VNC port: 5901, connect with host `<YOUR_HOST_IP>` and `<PORT>`
* noVNC port: 6901, connect via `http://<YOUR_HOST_IP>:6901/?password=<YOUR_VNC_PASSWORD>`
* SSH port: 22, connect with command line `ssh root@<YOUR_HOST_IP>:<PORT>`

**＊ You can login SSH with `default user` or `root`.**

## Some Flags

* Map ports
    - 5901 (vnc protocol)
    - 6901 (vnc web access)
    - 22 (ssh protocol)

`-p 12345:5901 -p 13579:6901 -p 24680:22`

* Set the same timezone

`-v /etc/localtime:/etc/localtime:ro`

* Mount a volume

`-v <YOUR_LOCAL_PATH>:<>YOUR_CONTAINER_PATH>`

* Mount a network disk as a volume

`sudo mount -t cifs -o username=<YOUR_USER_NAME>,password=<YOUR_PASSWORD>,vers=3.0 //<YOUR_NETWORK_LOCATION> <LOCAL_LOCATION>`

`-v <LOCAL_LOCATION>:<>YOUR_CONTAINER_PATH>`

* Override the VNC resolution

`-e VNC_RESOLUTION=1920x1080`

* Change the VNC password

`-e VNC_PW=<YOUR_VNC_PWD>`

* Change root password

`-e ROOT_PASSWORD='root'`

* Add user

`-e DEFAULT_USER='user' -e DEFAULT_USER_PASSWORD='user'`


### Execution with the only docker command

**You need to restart the container to make Chinese input method work after first login into VNC.**

* Test container:

```bash
docker run -d -p 12345:5901 -p 13579:6901 -p 24680:22 \
            -v /etc/localtime:/etc/localtime:ro \
            -v /home/infor/Desktop/test/:/root/Desktop/ \
            -e VNC_PW=infor1234 \
            -e VNC_RESOLUTION=1600x900 \
            -e DEFAULT_USER='test' -e DEFAULT_USER_PASSWORD='test' \
            -e ROOT_PASSWORD='root' \
            --name test test-vnc-gui
```

## Misc

If you need use this with NVIDIA GPUs, you need to follow this in the main system.

- [Installing the NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

