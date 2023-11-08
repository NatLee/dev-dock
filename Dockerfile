#FROM nvidia/cuda:latest
FROM python:3.9.16-slim-buster

# Environment variables
ENV HOME=/root \
    SCRIPTS_DIR=/root/scripts \
    NO_VNC_DIR=/root/noVNC \
    VNC_TOOL_DIR=/root/vnc-tools \
    DISPLAY=:1 \
    TERM=xterm \
    SSH_PORT=22 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1600x900 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false \
    DEBIAN_FRONTEND=noninteractive \
    LANG='zh_TW.UTF-8' LANGUAGE='en_US:en' \
    ROOT_PASSWORD='root' \
    DEFAULT_USER='user' DEFAULT_USER_PASSWORD='user'

# Working directory
WORKDIR $HOME

# Expose ports
EXPOSE $VNC_PORT
EXPOSE $NO_VNC_PORT
EXPOSE $SSH_PORT

# Add scripts
ADD ./scripts $SCRIPTS_DIR
RUN find $SCRIPTS_DIR -name '*.sh' -exec chmod a+x {} +

# User settings
RUN $SCRIPTS_DIR/1.user-settings.sh

# Install OS packages
RUN $SCRIPTS_DIR/2.install-packages.sh

# Install required softwares
ADD ./vnc-tools $VNC_TOOL_DIR
RUN $SCRIPTS_DIR/3.install-vnc-core.sh
ADD ./xfce $HOME

# Install Debs and other softwares
ADD ./pkg $HOME/install
RUN $SCRIPTS_DIR/4.install-custome-pkgs.sh

# Install Conda
RUN $SCRIPTS_DIR/5.install-conda.sh

# Set permissions
RUN $SCRIPTS_DIR/6.set-permissions.sh $SCRIPTS_DIR $HOME

# Make ssh run folder
RUN mkdir /run/sshd

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
