#!/bin/bash

# 插件列表，每个插件一个行
PLUGIN_LIST=(
    # python
    "ms-python.python"
    "charliermarsh.ruff"
    "njpwerner.autodocstring"
    # git
    "mhutchie.git-graph"
    "eamodio.gitlens"
    # jupyter notebook
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.vscode-jupyter-cell-tags"
    "ms-toolsai.jupyter-renderers"
    "ms-toolsai.vscode-jupyter-slideshow"
    # 主题
    "PKief.material-icon-theme"
    "Catppuccin.catppuccin-vsc"
    # AI写代码
    # "Codeium.codeium"
    # 数据库连接工具
    "cweijan.dbclient-jdbc"
    "cweijan.vscode-mysql-client2"
    # 其他
    "anwar.papyrus-pdf"
    "njzy.stats-bar"
    "richie5um2.vscode-sort-json"
    "Gruntfuggly.todo-tree"
)

# 设置代理环境变量
export http_proxy="http://101.43.1.213:20171"
export https_proxy="http://101.43.1.213:20171"

# 安装插件
for plugin in "${PLUGIN_LIST[@]}"; do
    code-server --install-extension "$plugin"
done
