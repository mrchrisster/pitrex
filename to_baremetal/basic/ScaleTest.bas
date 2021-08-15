' ScaleTest helps you determine the range of coordinates at a given
' scale.
'
' - Run the program, read the instructions, and press button 1 to continue.
' - Press buttons 1 or 2 to increase or decrease the scale.
' - Use the joystick to move the crosshairs to the edges of the screen.
' - Read the coordinates to see how far the beam is moving, at the current 
'   scale's setting

if Version() < 100 then
    print "Upgrade the Vectrex32 firmware to version 1.00 or newer."
    stop
endif

call SetFrameRate(30)
call IntensitySprite(100)

textSize = {40, 5}
call TextSizeSprite(textSize)
instructions = {{-50, 90, "INSTRUCTIONS"}, _
                {-80, 70, "BTN 1&2 CHANGES SCALE"}, _
                {-80, 50, "JOYSTK MOVES CROSSHAIR"}, _
                {-80, 30, "READ COORDINATES"}, _
                {-80, 10, "BTN 4 EXITS"}, _
                {-80, -10, "PRESS BTN 1 TO START"}}
        
call TextListSprite(instructions)

' Wait for button 1 not to be pressed
controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
while controls[1, 3] = 1
    controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
endwhile
' Now wait for button 1 or 4 to be pressed
controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
while controls[1, 3] = 0 and controls[1, 6] = 0
    controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
endwhile

' If button 4 is pressed, exit
if controls[1, 6] then
    stop
endif

call ClearScreen()

call SetFrameRate(40)
call IntensitySprite(100)

info = {{-35, 90, "SCALE: 50"}, {-35, 70, "X = 0"}, {-35, 50, "Y = 0"}}
infoDisplay = TextListSprite(info)

call ReturnToOriginSprite()

' This is the scale that the user will change
scale = 50
scaleDisplay = ScaleSprite(scale)

' Put a dummy move in. For some reason, drawing at (0, 0) after a ReturnToOrigin
' doesn't work
call MoveSprite(1, 1)
call MoveSprite(-1, -1)

' Set the position of the crosshair the user will move around
xy = {{0, 0}}
crossPos = LinesSprite(xy)

crossScale = ScaleSprite(20)

crosshair = {{MoveTo, 0, 50}, {DrawTo, 0, -50}, {MoveTo, -50, 0}, {DrawTo, 50, 0}}
crossDisplay = LinesSprite(crosshair)

' If a button is pressed, we wait until it's released before accepting
' another button press
refractoryPeriod = 1
' Do forever
while 1
    ' Wait until it's time to prepare the next frame
    controls = WaitForFrame(JoystickDigital, Controller1, JoystickX + JoystickY)
    ' If the joystick moved, update the crosshair position, first in the X axis
    if controls[1, 1] < 0 then
        xy[1, 1] = xy[1, 1] - 1
    elseif controls[1, 1] > 0
        xy[1, 1] = xy[1, 1] + 1
    endif
    ' then in the Y axis
    if controls[1, 2] < 0 then
        xy[1, 2] = xy[1, 2] - 1
    elseif controls[1, 2] > 0
        xy[1, 2] = xy[1, 2] + 1
    endif
    
    ' If button 1 or 2 was pressed
    if controls[1, 3] or controls[1, 4] then
        ' If we're not in the refractory period (the period after a button is
        ' pressed and before we accept another button press)
        if refractoryPeriod = 0 then
            ' Move the crosshair back to the origin
            xy[1, 1] = 0
            xy[1, 2] = 0
            ' Increment or decrement the scale
            if controls[1, 3] then
                scale = max(scale - 1, 0)
            else
                scale = min(scale + 1, 255)
            endif
            call SpriteScale(scaleDisplay, scale)
            info[1, 3] = "SCALE: " + scale
            refractoryPeriod = 1
        endif
    else
        refractoryPeriod = 0
    endif
    ' Button 4 exits
    if controls[1, 6] then
        exit while
    endif
    
    ' Display the current position of the crosshair
    info[2, 3] = "X = " + xy[1, 1]
    info[3, 3] = "Y = " + xy[1, 2]
endwhile

