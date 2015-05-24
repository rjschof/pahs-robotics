{{ PAHS Robotics - Transmitter                           }}
{{ Copyright (c) 2015, Robert Schofield                  }}
{{ All code in this build is released under the GNU/GPL. }}

CON
  _clkmode = xtal1 + pll16x                                               
  _xinfreq = 5_000_000

{ constants for PS2 buttons }
  ps2_nobutton = $FFFF5A73
  ps2_square = $7FFF5A73
  ps2_triangle = $EFFF5A73
  ps2_circle = $DFFF5A73
  ps2_cross = $BFFF5A73
  ps2_dpadUp = $FFEF5A73
  ps2_dpadRight = $FFDF5A73
  ps2_dpadDown = $FFBF5A73
  ps2_dpadLeft = $FF7F5A73
  ps2_L1 = $FBFF5A73
  ps2_L2 = $FEFF5A73
  ps2_R1 = $FDFF5A73
  ps2_R2 = $F7FF5A73
  ps2_start = $FFF75A73
  ps2_select = $FFBF5A73

OBJ 'objects used for the transmitter

  xbee : "Xbee_Object"
  ps2 : "PS2_Controller"

PUB main 'DO NOT EDIT THIS: Code to initialize the objects.  
         
  xbee.start(4, 3, 0, 9600)
  PS2.start(12, 5000)

  repeat
    update_xbee

PRI update_xbee 'This method is continuously repeated by the loop in the main method.
                'It checks the status of the PS2 controller's outputs and sends data accordingly.
                'Edit this as much as you wish.
 
  if (PS2.get_RightY <> 0) & (PS2.get_RightY <> 255) & (PS2.get_LeftX <> 0) & (PS2.get_LeftX <> 255)
    xbee.tx(0)

{ CASE / SWITCH for analog sticks
  This currently only includes data for the right analog stick on the PS2 controller. Use the same
  code, but change PS2.get_RightY and PS2.get_RightX to PS2.get_LeftY and PS2.get_LeftX  }

  CASE PS2.get_RightY
    0: xbee.tx(1)
    255: xbee.tx(2)

  CASE PS2.get_RightX
    0: xbee.tx(3)
    255: xbee.tx(4)
  
{ CASE / SWITCH for button presses }  
  CASE PS2.get_Data1
    ps2_cross: xbee.tx(5)