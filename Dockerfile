
# 使用官方cuda的Ubuntu作为基础镜像, 这个cuda版本要小于等于nvidia-smi
FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04


# 避免在安装时出现交互式提示
ARG DEBIAN_FRONTEND=noninteractive

# 复制本地的sources.list文件到容器中
COPY sources.list /etc/apt/sources.list

# 更新软件包列表，安装依赖
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC \
    && apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    zsh \
    tmux \
    vim \
    software-properties-common \
    apt-transport-https \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 配置tmux
COPY .tmux.conf /root/.tmux.conf

# 安装code-server
RUN export http_proxy="http://101.43.1.213:20171" && export https_proxy="http://101.43.1.213:20171" \
    && curl -fsSL https://raw.githubusercontent.com/cdr/code-server/main/install.sh | sh \
    && mkdir -p /root/.config/code-server

## 配置文件
COPY config.yaml /root/.config/code-server/config.yaml
## 安装插件
ARG PLUGIN_LIST="ms-python.python charliermarsh.ruff \
    mhutchie.git-graph eamodio.gitlens \
    ms-toolsai.jupyter ms-toolsai.jupyter-keymap ms-toolsai.vscode-jupyter-cell-tags ms-toolsai.jupyter-renderers ms-toolsai.vscode-jupyter-slideshow \
    cweijan.vscode-mysql-client2 anwar.papyrus-pdf njzy.stats-bar"

###  设置环境变量，以便在构建过程中使用
ENV PLUGIN_LIST=${PLUGIN_LIST}
RUN export http_proxy="http://101.43.1.213:20171" && export https_proxy="http://101.43.1.213:20171" && \
    for plugin in $PLUGIN_LIST; do code-server --install-extension $plugin; done

# 安装Oh-My-Zsh和插件
RUN export http_proxy="http://101.43.1.213:20171" \
    && export https_proxy="http://101.43.1.213:20171" \
    && sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

##  改变zsh配置
RUN chsh -s $(which zsh) \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/' /root/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' /root/.zshrc

# 安装Miniconda, zsh配置完了才能配置conda
RUN wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py39_23.10.0-1-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/conda \
    && rm /tmp/miniconda.sh \
    && /opt/conda/bin/conda init zsh

# 暴露code-server的端口
EXPOSE 8080

# 设置工作目录
WORKDIR /workspace

# 运行code-server
ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password"]

# 可以选择启动一个shell
CMD [ "zsh" ]