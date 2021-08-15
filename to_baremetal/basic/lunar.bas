' lunar

if version()  < 100 then
    print "You need a newer version of the Vectrex32 software to run this game"
    stop
endif

call IntensitySprite(100)

textSize = {40, 5}
call TextSizeSprite(textSize)
instructions = {{-50, 90, "INSTRUCTIONS"}, _
                {-80, 70, "JOYSTK IS THRUST"}, _
                {-80, 50, "BTNS 1&2 ROTATE"}, _
                {-80, 30, "BTN 4 EXITS"}, _
                {-80, 1, "PRESS BTN 1 TO START"}}
        
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

call Randomize

frameRate = GetFrameRate()

maxJoystick = 112 ' The maximum value the joystick can have

' These are the approximate dimensions of the screen for the normalTerrainScale
' as determined by the ScaleTest.bas program
normalTerrainScale = 60
normalScreenWidth = 520
normalScreenHeight = 650
screenHeight = normalScreenHeight
screenWidth = normalScreenWidth

zoomTerrainScale = 120
zoomScreenWidth = 260
zoomScreenHeight = 325

degToRads = 3.1415926 / 180

accel = 5.0 ' Acceleration from gravity
maxThrustAccel = 14.0 ' Maximum acceleration from thrust (not counting Abort)
maxThrustFuelCons = 8.0 ' 8 Fuel units/sec
rotationSpeed = 120.0 / frameRate ' The LEM can rotate once every 3 s, copying Atari

' Create the terrain. The X coordinates are in "LEM width" units, i.e. a line that's
' (1, 0) is long enough for the LEM to land on it. The Y coordinates range from 0 to 1 
terrainTemplate = {_
    {0,0.597884},{1.4,0.550265},{4.2,0.306878},{5.4,0.248677},{6.4,0.248677}, _
    {8.2,0.328042},{9.8,0.359788},{11.4,0.428571},{14.8,0.497354},{16.4,0.497354}, _
    {17.4,0.465608},{19.2,0.375661},{19.4,0.338624},{20.8,0.338624},{21.6,0.391534}, _
    {22.2,0.391534},{23.8,0.312169},{24.8,0.291005},{25.6,0.132275},{26.6,0.10582}, _
    {27.6,0.10582},{29.8,0.15873},{32.4,0.291005},{32.8,0.333333},{34.4,0.349206}, _
    {36.8,0.444444},{38.2,0.587302},{39.8,0.587302},{43.2,0.677249},{43.8,0.84127}, _
    {44.8,0.94709},{46,1},{47,1},{48.2,0.952381},{49,0.952381},{50.6,0.862434}, _
    {51.6,0.846561},{52.8,0.740741},{54.6,0.698413},{55.6,0.62963},{57,0.62963}, _
    {57.2,0.550265},{58.6,0.465608},{61.2,0.322751},{61.2,0.216931},{62.8,0.121693}, _
    {63.6,0.121693},{64,0.058201},{66,0.005291},{72.4,0.005291},{72.4,0.047619}, _
    {73.8,0.116402},{73.8,0.164021},{74.6,0.169312},{76.2,0.259259},{77.8,0.259259}, _
    {78.4,0.280423},{79,0.280423},{81,0.137566},{83.6,0.026455},{87.4,0.031746}, _
    {89,0},{92.4,0},{93,0.116402},{92.8,0.169312},{93.8,0.169312},{94,0.206349}, _
    {96.2,0.306878},{98.4,0.407407},{99.8,0.386243},{101,0.386243},{102,0.402116}, _
    {102.4,0.502645},{104,0.52381},{104.8,0.587302} _
}

' To help with scrolling the terrain, append a second copy of it onto the first
terrainTemplateWidth = terrainTemplate[ubound(terrainTemplate), 1]
terrainTemplateHeight = 0
terrainTemplate = AppendArrays(terrainTemplate, terrainTemplate)
for i = ubound(terrainTemplate) / 2 + 1 to ubound(terrainTemplate)
    terrainTemplate[i, 1] = terrainTemplate[i, 1] + terrainTemplateWidth
    terrainTemplateHeight = max(terrainTemplate[i, 2], terrainTemplateHeight)
next i

' Copy and scale the terrain into "World" coordinates". The world coordinates
' map 1:1 to screen coordinates, such that the terrain is twice the width of
' the screen and half the height
xmagnify = screenWidth / (terrainTemplateWidth / 2)
ymagnify = (screenHeight / 2) / terrainTemplateHeight
dim terrain[ubound(terrainTemplate), 3]
for i = 1 to ubound(terrainTemplate)
    terrain[i, 1] = 1
    terrain[i, 2] = int(terrainTemplate[i, 1] * xmagnify)
    terrain[i, 3] = int(terrainTemplate[i, 2] * ymagnify)
next i
terrain[1, 1] = 0 ' The first line should be a MoveTo
terrainWidth = terrain[ubound(terrain), 2] / 2
terrainHeight = int(terrainTemplateHeight * ymagnify)

windowSize = {screenWidth, screenHeight}
' The buffer zones are areas on the left and right of the screen. When the LEM goes into
' them, the terrain scrolls
bufferZoneWidth = windowSize[1] / 5
bufferZoneHeight = windowSize[2] / 6

initialAltitude = terrainHeight * 1.8
initialXPos = terrainWidth / 8
initialHSpeed = terrainWidth / 45 ' Initial speed is fast enough to cross the terrain in 45 seconds
initialFuel = 750
score = 0

' Set up the sprites for drawing the terrain.
terrainScale = ScaleSprite(normalTerrainScale)
lowerLeft = MoveSprite(-screenWidth / 2, -screenHeight / 2)
terrainPos = MoveSprite(0, 0)
terrainLines = LinesSprite(terrain)
' The terrain and the LEM's altitude are in World coordinates
' The terrain's X coordinate starts at 0 and goes up. To select
' what part of the terrain we want to display on the screen, we
' need to subtract a number from the terrain's X coordinates.
' So terrainTranslate's X coordinate will always be negative
terrainTranslate = {0, 0}
call SpriteTranslate(terrainLines, terrainTranslate)
' Clip the terrain lines to the drawable screen
call SpriteClip(terrainLines, {{0, 0}, {screenWidth, screenHeight}})

' Define the dimensions of the LEM. The lemSpecs array specifies {width of ascent module, 
' width of descent module, height of descent module, width of pads}. In the terrain template,
' a width of 1.0 was a safe landing site. We scaled that by xmagnify to get World coordinates.
' So we scale the LEM by xmagnify, too, but multiply by 0.9 to give a little breathing room
' on the landing site
lemWidth = xmagnify * 0.9
lemSpecs = {lemWidth * 0.5, lemWidth * 0.5, lemWidth * 0.25, lemWidth * 0.1}
' Get the lines for the LEM with different thrusts
lemArrays = {LEM(0, lemSpecs), LEM(1, lemSpecs), _
    LEM(2, lemSpecs), LEM(3, lemSpecs), _
    LEM(4, lemSpecs)}

' Figure out the LEM height
lemYMax = 0
lemYMin = 0
sampleLEM = lemArrays[1]
for i = 1 to UBound(lemArrays[1])
    lemYMax = max(lemYMax, sampleLEM[i, 3])
    lemYMin = min(lemYMin, sampleLEM[i, 3])
next i
lemHeight = lemYMax - lemYMin

' Create the sprites for drawing the LEM
call ReturnToOriginSprite()
lemMoveScale = ScaleSprite(normalTerrainScale)
lemPos = MoveSprite(0, 0)
' We draw the LEM at a scale of 10 so that we can show fine detail
lemScale = 10
call ScaleSprite(lemScale)


' Make LEM sprites
lems = {LinesSprite(lemArrays[1]), LinesSprite(lemArrays[2]), LinesSprite(lemArrays[3]), _
        LinesSprite(lemArrays[4]), LinesSprite(lemArrays[5])}
' We're drawing the terrain at one Scale and drawing the LEM at a different Scale. We do that
' because the level of detail we need for each is different. But we want them to appear
' on the screen in their proper sizes. So we magnify the LEM to counteract the Scale difference. 
' But the terrain is huge (mountains, y'know) and the LEM is small. To make the LEM more visible
' we have to exaggerate its size. So we magnify it by the difference between the terrain and the LEM
' Scales, and then we double that to exaggerate.
' (BTW, when we zoom in on the terrain, we're doubling the scale we draw the terrain at. So
' our exaggeration of the LEM's size is actually just right when we've zoomed.)
lemMagnify = normalTerrainScale / lemScale * 2
for i = 1 to ubound(lems)
    call SpriteSetMagnification(lems[i], lemMagnify)
next i
        
' If (when) the LEM explodes, we need to show fragments
fragmentData = {AscentModule(lemSpecs), DescentModule(lemSpecs), Legs(lemSpecs)}
dim fragments[ubound(fragmentData), 5] ' Each fragment has a ReturnToOrigin sprite, a Scale sprite, a Move sprite, another Scale sprite and a Lines sprite
' Magnify the fragments the same as the LEM             
for i = 1 to ubound(fragmentData)
    fragments[i, 1] = ReturnToOriginSprite()
    fragments[i, 2] = ScaleSprite(zoomTerrainScale)
    fragments[i, 3] = MoveSprite(0, 0)
    fragments[i, 4] = ScaleSprite(10)
    fragments[i, 5] = LinesSprite(fragmentData[i])
    call SpriteSetMagnification(fragments[i, 5], lemMagnify)
next i
             
fuel = initialFuel

' Show the LEM status
call ReturnToOriginSprite()
statsIntensity = IntensitySprite(100)
textSize = {40, 5}
statsTextSize = TextSizeSprite(textSize)
statsText = {{-128, 127, "SCORE     0"}, {-128, 117, "TIME   0:00"}, {-127, 107, "FUEL   0000"}, _
             {45, 127, "ALTITUDE 0000"}, {45, 117, "HSPEED   0000 >"}, {45, 107, "VSPEED   0000 c"}}
stats = TextListSprite(statsText)
         
' Show the success or failure message
msgRtn = ReturnToOriginSprite()
msgText = {{-64, 10, "LAND OR CRASH MESSAGE LINE 1"}, {-64, -10, "LAND OR CRASH MESSAGE LINE 1"}}
msg = TextListSprite(msgText)
call SpriteEnable(msgRtn, false)
call SpriteEnable(msg, false)         

' Play rounds until the player runs out of fuel
repeat
    ' Set up the initial flight parameters
    lemWorldPos = {initialXPos, initialAltitude}
    terrainTranslate[1] = 0
    terrainTranslate[2] = 0
    call SpriteMove(lemPos, 0, 0)
    hspeed = initialHSpeed ' positive hspeed is to the left
    vspeed = 0.0 ' positive vspeed is up
    time = 0
    frames = 0
    landed = false
    frameCount = 0

    ' Only draw the LEM with zero thrust
    call SpriteEnable(lems[1], true)
    for i = 2 to UBound(lems)
        call SpriteEnable(lems[i], false)
    next i
    currentLEM = lems[1]
    call SpriteSetRotation(currentLEM, 90)
    thrustAngle = (SpriteGetRotation(currentLEM) - 90) * degToRads

    ' Don't show the fragments (yet :-) )
    for i = 1 to ubound(fragments)
        for j = 1 to ubound(fragments, 2)
            call SpriteEnable(fragments[i, j], false)
        next j
    next i

    ' Do forever (or until he lands or crashes)
    while 1
        ' Wait until it's time to prepare the next frame
        controls = WaitForFrame(JoystickAnalog, Controller1, JoystickX + JoystickY)
        frameCount = frameCount + 1
        
        if controls[1, 6] then
            stop
        endif
        
        if not landed then
            ' If the Left or Right button is pressed, rotate the LEM at a speed
            ' of 1 revolution per 3.5 seconds (approx the same rate as Atari's game)
            if controls[1, 3] then
                call SpriteRotate(currentLEM, rotationSpeed)
            endif
            if controls[1, 4] then
                call SpriteRotate(currentLEM, -rotationSpeed)
            endif
            ' Based on the joystick, choose a thrust. 128 is the maximum joystick value
            ' We split the 0-128 range into UBound(lems) - 1 choices. (The "- 1" is 
            ' because the highest thrust level is only available via the Abort button.)
            joyY = max(0, controls[1, 2])
            ' The joystick might be out of calibration and reading 16 even though it's in the center.
            ' So ignore joystick readings of 16 or less
            if joyY <= 16 then
                joyY = 0
            endif
            ' No fuel left means no thrust
            if fuel = 0 then
                joyY = 0
            endif
            thrustAccel = joyY * maxThrustAccel / maxJoystick
            thrustIndex = truncate(joyY * (UBound(lems) - 1) / maxJoystick) + 1
            fuel = max(fuel - (thrustAccel / maxThrustAccel) * maxThrustFuelCons / frameRate, 0)
            ' If we need to display a different LEM
            if lems[thrustIndex] != currentLEM then
                ' Make sure the LEM we're about to display has the same rotation as the LEM
                ' that's currently displayed
                call SpriteSetRotation(lems[thrustIndex], SpriteGetRotation(currentLEM))
                ' Hide the current LEM and display the new one
                call SpriteEnable(currentLEM, false)
                currentLEM = lems[thrustIndex]
                call SpriteEnable(currentLEM, true)
            endif
        endif
        
        frames = frames + 1
        if frames = frameRate then
            time = time + 1
            frames = 0
        endif
        
        ' Get the distance from the LEM (its center point) to the ground
        dist = DistanceToGround(terrain, lemWorldPos)
        ' See if the LEM has landed
        if abs(SpriteGetRotation(currentLEM)) < 5 and vspeed > -10 and dist <= lemHeight / 2 then
            ' Check whether we're on flat ground
            leftSide = lemWorldPos[1] - lemWidth / 2
            rightSide = lemWorldPos[1] + lemWidth / 2
            for i = 1 to ubound(terrain) - 1
                if terrain[i, 2] <= leftSide and terrain[i + 1, 2] > rightSide then
                    landed = true
                    landingAreaWidth = terrain[i + 1, 2] - terrain[i, 2]
                    exit for
                endif
            next
            if landed then
                call Landed(landingAreaWidth)
                if screenWidth = zoomScreenWidth then
                    call ZoomOut
                endif
                exit while                
           endif
        endif
        
        ' See if the LEM has crashed. This is an imprecise test: we're checking if the
        ' center point of the LEM is within its height / 2 of the surface, but we're
        ' not checking the orientation of the LEM. It's possible that at its current orientation,
        ' it's not touching the ground
        if dist <= lemHeight / 2 then
            call ExplodeLEM
            if screenWidth = zoomScreenWidth then
                call ZoomOut
            endif
            exit while
        endif
        
        ' If the LEM is close to the ground
        if dist < zoomScreenWidth * 0.5 then
            if screenWidth != zoomScreenWidth then
                call ZoomIn
            endif
        ' Else zoom out
        elseif dist > zoomScreenWidth * 0.75 then
            if screenWidth != normalScreenWidth then
                call ZoomOut
            endif
        endif

        ' Fall
        if not landed then
            vspeed = vspeed - accel / frameRate
        endif
        
        ' Apply thrust
        ' Round thrustAngle to the nearest 5 degrees
        degThrustAngle = (SpriteGetRotation(currentLEM) - 90)
        degThrustAngle = Round(degThrustAngle / 5.0) * 5
        thrustAngle = degThrustAngle * degToRads
        hspeed = hspeed - cos(thrustAngle) * thrustAccel / frameRate
        ' If the user is not applying horizontal thrust and the hspeed is near zero
        if (degThrustAngle = -90 or thrustAccel = 0) and Round(hspeed) = 0 then
            ' Set it to zero so the user doesn't see horizontal motion when the stats
            ' say his hspeed is zero
            hspeed = 0
        endif
        vspeed = vspeed - sin(thrustAngle) * thrustAccel / frameRate
        
        ' Update the position
        lemWorldPos[1] = lemWorldPos[1] + hspeed / frameRate
        lemWorldPos[2] = max(0, lemWorldPos[2] + vspeed / frameRate)
        
        ' If the LEM is approaching the edge of the window, move the window
        leftBufferZone = -terrainTranslate[1] + bufferZoneWidth
        rightBufferZone = -terrainTranslate[1] + windowSize[1] - bufferZoneWidth
        if lemWorldPos[1] > rightBufferZone then
            terrainTranslate[1] = terrainTranslate[1] - (lemWorldPos[1] - rightBufferZone)
        ' Elseif the LEM is approaching the left edge of the window
        elseif lemWorldPos[1] < leftBufferZone then
            terrainTranslate[1] = terrainTranslate[1] + leftBufferZone - lemWorldPos[1]
        endif
        call WrapAround
        bottomBufferZone = -terrainTranslate[2] + bufferZoneHeight - 1
        topBufferZone = -terrainTranslate[2] + windowSize[2] - bufferZoneHeight
        if lemWorldPos[2] > topBufferZone then
            terrainTranslate[2] = terrainTranslate[2] - (lemWorldPos[2] - topBufferZone)
            if screenWidth = normalScreenWidth and terrainTranslate[2] < 0 then
                terrainTranslate[2] = 0
            endif
        ' Elseif the LEM is approaching the bottom edge of the window
        elseif lemWorldPos[2] < bottomBufferZone then
            terrainTranslate[2] = min(0, terrainTranslate[2] + bottomBufferZone - lemWorldPos[2])
        endif

        lemMoveX = lemWorldPos[1] + terrainTranslate[1] - screenWidth / 2
        lemMoveY = lemWorldPos[2] + terrainTranslate[2] - screenHeight / 2
        call SpriteMove(lemPos, lemMoveX, lemMoveY)
        if (lemMoveY > screenHeight / 2 + lemHeight) then
            call SpriteEnable(currentLEM, false)
            call SpriteEnable(lemPos, false)
        else
            call SpriteEnable(currentLEM, true)
            call SpriteEnable(lemPos, true)
        endif
        
        ' Update the stats
        seconds = time mod 60
        minutes = time / 60
        statsText[2, 3] = "TIME  " + RightJustify(minutes + "", 2, " ") + ":" + RightJustify(seconds + "", 2, "0")
        statsText[3, 3] = "FUEL   " + RightJustify(int(fuel) + "", 4, " ")
        statsText[4, 3] = "ALTITUDE " + RightJustify(int(lemWorldPos[2]) + "", 4, " ")
        statsText[5, 3] = "HSPEED   " + RightJustify(abs(Round(hspeed)) + "", 4, " ")
        if hspeed < 0 then
            statsText[5, 3] = statsText[5, 3] + " <"
        elseif hspeed > 0
            statsText[5, 3] = statsText[5, 3] + " >"
        endif
        statsText[6, 3] = "VSPEED   " + RightJustify(abs(Round(vspeed)) + "", 4, " ")
        if vspeed < 0 then
            statsText[6, 3] = statsText[6, 3] + " c"
        elseif vspeed > 0
            statsText[6, 3] = statsText[6, 3] + " a"
        endif
    endwhile
until fuel <= 0

' Create the octagon for the ascent module, rotated so it's flat on the base. 
function AscentModule(lemSpecs)
    return RegularPolygon(8, lemSpecs[1] / 2, 360.0 / 16)
endfunction

' For the descent stage, we move to a corner then draw a 
' rectangle
function DescentModule(lemSpecs)
    halfWidth = lemSpecs[2] / 2
    halfHeight = lemSpecs[3] / 2
    return {{0, -halfWidth, halfHeight}, {1, halfWidth, halfHeight}, _
            {1, halfWidth, -halfHeight}, {1, -halfWidth, -halfHeight}, {1, -halfWidth, halfHeight}}
endfunction

function Legs(lemSpecs)
    halfWidth = lemSpecs[1] / 2
    leftLeg = {{0, -halfWidth, -lemSpecs[3]}, {1, -lemSpecs[1], -lemSpecs[1]}, _
               {0, -lemSpecs[1] - lemSpecs[4] / 2, -lemSpecs[1]}, {1, -lemSpecs[1] + lemSpecs[4] / 2, -lemSpecs[1]}}
	rightLeg = {{0, -leftLeg[1, 2], leftLeg[1, 3]}, {1, -leftLeg[2, 2], -lemSpecs[1]}, _
                {0, -leftLeg[3, 2], -lemSpecs[1]}, {1, -leftLeg[4, 2], -lemSpecs[1]}}
	
	return AppendArrays(leftLeg, rightLeg)
endfunction

' Return an array of lines that draw a Lunar Module with the specified
' thrust coming out of its engine. The width of the LEM, including the
' legs, will be 1.0
function LEM(thrust, lemSpecs)
	halfWidth = lemSpecs[1] / 2
	bellHeight = lemSpecs[1] / 3
	' Create the ascent module. Raise it in the Y direction 
    ' so its base is at zero
	ascent = AscentModule(lemSpecs)
	call Offset(ascent, 0, lemSpecs[1] / 2)
	descent = DescentModule(lemSpecs)
    call Offset(descent, 0, -lemSpecs[3] / 2)
	' Draw the exhaust bell
	bell = {{0, lemSpecs[1] / 4, -lemSpecs[3]}, {1, halfWidth, -lemSpecs[3] - bellHeight}, _
            {1, -halfWidth, -lemSpecs[3] - bellHeight}, {1, -lemSpecs[1] / 4, -lemSpecs[3]}}
    ' Draw the exhaust flame
    if thrust then
        flame = {{0, bell[3, 2], bell[3, 3]}, _
                 {1, (bell[3, 2] + bell[2, 2]) / 2, bell[3, 3] - thrust * (lemSpecs[1] + lemSpecs[3] + bellHeight) / 4}, _
                 {1, bell[2, 2], bell[2, 3]}}
        bell = AppendArrays(bell, flame)
    endif
    legSection = Legs(lemSpecs)
	
    ' Combine all the parts into one array
	lem = AppendArrays(ascent, AppendArrays(descent, AppendArrays(bell, legSection)))
    
    ' When we draw the LEM, we're going to move the pen to the location where the center
    ' of the LEM is, then draw it. We need to offset the shapes so the center is at (0, 0)
    vcenter = (ascent[2, 3] + legSection[2, 3]) / 2
    call Offset(lem, 0, -vcenter)
    return lem
endfunction

' Find the distance between the LEM and any piece of the ground
function DistanceToGround(terrain, lemPos)
    ' Find the terrain line beneath the LEM
    for i = 1 to ubound(terrain) - 1
        if terrain[i, 2] <= lemPos[1] and lemPos[1] < terrain[i + 1, 2] then
            exit for
        endif
    next i
    
    ' Get the distance between that line and the LEM
    dist = Distance(lemPos, {{terrain[i, 2], terrain[i, 3]}, {terrain[i + 1, 2], terrain[i + 1, 3]}})
    ' Look at lines to the left of the LEM for shorter distances
    lookLeft = 1
    while i - lookLeft >= 1
        leftDist = Distance(lemPos, {{terrain[i - lookLeft, 2], terrain[i - lookLeft, 3]}, {terrain[i - lookLeft + 1, 2], terrain[i - lookLeft + 1, 3]}})
        if leftDist < dist then
            dist = leftDist
        else
            exit while
        endif
    endwhile
    ' Look at lines to the right of the LEM for shorter distances
    lookRight = 1
    while i + lookRight < ubound(terrain)
        rightDist = Distance(lemPos, {{terrain[i + lookRight, 2], terrain[i + lookRight, 3]}, {terrain[i + lookRight + 1, 2], terrain[i + lookRight + 1, 3]}})
        if rightDist < dist then
            dist = rightDist
        else
            exit while
        endif
    endwhile
    
    return dist
endfunction

sub Landed(surfaceLength)
    names = {"EAGLE", "INTREPID", "AQUARIUS", "ANTARES", "FALCON", "ORION", "CHALLENGER"}
    vspeed = 0
    hspeed = 0
    call SpriteEnable(currentLEM, false)
    thrustIndex = 1
    currentLEM = lems[thrustIndex]
    call SpriteEnable(currentLEM, true)
    call SpriteSetRotation(currentLEM, 0)

    ' The narrower the landing area, the more pointshe got
    points = 250 - int(surfaceLength / lemWidth) * 50
    ' Subtract points for hard landings
    points = points - int(sqrt(hspeed * hspeed + vspeed * vspeed) * 10)
    points = max(50, points)
    score = score + points
    statsText[1, 3] = "SCORE  " + RightJustify(score + "", 4, " ")
    fuel = fuel + int(points / 2)
    
    msgText[1, 3] = "THE " + names[rand() mod (ubound(names) - 1) + 1] + " HAS LANDED!"
    msgText[2, 3] = "+" + points + " POINTS"
    
    ' Display the message text
    call SpriteEnable(msgRtn, true)
    call SpriteEnable(msg, true) 
    ' Hide the stats; drawing the message and the stats is too much for the Vectrex
    call SpriteEnable(stats, false)
    
    ' Show the landing for 5 seconds
    for i = 1 to frameRate * 5
        call WaitForFrame(JoystickNone, ControllerNone, JoystickNone)
    next i
    
    ' Hide the message and show the stats
    call SpriteEnable(msgRtn, false)
    call SpriteEnable(msg, false)        
    call SpriteEnable(stats, true)
endsub

sub ExplodeLEM
    ' Hide the LEM
    call SpriteEnable(currentLEM, false)
    
    ' Show the fragments. Also set X and Y velocities for them
    dim velocities[ubound(fragments), 2], rotations[ubound(fragments)]
    speed = max(sqrt(hspeed * hspeed + vspeed * vspeed), initialHSpeed) * 3
    ' Go through each fragment
    for i = 1 to ubound(fragments)
        ' Enable all the sprites used by the fragment
        for j = 1 to ubound(fragments, 2)
            call SpriteEnable(fragments[i, j], true)
        next j
        call SpriteMove(fragments[i, 3], lemMoveX, lemMoveY)
        call SpriteTranslate(fragments[i, 5], {0, 0})
        direction = (rand() mod 180) * pi / 180
        velocities[i, 1] = cos(direction) * speed / frameRate
        velocities[i, 2] = sin(direction) * speed / frameRate
        rotations[i] = rand() mod 48 - 24
    next i
    
    fuelLoss = max(int(sqrt(hspeed * hspeed + vspeed * vspeed) * 2), 50)
    msgText[1, 3] = "YOU'RE DEAD! OH, AND YOU"
    msgText[2, 3] = "LOST " + fuelLoss + " GALLONS OF FUEL"
    fuel = fuel - fuelLoss
    
    ' Display the message
    call SpriteEnable(msgRtn, true)
    call SpriteEnable(msg, true)         
    ' Hide the stats; drawing the message and the stats is too much for the Vectrex
    call SpriteEnable(stats, false)
    
    ' Show the explosion for 5 seconds
    for i = 1 to frameRate * 5
        call WaitForFrame(JoystickNone, ControllerNone, JoystickNone)
        for f = 1 to ubound(fragments)
            call SpriteRotate(fragments[f, 5], rotations[f])
            x = velocities[f, 1] * i
            y = velocities[f, 2] * i
            if abs(x) > 1000 or abs(y) > 1000 then
                call SpriteEnable(fragments[f, 5], false)
            endif
            call SpriteTranslate(fragments[f, 5], {x, y})
        next f
    next i
    
    ' Hide the message and draw the stats
    call SpriteEnable(msgRtn, false)
    call SpriteEnable(msg, false) 
    call SpriteEnable(stats, true)
endsub

sub ZoomIn
    ' Zoom in. We'll configure the window so that the LEM is in the top middle
    screenWidth = zoomScreenWidth
    screenHeight = zoomScreenHeight
    windowSize = {screenWidth, screenHeight}
    bufferZoneWidth = windowSize[1] / 3
    bufferZoneHeight = windowSize[2] / 4
    terrainTranslate[1] = -(lemWorldPos[1] - zoomScreenWidth / 2)
    terrainTranslate[2] = min(0, -(lemWorldPos[2] - zoomScreenHeight * 0.75))
    call SpriteScale(terrainScale, zoomTerrainScale)
    call SpriteMove(lowerLeft, -screenWidth / 2, -screenHeight / 2)
    call SpriteClip(terrainLines, {{0, 0}, {screenWidth, screenHeight}})
    call SpriteScale(lemMoveScale, zoomTerrainScale)
endsub

sub ZoomOut
    screenWidth = normalScreenWidth
    screenHeight = normalScreenHeight
    windowSize = {screenWidth, screenHeight}
    bufferZoneWidth = windowSize[1] / 5
    bufferZoneHeight = windowSize[2] / 6
    terrainTranslate[1] = -(lemWorldPos[1] - normalScreenWidth / 2)
    terrainTranslate[2] = min(0, -(lemWorldPos[2] - normalScreenHeight * 0.75))
    call SpriteScale(terrainScale, normalTerrainScale)
    call SpriteMove(lowerLeft, -screenWidth / 2, -screenHeight / 2)
    call SpriteClip(terrainLines, {{0, 0}, {screenWidth, screenHeight}})
    call SpriteScale(lemMoveScale, normalTerrainScale)
endsub

sub WrapAround
    ' If the window is too far to the right, wrap around to the left
    if terrainTranslate[1] < -terrainWidth then
        terrainTranslate[1] = terrainTranslate[1] + terrainWidth
        lemWorldPos[1] = lemWorldPos[1] - terrainWidth
    ' If the window is too far to the right, wrap around to the left
    elseif terrainTranslate[1] > 0 then
        terrainTranslate[1] = terrainTranslate[1] - terrainWidth
        lemWorldPos[1] = lemWorldPos[1] + terrainWidth
    endif
endsub

' Right justify the str in a string len characters long, with the
' leftmost characters being the fill character
function RightJustify(str, length, fillChar)
    fill = ""
    for i = 1 to length - len(str)
        fill = fill + fillChar
    next i
    return fill + str
endfunction

