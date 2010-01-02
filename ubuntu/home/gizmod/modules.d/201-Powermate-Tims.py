from GizmoDaemon import *
from GizmoScriptDefault import *
import time

ENABLED = True
VERSION_NEEDED = 3.3
INTERESTED_CLASSES = [GizmoEventClass.Powermate]


PRESS_THRESHOLD = 2
MULTIPLIER = 2

#_out = open('/tmp/powermate-log', 'w')

def debug(s): pass
	#print >> _out, s
	#_out.flush()

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
