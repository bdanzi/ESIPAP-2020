FROM rootproject/root-ubuntu16

MAINTAINER Marco Delmastro <Marco.Delmastro@cern.ch>

USER root

# Install ROOT prerequisites
RUN apt-get update

# Install Python and dependencies (installs python 2.7)
RUN apt-get install -y python-pip

# Download and install ROOT in /opt/root
RUN apt-get install -y wget
WORKDIR /opt
ARG rootsrc=root_v6.18.04.Linux-ubuntu16-x86_64-gcc5.4.tar.gz
RUN wget https://root.cern.ch/download/${rootsrc}
RUN tar xzf ${rootsrc}
RUN rm ${rootsrc}

# Install dependencies to run notebooks
RUN pip install --upgrade pip
RUN pip install jupyter \
                metakernel \
                zmq \
		numpy \
		matplotlib

# Create a user that does not have root privileges
ARG username=physicist
RUN userdel builder && useradd --create-home --home-dir /home/${username} ${username}
ENV HOME /home/${username}

# Copy repository in user home
COPY . ${HOME}
RUN chown -R ${username} ${HOME}

# Switch to normal user
USER ${username}
WORKDIR ${HOME}

# Set ROOT environment
ENV ROOTSYS         "/opt/root"
ENV PATH            "$ROOTSYS/bin:$ROOTSYS/bin/bin:$PATH"
ENV LD_LIBRARY_PATH "$ROOTSYS/lib:$LD_LIBRARY_PATH"
ENV PYTHONPATH      "$ROOTSYS/lib:PYTHONPATH"

# Customize the local environement
RUN mkdir -p                                 $HOME/.ipython/kernels
RUN cp -r $ROOTSYS/etc/notebook/kernels/root $HOME/.ipython/kernels
RUN mkdir -p                                 $HOME/.ipython/profile_default/static
RUN cp -r $ROOTSYS/etc/notebook/custom       $HOME/.ipython/profile_default/static

