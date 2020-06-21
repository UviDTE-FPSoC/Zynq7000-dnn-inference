import cv2
from sklearn import preprocessing

def bgr2rgb(image):
  B, G, R = cv2.split(image)
  image = cv2.merge([R, G, B])
  return image

def central_crop(image, scale=1.0):
  center_y = image.shape[0] / 2
  center_x = image.shape[1] / 2
  width_scaled = image.shape[1]*scale
  height_scaled = image.shape[0]*scale

  left_x = center_x - width_scaled / 2
  right_x = center_x + width_scaled / 2
  top_y = center_y - height_scaled / 2
  bottom_y = center_y + height_scaled / 2

  return image[int(top_y):int(bottom_y), int(left_x):int(right_x)]

def normalize(image):
  image=image/255.0
  image=image-0.5
  image=image*2
  return image
