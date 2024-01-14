
# 使用官方cuda的Ubuntu作为基础镜像, 这个cuda版本要小于等于nvidia-smi
FROM nvidia/cuda:11.2.2-cudnn8-devel-ubuntu20.04


# 避免在安装时出现交互式提示
ARG DEBIAN_FRONTEND=noninteractive

# 复制本地的sources.list文件到容器中
COPY os/sources.list /etc/apt/sources.list

# 更新软件包列表，安装依赖
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC \
    && apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    zsh \
    tmux \
    vim \
    build-essential \
    software-properties-common \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*


##########################code-server##########################
# 安装code-server
RUN export http_proxy="http://101.43.1.213:20171" && export https_proxy="http://101.43.1.213:20171" \
    && curl -fsSL https://raw.githubusercontent.com/cdr/code-server/main/install.sh | sh \
    && mkdir -p /root/.config/code-server

## 配置文件
COPY code-server/config.yaml /root/.config/code-server/config.yaml

## 插件安装
COPY code-server/plugin_install.sh /workspace/
RUN zsh /workspace/plugin_install.sh
COPY code-server/settings.json root/.local/share/code-server/User/settings.json
##########################code-server##########################

# 修改默认的 shell 为 zsh
SHELL ["/bin/zsh", "-c"]


# 配置tmux
COPY tmux/.tmux.conf /root/.tmux.conf


# 安装Oh-My-Zsh和插件
RUN export http_proxy="http://101.43.1.213:20171" && export https_proxy="http://101.43.1.213:20171" \
    && sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

##  改变zsh配置
RUN chsh -s $(which zsh) \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/' /root/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' /root/.zshrc \
    && echo "alias cs=code-server" >> /root/.zshrc


# 安装Miniconda, zsh配置完了才能配置conda
RUN wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py39_23.10.0-1-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/conda \
    && rm /tmp/miniconda.sh \
    && /opt/conda/bin/conda init zsh \
    && source ~/.zshrc \
    && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn \
    && pip install numpy \
    && pip install pycuda

# 暴露code-server的端口
EXPOSE 8080

# 设置工作目录
WORKDIR /workspace

# 运行code-server
ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password"]