#!/usr/bin/python
#affine_mod.py
import os
from numpy import array, insert, zeros, transpose, dot, cross
from numpy.linalg import norm
from nibabel import load, save, Nifti1Image

mridir = os.path.join(os.environ.get('EXPDIR'), '7t')

F = array([[223, 17, 80, 1], [409, 278, 40, 1],[31, 287, 41, 1], [219, 530, 97, 1]])
a2  = (F[1, 0:3] + F[2, 0:3])/2
v = (F[0, 0:3] - a2)
v = v/norm(v)
w = cross(F[2, 0:3] - F[1, 0:3], v)
w = w/norm(w)
u = cross(v, w)
R = array([u, v, w])*.4
T = insert(insert(R, 3, -dot(R, a2), axis=1), 3, array([0, 0, 0, 1]), axis=0)

img = load(os.path.join(mridir, 'KMKT130606_mp2rage_inv2_merged.nii'))
img_new = insert(img.get_data(), 454, zeros((544, 454)), axis=0)
img_new = insert(img_new, 544, zeros((455, 454)), axis=1)
img_new = insert(img_new, 454, zeros((455, 545)), axis=2)
image = Nifti1Image(img_new, T)
save(image, (os.path.join(mridir, 'aKMKT130606_mp2rage_inv2_merged.nii')))

img = load(os.path.join(mridir, 'KMKT130606_mp2rage_t1weighted_merged.nii'))
img_new = insert(img.get_data(), 454, zeros((544, 454)), axis=0)
img_new = insert(img_new, 544, zeros((455, 454)), axis=1)
img_new = insert(img_new, 454, zeros((455, 545)), axis=2)
image = Nifti1Image(img_new, T)
save(image, (os.path.join(mridir, 'aKMKT130606_mp2rage_t1weighted_merged.nii')))

