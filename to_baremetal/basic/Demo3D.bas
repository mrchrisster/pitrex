if Version() < 110 then
    print "Upgrade the Vectrex32 firmware to version 1.10 or newer."
    stop
endif

call IntensitySprite(100)

call SetFrameRate(60)

textSize = {40, 5}
call TextSizeSprite(textSize)
instructions = {{-50, 90, "INSTRUCTIONS"}, _
                {-80, 70, "BTN 1 CREATES SHIP"}, _
                {-80, 50, "JOY PITCHES AND YAWS"}, _
                {-80, 30, "JOY + BTN 2 ROLLS"}, _
                {-80, 10, "JOY + BTN 3 MOVES CAMERA"}, _
                {-80, -10, "BTN 4 EXITS"}, _
                {-80, -30, "PRESS BTN 1 TO START"}}

call TextListSprite(instructions)

' Wait for button 1 or button 4
controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
while controls[1, 3] = 0 and controls[1, 6] = 0
    controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
endwhile

' If button 4 was pressed, exit
if controls[1, 6] then
    stop
endif

call ClearScreen()

call SetFrameRate(45)
cameraTrans = {0, 0, 0}
call CameraTranslate(cameraTrans)

call Randomize



' Set the scale to 32. At a scale of 32, 650 Vectrex units will draw a line
' on the Vectrex screen that is 0.097 meters long (and we're using meters for
' our World coordinates)
call ScaleSprite(64, 324 / 0.097)

shipWidth = 7.0
shipHeight = shipWidth * 0.75
podDiameter = shipWidth * 5 / 8

' Create an array of ships. Each row has the ship's sprite, its translation and its pitch/roll/yaw
ships = NewShip()

disableButton1 = GetFrameRate()

while 1 do
    controls = WaitForFrame(JoystickDigital, Controller1, JoystickX + JoystickY)

    ' If button 4 was pressed, exit
    if controls[1, 6] then
        stop
    endif

    ' If button 1 was pressed, create a new ship
    if controls[1, 3] and disableButton1 = 0 then
        call ReturnToOriginSprite()
        ships = AppendArrays(ships, NewShip())
        ' Disable the button for 1/2 second
        disableButton1 = GetFrameRate() / 2
    endif

    if disableButton1 then
        disableButton1 = disableButton1 - 1
    endif

    ' If button 3 is not pressed
    if controls[1, 5] = 0 then
        ' If button 2 is not pressed
        if controls[1, 4] = 0 then
            ' Go through all the ships
            for i = 1 to UBound(ships)
                ' Yaw the ship based on the joystick's X position
                if controls[1, 1] < 0 then
                    call SpriteRotate(ships[i, 1], 0, 0, -1)
                elseif controls[1, 1] > 0
                    call SpriteRotate(ships[i, 1], 0, 0, 1)
                endif
                ' Pitch the ship based on Y
                if controls[1, 2] < 0 then
                    call SpriteRotate(ships[i, 1], 0, -1, 0)
                elseif controls[1, 2] > 0
                    call SpriteRotate(ships[i, 1], 0, 1, 0)
                endif
            next i

        ' Else (button 2 is pressed)
        else
            ' Go through all the ships
            for i = 1 to UBound(ships)
                ' Roll the ship based on the joystick
                if controls[1, 1] < 0 then
                    call SpriteRotate(ships[i, 1], 0, -1, 0)
                elseif controls[1, 1] > 0
                    call SpriteRotate(ships[i, 1], 0, 1, 0)
                endif
            next i
        endif

    ' Else (button 3 is pressed)
    else
        ' If button 2 is not pressed
        if controls[1, 4] = 0 then
            ' Change the camera's yaw
            if controls[1, 1] < 0 then
                call CameraRotate(0, 0, -1)
            elseif controls[1, 1] > 0
                call CameraRotate(0, 0, 1)
            endif
            ' Change the camera's pitch
            if controls[1, 2] < 0 then
                call CameraRotate(0, -1, 0)
            elseif controls[1, 2] > 0
                call CameraRotate(0, 1, 0)
            endif
        ' Else (button 2 is pressed)
        else
            ' Change the camera's roll
            if controls[1, 1] < 0 then
                call CameraRotate(0, -1, 0)
            elseif controls[1, 1] > 0
                call CameraRotate(0, 1, 0)
            endif
            camRotation = CameraGetRotation()
            ' Change the camera's position
            v = {0, 0, 0}
            if controls[1, 2] < 0 then
                v = {0, 0, -1}
            elseif controls[1, 2] > 0
                v = {0, 0, 1}
            endif
            v = VectorRotate(v, camRotation[1], camRotation[2], camRotation[3])
            cameraTrans[1] = cameraTrans[1] + v[1]
            cameraTrans[2] = cameraTrans[2] + v[2]
            cameraTrans[3] = cameraTrans[3] + v[3]
        endif
    endif

endwhile

function TieFighter(shipWidth, shipHeight, podDiameter, wingSides, podSides)
    ' Build the wings: first, make a polygon. It must have an even number of sides
    poly = RegularPolygon(wingSides, shipHeight, 180 / wingSides)
    ' Draw lines between opposite vertices
    dim lines[wingSides - 1, 3]
    dest = 1
    for i = 1 to wingSides / 2
        if i > 1 then
            lines[dest, 1] = MoveTo
            lines[dest, 2] = poly[i, 2]
            lines[dest, 3] = poly[i, 3]
            dest = dest + 1
        endif
        lines[dest, 1] = DrawTo
        lines[dest, 2] = poly[i + wingSides / 2, 2]
        lines[dest, 3] = poly[i + wingSides / 2, 3]
        dest = dest + 1
    next i

    ' Combine the hexagon and the lines between vertices
    wing = AppendArrays(poly, lines)
    ' Turn it into a 3D arrays for the left and right wing
    dim leftWing[UBound(wing), 4], rightWing[UBound(wing), 4]
    for i = 1 to UBound(wing)
        leftWing[i, 1] = wing[i, 1]
        leftWing[i, 2] = -shipWidth / 2
        leftWing[i, 3] = wing[i, 3]
        leftWing[i, 4] = wing[i, 2]
        rightWing[i, 1] = wing[i, 1]
        rightWing[i, 2] = shipWidth / 2
        rightWing[i, 3] = wing[i, 3]
        rightWing[i, 4] = wing[i, 2]
    next i

    ' Make left and right struts from the wings to the pod
    leftStrut = {{MoveTo, -podDiameter / 2, 0, 0}, {DrawTo, -shipWidth / 2, 0, 0}}
    rightStrut = {{MoveTo, shipWidth / 2, 0, 0}, {DrawTo, podDiameter / 2, 0, 0}}

    ' Make the pod from two polygons at right angles
    poly = RegularPolygon(podSides, podDiameter / 2, 90)
    dim pod[podSides * 2 + 1, 4]
    for i = 1 to podSides + 1
        pod[i, 1] = poly[i, 1]
        pod[i, 2] = poly[i, 2]
        pod[i, 3] = poly[i, 3]
        pod[i, 4] = 0
    next i
    for i = 2 to podSides + 1
        j = i + podSides
        pod[j, 1] = poly[i, 1]
        pod[j, 2] = 0
        pod[j, 3] = poly[i, 3]
        pod[j, 4] = poly[i, 2]
    next i

    ' Assemble the ship
    tie = AppendArrays(rightWing, rightStrut)
    tie = AppendArrays(tie, pod)
    tie = AppendArrays(tie, leftStrut)
    tie = AppendArrays(tie, leftWing)
    return tie
endfunction

function NewShip()
    dim ship[1, 2]
    ship[1, 1] = Lines3DSprite(TieFighter(shipWidth, shipHeight, podDiameter, 6, 8))
    ' Choose a distance from us between 150 and 300 meters
    z = rand() mod 150 + 150
    ' Choose an apparent position on the screen in meters (the screen is
    ' about 0.15 meters by 0.18 meters)
    x = (rand() mod (150 - shipWidth) - 75) / 1000.0
    y = (rand() mod (180 - shipHeight) - 90) / 1000.0
    ' Scale the apparent position on the screen to an actual translation based on
    ' the ship's z distance (and assuming the user sits 0.5 meters from the screen)
    x = x / 0.5 * (z + 0.5)
    y = y / 0.5 * (z + 0.5)
    ship[1, 2] = {x, y, z}
    call SpriteTranslate(ship[1, 1], ship[1, 2])
    ' Set the rotation of the ship
    call SpriteRotate(ship[1, 1], rand() mod 360, rand() mod 360, rand() mod 360)
    return ship
endfunction
