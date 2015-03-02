#!/usr/bin/python
#write_vistamesh.py

import os
batdir = os.environ.get('BATDIR')
from subprocess import call
call(['matlab', '< ' + batdir + 'Headmodel/write_vistamesh.m'])

