#!/usr/bin/python
# Run 'nosetests' over the current file.
# If the current file does not end in '_test.py' then
# it will look in your project directory for one that does

import os, sys, re, commands
from popen2 import popen2

def escape_singles(s):
	return s.replace("'", "'\\''")

def str_end(a, b):
	la = len(a)
	lb = len(b)
	mn = min(la, lb)
	if la < lb:
		return b[mn:]
	else:
		return a[mn:]

project_dir = os.environ['TM_PROJECT_DIRECTORY']
file_path = os.environ['TM_FILEPATH']
file_base = re.sub('\.py$', '', os.path.basename(file_path), re.I)

if not file_base.endswith('_test'):
	(status, file_path) = commands.getstatusoutput(
		"find '%s' -iname '%s_test.py' | head -n 1" % (
			escape_singles(project_dir),
			escape_singles(file_base)))
	if status != 0:
		print "Error: %s" % (file_path)
		exit(2)
	if not os.path.isfile(file_path):
		print "Find did not get us a valid file: %s" % (file_path,)
		exit(2)


rel_file_path = str_end(project_dir, file_path)
if rel_file_path.startswith(os.path.sep):
	rel_file_path = rel_file_path[1:]

rel_file_path = re.sub('\.py$', '', rel_file_path, re.I)
rel_file_path = rel_file_path.replace('..','.')
dotted_file_path = '.'.join(os.path.split(rel_file_path))

cmd = """cd '%s' && nosetests '%s' --xml --xml-formatter=nosexml.TextMateFormatter""" % (escape_singles(project_dir), escape_singles(dotted_file_path))

# print cmd

(output, input) = popen2('/bin/bash')
print >> input, cmd
input.close()
for line in output.readlines():
	print line