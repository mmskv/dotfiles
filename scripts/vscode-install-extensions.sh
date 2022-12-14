{
cat <<EOF
James-Yu.latex-workshop
ms-python.isort
ms-python.python
ms-python.vscode-pylance
ms-toolsai.jupyter
ms-toolsai.jupyter-keymap
ms-toolsai.jupyter-renderers
ms-toolsai.vscode-jupyter-cell-tags
ms-toolsai.vscode-jupyter-slideshow
ms-vsliveshare.vsliveshare
shanejarvie.hybrid-theme
vscodevim.vim
EOF
} | xargs -L1 vscodium --install-extension
