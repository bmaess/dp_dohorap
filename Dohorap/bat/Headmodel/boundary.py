#!/usr/bin/python
#geometry/boundary.py

from numpy import concatenate
from numpy import sort
from numpy import transpose
from numpy import array
from numpy import argsort
from numpy import diff
from numpy import argwhere
from numpy import delete
from numpy import unique
from numpy import reshape

def boundary( vert, element ):
    "Calculate the boundary of a hexagonal mesh."
    quad1 = element[:, [0, 1, 2, 3]]
    quad2 = element[:, [0, 1, 5, 4]]
    quad3 = element[:, [1, 2, 6, 5]]
    quad4 = element[:, [2, 3, 7, 6]]
    quad5 = element[:, [3, 0, 4, 7]]
    quad6 = element[:, [4, 5, 6, 7]]
    quads = concatenate((quad1, quad2, quad3, quad4, quad5, quad6))
    
    quads_sort = sort(quads, 1).astype('int64')
     
    p = quads_sort[:, 0]*(max(quads_sort[:, 1]) - min(quads_sort[:, 1]) + 1) + quads_sort[:, 1] +1j*quads_sort[:, 2]
    k = argsort(p)
    l = argwhere(diff(p[k])==0)
    l = concatenate((l, l + 1))
    k = delete(k, l)
    quad = quads[k, :]
    index = k % element.shape[0]
    
    #quads_center = squeeze(mean(reshape(node(boundary,:),size(boundary,1),4,3),2));
    #element_center = squeeze(mean(reshape(node(element(mod(K(a==1) - 1,size(element,1)) + 1,:),:),size(boundary,1),8,3),2));
    #e = mod(K(a==1) - 1,size(element,1)) + 1;
    #normal = bsxfun(@minus,quads_center,element_center);
    
    [nodemap,d] = unique(quad, return_inverse=True)
    face = reshape(d, quad.shape)
    bnd  = vert[nodemap, :]
    
    #idx = dot(cross(vert(boundary(:,2),:)-vert(boundary(:,1),:),vert(boundary(:,3),:)-vert(boundary(:,2),:)), normal, 2) < 0;
    #boundary(idx, 2:4) = boundary(idx, 4:-1:2);
    # pot = potential(map);
    return [bnd, face, index]

