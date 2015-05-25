{{Pulse.spin

Methods for transmitting and measuring individual pulses.
See end of file for terms of use.
                   
}}

VAR

  long dt, blocked, timeOut
  
PUB Out(ioPin, pulseTime) : ctrIdx | ctr, phs, frq, state, i
{{Send a voltage pulse

Checks I/O pin, changes the I/O pin's output state
for a certain time, then returns it to its original state.

Parameters:

  ioPin     = I/O pin number
  pulseTime = Time pulse lasts.

Returns:

  success  

Notes:

  Default time increment is 1 = 1 us.
  Time increment can be changed by calling CustomTimeIncrement

Example:
  OBJ
    system : "Propeller Board of Education"
    pin    : "Input Output Pins"
    pulse  : "Pulse"
    
  PUB Go
    system.Clock(80_000_000) ' System clock -> 80 MHz
    ' Send positive pulse  to P9
    pin.Low(9)               ' P9 output-low   
    pulse.Out(9, 10)         ' 10 us positive pulse to P9
    
    ' Send negative pulse  to P5
    pin.High(5)              ' P5 output-high  
    pulse.Out(5,11)          ' 11 us negative pulse to P5

}}

  state := ! ina[ioPin] & 1                             ' Record state of I/O pin

  ifnot dt                                              ' If time increment not defined
    dt := clkfreq/1_000_000                             ' Default to microseconds

  phs := - pulseTime * dt                               ' Set up positive pulse time
  frq := 1                                              ' Set up counting increment
  ifnot state                                           ' If negative pulse
    phs := -phs                                         ' Negate frq and phs
    frq := -frq                                         

  ctr := (%00100 << 26) + ioPin                         ' Set up counter register 
  
  ifnot ctra                                            ' Check if CTRA unused
    i := 0                                              ' Yes? CTRA offset for SPR = 0
  elseifnot ctrb                                        ' Check if CTRB unused 
    i := 1                                              ' Yes? CTRB offset for SPR = 1
  else                                                  ' No CTR registers open?
    i := -1                                             ' Return -1 
    return ctrIdx := -1                                 ' To-Do: Add attempt to launch process into cog

  ' This routine enables negative pulses.  Withouth it, outa[ioPin] OR phs[bit31] -> pin will not go 
  ' low if it starts with outa[ioPin] == 1.  It applies the same process to positive pulses even though
  ' it is not required because it helps reduce code size and keeps setup times consistent.
  ifnot state                                           ' If negative pulse
    spr[12+i] := -1                                     ' Set up CTR for temporary positive pulse to create high signal
  else                                                  ' If positive pulse
    spr[12+i] := 0                                      ' Set up CTR for temporary negative pulse
  spr[10+i] := frq                                    
  spr[8+i] := ctr
  outa[ioPin] := 0                                      ' Set I/O pin to output low (because it's I/O OR counter module)
  dira[ioPin] := 1  

  spr[12+i] := phs                                      ' Deliver pulse
        
  ifnot blocked                                         ' If default preempt process until complete
    repeat while ina[ioPin] == state                    ' Wait for pulse to end
    outa[ioPin] := !state                               ' Restore I/O output register to pre-pulse state
                                                         
  spr[8+i]~                                             ' Clear CTRA/B

  return ctrIdx := i                                    ' Report pulse successfully delivered

PUB In(ioPin, state) : pulseTime | ctr, frq, offset, i, notstate, t, tf
{{Measure a voltage pulse applied to an I/O pin

Waits for I/O pin to get to resting state, then waits for pulse to start and measures it.

Parameters:

  ioPin = I/O pin number
  state = 1 -> positive pulse, 0 -> negative pulse

Notes:

  Default time increment is 1 = 1 us.
  Time increment can be changed by calling CustomTimeIncrement
  Timeout can be changed by callnig CustomTimeout

Example:
  OBJ
    system : "Propeller Board of Education"
    pulse : "Pulse"
    pst   : "Parallax Serial Terminal Plus"
    
  PUB Go | t
    system.Clock(80_000_000)    ' System clock -> 80 MHz
    ' Measure positive pulse  applied to P10
    t = pulse.In(10, 1)         ' Stores pulse applied to P10 in t
    pst.Dec(t)
    pst.LewLine
    ' Measure negative pulse  applied to P6
    t = pulse.Out(5,0)          ' Stores pulse applied to P6 in t
    pst.Dec(t)

}}

  ifnot dt                                              ' If time increment not defined
    dt := clkfreq/1_000_000                             ' Make it 1 µs
  ifnot timeOut                                         ' If timeOut not defined
    timeOut := (clkfreq/1000)*25                        ' Make it 25 ms

  ctr := ((%01000 | ((!state&1)*%100)) << 26) + ioPin     ' Set up counter to measure + pulses

  ifnot ctra                                            ' Check if coutner A unused
    i := 0                                              ' If so, use it
  elseifnot ctrb                                        ' Check if counter B unused
    i := 1                                              ' If so, use it
  else                                                  ' No counters?
    return -1                                           ' Return -1.  To-do: try another cog

  dira[ioPin]~                                          ' Set I/O pin to input

  spr[8+i] := ctr                                       ' Configure counter module
  spr[10+i] := 1                                        ' Set phase increment to 1 
  tf := timeOut                                         ' Set timeout
  t  := cnt                                             ' Mark time

  repeat while (ina[ioPin] == state) and (cnt-t<tf)     ' Wait for rest state or timeout
  spr[12+i]~                                            ' Clear phase register
  repeat until spr[12+i] or (cnt-t>tf)                  ' Wait for pulse to accumulate or timeout
  repeat while (ina[ioPin] == state) and (cnt-t<tf)     ' Wait for pulse to end or timeout
  spr[8+i]~                                             ' Stop the counter
  pulseTime := spr[12+i]/dt                             ' Return phase register contents in terms of time increment

PUB SetForget(tf)
{{Setects whether Out method initiates a pulse and returns immediately or waits for the
pulse to finish before returning.

Parameter:

  tf = false -> Set-forget mode disabled. Out waits for pulse to finish before returning.
       true  -> Set-forget mode enabled. Out starts pulse and returns immediately.  

Note:

  Set forget mode is disabled by default.

  If you enable set-forget mode, your code has to manually close the counter module with
  the Close method after calling Out.
  
}}

  blocked := tf

PUB Close(ctrIdx)
{{Allows our code to close a counter module after calling Out with SetForget mode
enabled.

Parameter:

  ctrIdx = 1 -> CTRB, 0 -> CTRA  

Note:

  Check the Out method's return value to get ctrIdx 
  
}}

  

PUB CustomTimeIncrement(clockTicks)
{{Sets time increment to custom value.

Parameter:

  clockTicks = number of clock ticks in the time increment.
  
Example:
  OBJ
    system : "Propeller Board of Education"
    pulse  : "Pulse"
    
  PUB Go
    system.Clock(80_000_000) ' Set system clock to 80 MHz 
    ' Change time increment from 1 us to 2 us
    pulse.CustomTimeIncrement(clkfreq/500_000)
    ' Change time increment to 12.5 ns (assuming 80 MHz clock)
    puslse.CustomTimeIncrement(1)

}}


  dt := clockTicks

PUB CustomTimeout(clockTicks)
{{Sets timeout to custom value.

Parameter:

  clockTicks = number of clock ticks the timeout takes.
  
Example:
  OBJ
    system : "Propeller Board of Education"
    pulse  : "Pulse"
    
  PUB Go
    system.Clock(80_000_000) ' Set system clock to 80 MHz 
    ' Change time increment from 25 ms to 50 ms
    pulse.CustomTimeout((clkfreq/1000)*50)

}}

  timeOut := clockTicks    

DAT                                           

{{
File:      Pulse.spin
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