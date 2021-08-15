' Clock.bas
'

if Version() < 100 then
    print "Upgrade the Vectrex32 firmware to version 1.00 or newer."
    stop
endif

call IntensitySprite(100)

rate = GetFrameRate()

textSize = {40, 5}
call TextSizeSprite(textSize)
' Display the time, the number of OS ticks in the latest frame.
' You can have a succint display with just the numbers by changing
' the 'succinct' variable to true. Otherwise, you'll get a more
' verbose display. A succint display might allow a higher frame rate
succint = false
if succint then
    clock = {{-30, 10, "0/0/0"}}
else
    clock = {{-30, 90, "CLOCK: 0"}, _
             {-30, 70, "FRAME RATE: " + rate}, _
             {-30, 50, "FRAME TIME: 0"}, _
             {-60, 10, "BTN 1 & 2 CHANGE RATE"}}
endif
        
call TextListSprite(clock)

time = 0
count = 0
tick = GetTickCount()
lastTick = tick

recognizeBtn1 = false
recognizeBtn2 = false

' Do forever
while 1
    if UBound(clock) = 1 then
        clock[1, 3] = time + "/" + rate + "/" + (tick - lastTick)
    else
        clock[1, 3] = "CLOCK: " + time
        clock[2, 3] = "FRAME RATE: " + rate
        clock[3, 3] = "FRAME TIME: " + (tick - lastTick)
    endif
    
    ' Wait until it's time to prepare the next frame
    controls = WaitForFrame(JoystickDigital, Controller1, JoystickX + JoystickY)
    
    if controls[1, 6] then
        stop
    endif
    
    if recognizeBtn1 and controls[1, 3] and rate < 300 then
        rate = rate + 5
        call SetFrameRate(rate)
        time = 0
        count = 0
        recognizeBtn1 = false
    endif
    if recognizeBtn2 and controls[1, 4] and rate > 5 then
        rate = rate - 5
        call SetFrameRate(rate)
        time = 0
        count = 0
        recognizeBtn2 = false
    endif
    
    if not recognizeBtn1 and controls[1, 3] = 0 then
        recognizeBtn1 = true
    endif
    if not recognizeBtn2 and controls[1, 4] = 0 then
        recognizeBtn2 = true
    endif
    
    lastTick = tick
    tick = GetTickCount()
    
    count = count + 1
    if count = rate then
        count = 0
        time = time + 1
    endif
endwhile

