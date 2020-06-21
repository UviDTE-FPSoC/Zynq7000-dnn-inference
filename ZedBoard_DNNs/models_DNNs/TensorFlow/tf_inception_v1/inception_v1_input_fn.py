from inception_v1_preprocessing import *

def eval_input(iter, eval_image_dir, eval_image_list, class_num, eval_batch_size):
  images = []
  labels = []
  line = open(eval_image_list).readlines()
  for index in range(0, eval_batch_size):
    curline = line[iter * eval_batch_size + index]
    [image_name, label_id] = curline.split(' ')
    image = cv2.imread(eval_image_dir + image_name)
    image = mean_image_subtraction(image)
    image = central_crop(image, 0.875)
    image = cv2.resize(image, (224, 224))
    image = normalize(image)
    images.append(image)
    labels.append(int(label_id) + 1)
  lb = preprocessing.LabelBinarizer()
  lb.fit(range(0, class_num))
  labels = lb.transform(labels)
  return {"input": images, "labels": labels}


calib_image_dir = "/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_images/"
calib_image_list = "/media/arroas/HDD/MinhasCousas/EEI/Mestrado/2_Curso/TFM/Inference_Images/calibration_data/imagenet_calib.txt"
calib_batch_size = 1
def calib_input(iter):
  images = []
  line = open(calib_image_list).readlines()
  for index in range(0, calib_batch_size):
    curline = line[iter * calib_batch_size + index]
    calib_image_name = curline.strip()
    image = cv2.imread(calib_image_dir + calib_image_name)
    image = mean_image_subtraction(image)
    image = central_crop(image, 0.875)
    image = cv2.resize(image, (224, 224))
    image = normalize(image)
    images.append(image)
  return {"input": images}
