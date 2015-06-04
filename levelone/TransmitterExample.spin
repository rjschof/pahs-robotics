{{ PAHS Robotics - Transmitter Example                     }}           
{{ Copyright (c) 2015, Robert Schofield                    }}
{{ All code in this release is licensed under the GNU GPL. }}{{

The following code is meant to provide an example for transmitter code that can be used
for the level one robots.

The CON, OBJ, and VAR blocks for this code are explained below.

--- CON (Constants)
The constants block contains the constants that represent button press data on the PS2
controller. Do not change the hexadecimal values on these lines.

--- OBJ (Objects)
Objects are the different pieces of source code used for very specific purposes. For
example, the PS2 Controller and XBee Controller are objects that are used for this
source code.

--- VAR (Variables)
The variables block for this code was not included. It is not necessary to include
variables in this code as it is written currently. If you come up with a solution
that requires the use of a variable, then be sure to add the VAR blcok to your code.

*** More documentation for this code can be found in the documentation folder. }}

CON
  _clkmode = xtal1 + pll16x  'Clock mode for the propeller chip. Do not change this.                                             
  _xinfreq = 5_000_000 ' Clock frequency for the propeller chip. Do not change this.

{ constants for PS2 buttons }
  ps2_nobuttons = $FFFF5A73
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

OBJ 'objects used for the transmitter. Do not edit this unless you know what you're doing.
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
                
{ Important information:
  The xbee.tx method takes a number as its parameter. This number is sent based upon the input
  on the PS2 Controller. You get to decide what number is sent for each button press or analog
  stick movement.                                                                                   }
 
  if (PS2.get_RightY <> 0) & (PS2.get_RightY <> 255) & (PS2.get_RightX <> 0) & (PS2.get_RightX <> 255) & (PS2.get_Data1 == ps2_nobuttons)
    xbee.tx(0) ' No button presses and no analog stick movement

{ CASE Statement for analog sticks
  This currently only includes data for the right analog stick on the PS2 controller. Use the same
  code, but change PS2.get_RightY and PS2.get_RightX to PS2.get_LeftY and PS2.get_LeftX             }

  CASE PS2.get_RightY
    0: xbee.tx(1)
    255: xbee.tx(2)

  CASE PS2.get_RightX
    0: xbee.tx(3)
    255: xbee.tx(4)
  
{ CASE / SWITCH for button presses           
  The constants set in the CON block above are used in this CASE statement. You can set which value
  each button press sends to the receiver.                                                          }
                                          
  CASE PS2.get_Data1
    ps2_cross: xbee.tx(5)
    ps2_square: xbee.tx(6)
    ps2_circle: xbee.tx(7)
    ps2_triangle: xbee.tx(8)
    