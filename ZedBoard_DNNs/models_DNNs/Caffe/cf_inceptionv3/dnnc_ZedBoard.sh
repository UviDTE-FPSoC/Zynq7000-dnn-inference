#!/usr/bin/env bash

net="inception_v3"
CPU_ARCH="arm32"
DNNC_MODE="debug"
dnndk_board="ZedBoard"
dnndk_dcf="../../dcf/custom_zedboard.dcf"

echo "Compiling Network ${net}"

model_dir="quantized"
output_dir="dnnc_output"

DNNC=dnnc

# Get DNNDK config info
if [ ! -f /etc/dnndk.conf ]; then
    echo "Error: Cannot find /etc/dnndk.conf"
    exit 1
else
    tmp=$(grep "DNNDK_VERSION=" /etc/dnndk.conf)
    dnndk_version=${tmp#DNNDK_VERSION=}
    dnndk_version=${dnndk_version#v}
    echo "DNNDK      : $dnndk_version"
    echo "Board Name : $dnndk_board"
    echo "DCF file   : $dnndk_dcf"
fi

if [ ! -d "$model_dir" ]; then
    echo "Can not found directory of $model_dir"
    exit 1
fi

[ -d "$output_dir" ] || mkdir "$output_dir"

echo "CPU Arch   : $CPU_ARCH"
echo "DNNC Mode  : $DNNC_MODE"
echo "$(dnnc --version)"
$DNNC   --prototxt=${model_dir}/deploy.prototxt    \
       --caffemodel=${model_dir}/deploy.caffemodel \
       --output_dir=${output_dir}                  \
       --net_name=${net}                           \
       --dcf=${dnndk_dcf}                          \
       --mode=${DNNC_MODE}                         \
       --cpu_arch=${CPU_ARCH}
