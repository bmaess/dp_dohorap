#!/usr/bin/python
#geometry/mesh.py

from numpy import unravel_index
from numpy import nonzero
from numpy import transpose
from numpy import unique
from numpy import reshape
from numpy import concatenate
from numpy import argsort

def mesh( img ):
    "Calculate the mesh of an image (segmentation)."
    [x, y, z] = nonzero(img)
    r1 = [x,   y,   z  ]
    r2 = [x+1, y,   z  ]
    r3 = [x+1, y+1, z  ]
    r4 = [x,   y+1, z  ]
    r5 = [x,   y,   z+1]
    r6 = [x+1, y,   z+1]
    r7 = [x+1, y+1, z+1]
    r8 = [x,   y+1, z+1]
    r = concatenate((r1, r2, r3, r4, r5, r6, r7, r8), 1)
    #p = r[0, :]*(max(r[1, :])-min(r[1, :]) + 1) + r[1, :] + 1j*r[2, :]
    p = r[0, :]*(max(r[1, :])-min(r[1, :]) + 1) + r[1, :] + 1j*r[2, :]
    
    [k, d] = unique(p, return_index=True, return_inverse=True)[1:3]
    vert = transpose(r[:, k])
    elem = transpose(reshape(d, (8, -1)))
 
    return [vert, elem]

