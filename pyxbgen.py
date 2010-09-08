#!/usr/bin/env python

# Generate PyXB binding classes from schemas.

import os
import sys
import glob

try:
  os.mkdir('./pyxb')
except OSError:
  pass

for xsd in glob.glob('*.xsd'):
  if xsd in ('common.xsd', 'dryadMetsAny.xsd'):
    continue
  cmd = 'pyxbgen --binding-root=./pyxb -m {0} {1}'.format(os.path.splitext(xsd)[0], xsd)
  print(cmd)
  os.system(cmd)
