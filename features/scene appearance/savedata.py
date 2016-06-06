import h5py
import numpy as np
import scipy.misc
import numpy as np
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


f = h5py.File('nyu_depth_v2_labeled.mat')
for i in range(1449):
	print(i)
	b = np.array(f['images'][i,:,:,:]).astype('float32')
	b = np.swapaxes(b, 0,2)
	b = resize_image(b, (227, 227))
	scipy.misc.imsave('./images/' + str(i+1) + '.jpg', b)