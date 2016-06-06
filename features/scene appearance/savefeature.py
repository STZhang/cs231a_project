import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
import caffe
import scipy.io as sio

from skimage.transform import resize
from scipy.ndimage import zoom

def resize_image(im, new_dims, interp_order=1):
    """
    Resize an image array with interpolation.
    Take
    im: (H x W x K) ndarray
    new_dims: (height, width) tuple of new dimensions.
    interp_order: interpolation order, default is linear.
    Give
    im: resized ndarray with shape (new_dims[0], new_dims[1], K)
    """
    if im.shape[-1] == 1 or im.shape[-1] == 3:
	im_min, im_max = im.min(), im.max()
        if im_max > im_min:
            # skimage is fast but only understands {1,3} channel images in [0, 1].
            im_std = (im - im_min) / (im_max - im_min)
            resized_std = resize(im_std, new_dims, order=interp_order)
            resized_im = resized_std * (im_max - im_min) + im_min
        else:
            # the image is a constant -- avoid divide by 0
            ret = np.empty((new_dims[0], new_dims[1], im.shape[-1]), dtype=np.float32)
            ret.fill(im_min)
            return ret
    else:
        # ndimage interpolates anything but more slowly.
        scale = tuple(np.array(new_dims) / np.array(im.shape[:2]))
        resized_im = zoom(im, scale + (1,), order=interp_order)
    return resized_im.astype(np.float32)

caffe.set_device(0)
caffe.set_mode_gpu()

MODEL_FILE = '/scail/scratch/u/zhangst/object/caffe/models/finetune_flickr_style/deploy.prototxt'
PRETRAINED = '/scail/scratch/u/zhangst/object/caffe/models/finetune_flickr_style/version1_iter_1000.caffemodel'
IMAGE_DIR = '/scail/scratch/u/zhangst/object/scene/data/images/'

net = caffe.Net(MODEL_FILE, PRETRAINED, caffe.TEST)
features = np.zeros([1449, 13])
transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})
transformer.set_transpose('data', (2,0,1))
blob = caffe.proto.caffe_pb2.BlobProto()
data = open( '/scail/scratch/u/zhangst/object/scene/places365CNN_mean.binaryproto' , 'rb' ).read()
blob.ParseFromString(data)
arr = np.array( caffe.io.blobproto_to_array(blob) )
transformer.set_mean('data', arr[0,:,:,:].mean(1).mean(1)) # mean pixel
transformer.set_raw_scale('data', 255)  # the reference model operates on images in [0,255] range instead of [0,1]
transformer.set_channel_swap('data', (2,1,0))  # the reference model has channels in BGR order instead of RGB

net.blobs['data'].reshape(50,3,227,227)

# In[4]:
for i in range(1, 1450):
	input_image = caffe.io.load_image(IMAGE_DIR + str(i) + '.jpg')
	net.blobs['data'].data[...] = transformer.preprocess('data', input_image)	
	net.forward() # equivalent to net.forward_all()
	softmax_probabilities = net.blobs['prob'].data[0].copy()
	print(softmax_probabilities.argmax()) 
	features[i-1, :] = softmax_probabilities

#save features to .mat
sio.savemat('scene_scores.mat', {'scores': features})
