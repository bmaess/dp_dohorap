# -*- coding: utf-8 -*-
"""
Created on Mon Jan 13 16:12:47 2014

@author: portain
"""

def hex2rgb(h):
	if '#' in h:
		h = h.replace('#','')
	return [ord(c) for c in h.decode('hex')]
	
def rgb2hex(c):
	return '#%02x%02x%02x' % (c[0], c[1], c[2])