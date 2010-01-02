    #***
  #*********************************************************************
#*************************************************************************
#***
#*** GizmoDaemon Config Script
#***  Powermate Compiz config
#***
#*****************************************
  #*****************************************
    #***

"""

  Copyright (c) 2007, Gizmo Daemon Team
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at 

	http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and 
  limitations under the License. 
  
"""

############################
# Imports
##########################

from GizmoDaemon import *
from GizmoScriptDefault import *
import time

ENABLED = True
VERSION_NEEDED = 3.3
INTERESTED_CLASSES = [GizmoEventClass.Powermate]


PRESS_THRESHOLD = 2
MULTIPLIER = 2

_out = open('/tmp/powermate-log', 'w')

def debug(s):
	print >> _out, s
	_out.flush()

############################
# PowermateCompiz Class definition
##########################

class ScrollAction(GizmoScriptDefault):
	"""
	Tim's default scrolley actions
	"""
	
	############################
	# Public Functions
	##########################
			
	def onDeviceEvent(self, Event, Gizmo = None):
		"""
		Called from Base Class' onEvent method.
		See GizmodDispatcher.onEvent documention for an explanation of this function
		"""
		debug("event!")
					
		if Event.Type == GizmoEventType.EV_REL:
			if not Gizmo.getKeyState(GizmoKey.BTN_0): # normal scrolling
				Gizmod.Mice[0].createEventRaw(GizmoEventType.EV_REL, GizmoMouseAxis.WHEEL, -Event.Value)

			else: # knob is being held down
				print self.press_buffer
				self.press_buffer += Event.Value
				if(abs(self.press_buffer) < PRESS_THRESHOLD):
					return True
				else:
					repeat = abs(self.press_buffer) // PRESS_THRESHOLD
					self.press_buffer = repeat % PRESS_THRESHOLD
					debug("repeat = %s, new buffer = %s" % (repeat, self.press_buffer))

				if Event.Value < 0:
					for repeat in range(repeat):
						Gizmod.Keyboards[0].createEvent(GizmoEventType.EV_KEY, GizmoKey.KEY_PAGEUP, [GizmoKey.KEY_RIGHTCTRL])
				else:
					for repeat in range(repeat):
						Gizmod.Keyboards[0].createEvent(GizmoEventType.EV_KEY, GizmoKey.KEY_PAGEDOWN, [GizmoKey.KEY_RIGHTCTRL])
			
		elif Event.Type == GizmoEventType.EV_KEY:
			if Event.Value == 0 and not Gizmo.Rotated:
				# issue a close tab if the button is pressed
				Gizmod.Keyboards[0].createEvent(GizmoEventType.EV_KEY, GizmoKey.KEY_W, [GizmoKey.KEY_RIGHTCTRL])
		return True
		
	############################
	# Private Functions
	##########################

	def __init__(self):
		""" 
		Default Constructor
		"""
		
		GizmoScriptDefault.__init__(self, ENABLED, VERSION_NEEDED, INTERESTED_CLASSES)
		self.press_buffer = 0


# register the user script
debug("loading...")
ScrollAction()
