#!/bin/sh
cd $TM_PROJECT_DIRECTORY && nosetests --xml --xml-formatter=nosexml.TextMateFormatter