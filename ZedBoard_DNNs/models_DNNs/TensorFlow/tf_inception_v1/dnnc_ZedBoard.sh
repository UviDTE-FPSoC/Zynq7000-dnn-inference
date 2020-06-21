#!/usr/bin/env bash

net="inception_v1"
CPU_ARCH="arm32"
DNNC_MODE="debug"
dnndk_board="ZedBoard"
dnndk_dcf="../../dcf/custom_zedboard.dcf"

echo "Compiling Network ${net}"

# Work space directory
work_dir=$(pwd)

# Path of caffe quantization model
model_dir=${work_dir}/quantize_results
# Output directory
output_dir="dnnc_output"

tf_model=${model_dir}/deploy_model.pb

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
$DNNC   --parser=tensorflow                         \
       --frozen_pb=${tf_model}                     \
       --output_dir=${output_dir}                  \
       --dcf=${dnndk_dcf}                          \
       --mode=${DNNC_MODE}                         \
       --cpu_arch=${CPU_ARCH}                      \
       --net_name=${net}

