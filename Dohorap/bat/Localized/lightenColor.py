# -*- coding: utf-8 -*-
"""
Created on Mon Jan 13 16:12:04 2014

@author: portain
"""
import colorsys
import hex2rgb

def lightenColor(hexColor, percentage):
	c = hex2rgb.hex2rgb(hexColor)
	hls = colorsys.rgb_to_hls(c[0]/255.0,c[1]/255.0,c[2]/255.0)
	h = hls[0]
	l = hls[1]*(1-percentage) + percentage
	s = hls[2]
	frac = colorsys.hls_to_rgb(h,l,s)
	c = [int(c*255) for c in frac]
	return hex2rgb.rgb2hex(c)
