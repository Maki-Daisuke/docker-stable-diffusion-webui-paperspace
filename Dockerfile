FROM ubuntu:22.04

WORKDIR /root

RUN apt update  &&  apt upgrade -y                                           && \
    apt install -y git binutils wget gcc libxml2                             && \
    apt install -y python3.10-venv python3-pip libgl1-mesa-glx libglib2.0-0  && \
    apt autoremove -y && apt autoclean -y

# Install CUDA Toolkit 11.8
RUN wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run  && \
    sh cuda_11.8.0_520.61.05_linux.run --silent --toolkit                                                            && \
    rm cuda_11.8.0_520.61.05_linux.run

ENV PATH=/usr/local/cuda-11.8/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:$LD_LIBRARY_PATH

# Install Pythorch 2.0
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118  && \
    rm -rf /root/.cache/pip

# Install Stable-Diffusion-WebUI, recommended extensions, and their requirements.
# (python-socketio is required by Civitai extension)
RUN pip3 install python-socketio                                                                                && \
    git clone --depth 1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git                             && \
    cd stable-diffusion-webui/extensions                                                                        && \
    git clone --depth 1 https://github.com/civitai/sd_civitai_extension.git civitai                             && \
    git clone --depth 1 https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git tagcomplete               && \
    git clone --depth 1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git infinite-image-browsing  && \
    git clone --depth 1 https://github.com/Mikubill/sd-webui-controlnet.git controlnet                          && \
    cd ..                                                                                                       && \
    COMMANDLINE_ARGS=--skip-torch-cuda-test python3 -c "import launch; launch.prepare_environment()"            && \
    rm -rf /root/.cache/pip

# Install Jupyter
RUN pip3 install jupyterlab  && \
    rm -rf /root/.cache/pip
EXPOSE 6006 
EXPOSE 8888

# Change login shell to bash
RUN chsh -s /usr/bin/bash

CMD ["/bin/sh" "-c" "jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True"]
