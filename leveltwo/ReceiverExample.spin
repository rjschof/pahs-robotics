{{ PAHS Robotics - Receiver Example                        }}           
{{ Copyright (c) 2015, Robert Schofield and Peter Nguyen   }}
{{ All code in this release is licensed under the GNU GPL. }}{{

This code was written to correspond with the code in TransmitterExample.spin. The
following code is meant to provide an example for receiver code that can be used
for the level two robots.

Note that words such as "forward" and "reverse" are relative to your particular
setup. View the documentation for more information. 

The CON, OBJ, and VAR blocks for this code are explained below.

--- CON (Constants)
The constants block contains the constant values that represent the movement of the
servo. Use: servo.set(pin#, full_forward) to make the the servo at the specified pin
number move forward with maximum power. 

--- OBJ (Objects)
Objects are the different pieces of source code used for very specific purposes. For
example, the XBee Controller and Servo Controller are objects that are used for this
source code.

--- VAR (Variables)
One variable is present in this code. The variable in the VAR block below represents
the value received from the transmitter by the XBee Chip. 

*** More documentation for this code can be found in the documentation folder. }}

CON
  _clkmode = xtal1 + pll16x 
  _xinfreq = 5_000_000

{{ constants for servo control }}
  full_forward = 2000
  half_forward = 1750
  full_stop = 1500
  full_reverse = 1000
  half_reverse = 1250

VAR
  byte memory[400] ' memory location for arm, clamp, and autonomous cogs.
  byte autonomous_done ' variable that represents whether autonomous has been used.

  byte drive_cog
  byte arm_cog
  byte clamp_cog
  byte auton_control_cog 
  
OBJ
  xbee : "Xbee_Object"
  servo : "Servo32v9"
  ping : "Ping)))"
  
PUB main
  xbee.start(4,3,0,9600)
  servo.start
  servo.ramp

  autonomous_done := 0

  drive_cog := cognew(update_drive, @memory[0])
  arm_cog := cognew(update_arm, @memory[100])
  clamp_cog := cognew(update_clamp, @memory[200])
  
  repeat
    update_autonomous

PRI update_drive {{
The code in this section will make a robot with two servos as part of its drive train move
based upon what the xbee chip receives from the transmitter. Please note that these values
will vary based upon your setup.                                                            }}

  repeat
    CASE xbee.rx
      0: servo.set(16, full_stop)
        servo.set(17, full_stop)
      1: servo.set(16, full_reverse)
        servo.set(17, full_reverse)
      2: servo.set(16, full_forward)
        servo.set(17, full_forward)
      3: servo.set(16, full_reverse)
        servo.set(17, full_forward)
      4: servo.set(16, full_forward)
        servo.set(17, full_reverse)

PRI update_arm {{
The code in this section will make a robot arm that is controlled with one servo retract and
extend based upon the button input that the transmitter as processed.                       }}

  repeat
    CASE xbee.rx
      5: servo.set(18, full_stop)
      6: servo.set(18, full_reverse)
      7: servo.set(18, full_forward)

PRI update_clamp {{
The code in this section will make a robot's clamping mechanism open and close based upon the
button input that the transmitter processed and sent to the receiver.                      }}

  repeat
    CASE xbee.rx
      5: servo.set(19, full_stop)
      8: servo.set(19, full_reverse)
      9: servo.set(19, full_forward)

PRI update_autonomous {{
This method checks the signals received from the XBee Chip for the signal that represents
the button press that starts autonomous. In this example, it is the Start button on the
PS2 Controller.                                                                            }}

  repeat
    CASE xbee.rx
      10: cogstop(drive_cog)
        cogstop(arm_cog)
        cogstop(clamp_cog)
        coginit(0, autonomous_control, @memory[0])
        autonomous
        quit
  
PRI autonomous                   

  repeat while(autonomous_done == 0)                   
    if(ping.cm(18) > 15)           
      servo.Set(16,1000)      
      servo.Set(17,2000)
    else 
      servo.Set(16,1500)      
      servo.Set(17,1500)
    if (xbee.rx == 11)
      quit

  drive_cog := coginit(0, update_drive, @memory[0])
  arm_cog := cognew(update_arm, @memory[100])
  clamp_cog := cognew(update_clamp, @memory[200])
  
PRI autonomous_control
  waitcnt(cnt + (clkfreq * 29))
  autonomous_done := 1
   