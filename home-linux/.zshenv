[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.config/vite-plus/env" ] && . "$HOME/.config/vite-plus/env"

# Usa a GPU do Windows (d3d12) no OpenGL e no VA-API em vez do llvmpipe.
export GALLIUM_DRIVER=d3d12
export LIBVA_DRIVER_NAME=d3d12
