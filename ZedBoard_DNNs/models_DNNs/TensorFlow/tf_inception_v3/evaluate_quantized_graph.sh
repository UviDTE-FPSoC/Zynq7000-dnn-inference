#!/bin/sh

set -e

# Please set your imagenet validation dataset path here, 
IMAGE_DIR=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/
IMAGE_LIST=/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/val.txt

# Please set your batch size settings here, #IMAGES = VAL_BATCHES * BATCH_SIZE
# Commonly there are 5w image in total for imagenet validation dataset
EVAL_BATCHES=50		#1000
BATCH_SIZE=50

python inception_v3_eval.py \
  --input_frozen_graph quantize_results/quantize_eval_model.pb \
  --input_node input \
  --output_node InceptionV3/Predictions/Reshape_1 \
  --eval_batches $EVAL_BATCHES \
  --batch_size $BATCH_SIZE \
  --eval_image_dir $IMAGE_DIR \
  --eval_image_list $IMAGE_LIST \
  --gpu 0
