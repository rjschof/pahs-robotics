{{Ping))).spin

Gets measurements from Ping))) Ultrasonic Distance Sensor.

See end of file for author, version, copyright and terms of use.
                   
}}
OBJ                                                   

  pin    : "Input Output Pins"                        ' Input/output pin convenience methods
  pulse  : "Pulse"                                    ' Measures and/or transmits pulses
  

CON                                                   

  cmScalar = 29                                       ' For converting echo time to measured distance
  inchScalar = 74
  

VAR                                                   

  long dt                                             ' Time increment
  
  
PUB cm(ioPin) : distance
{{Measure distance in centimeters

Parameter:

  ioPin = I/O pin number

Returns:

  distance = centimeter distance measurement  

Example:
  OBJ
    system : "Propeller Board of Education"
    ping   : "Ping)))"
    pst    : "Parallax Serial Terminal Plus"
    
  PUB Go | distance
    system.Clock(80_000_000)    ' System clock -> 80 MHz
    ' Measure cm distance from Ping))) connected to P19
    distance = ping.cm(19)      
    pst.Dec(distance)           ' Display distance
    pst.LewLine                 ' Cursor -> next line

}}
  distance := Get(ioPin, cmScalar)
  

PUB In(ioPin) : distance
{{Measure distance in inches

Parameter:

  ioPin = I/O pin number

Returns:

  distance = Inch distance measurement  

Example:
  OBJ
    system : "Propeller Board of Education"
    ping   : "Ping)))"
    pst    : "Parallax Serial Terminal Plus"
    
  PUB Go | distance
    system.Clock(80_000_000)    ' System clock -> 80 MHz
    ' Measure inch distance from Ping))) connected to P19
    distance = ping.in(19)      
    pst.Dec(distance)           ' Display distance
    pst.LewLine                 ' Cursor -> next line

}}

  distance := Get(ioPin, inchScalar)
  

PUB Ticks(ioPin) : echoTime
{{Measure distance in system clock ticks

Parameter:

  ioPin = I/O pin number

Returns:

  distance = Echo round trip time in system clock ticks  

Example:
  OBJ
    system : "Propeller Board of Education"
    ping   : "Ping)))"
    pst    : "Parallax Serial Terminal Plus"
    
  PUB Go | distance
    system.Clock(80_000_000)    ' System clock -> 80 MHz
    ' Measure echo round trip echo time from Ping))) connected to P19 
    ' in terms of clock ticks 
    distance = ping.Ticks(19)      
    pst.Dec(distance)           ' Display distance
    pst.LewLine                 ' Cursor -> next line

}}

  pin.Low(ioPin)
  pulse.Out(ioPin, 5)
  echoTime := pulse.In(ioPin, 1)
  

PRI Get(ioPin, scalar) : distance

  ifnot dt
    dt := clkfreq/1_000_000

  distance := Ticks(ioPin)
  distance /= (scalar*2)


DAT
{{
File:      Ping))).spin
Date:      2012.06.02
Version:   0.50
Author:    Andy Lindsay
Copyright: (c) 2012 Parallax Inc.  

┌-─────────────────────────────────────────────────────────────────────────────────────┐
│ TERMS OF USE: MIT License                                                            │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Permission is hereby granted, free of charge, to any person obtaining a copy         │
│ of this software and associated documentation files (the "Software"),                │
│ to deal in the Software without restriction, including without limitation            │
│ the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or      │
│ sell copies of the Software, and to permit persons to whom the Software is furnished │  
│ to do so, subject to the following conditions:                                       │
│                                                                                      │
│ The above copyright notice and this permission notice shall be included in all       │
│ copies or substantial portions of the Software.                                      │
│                                                                                      │
│ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,  │ 
│ INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A        │   
│ PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT   │  
│ HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF │   
│ CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE │  
│ OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                        │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}  