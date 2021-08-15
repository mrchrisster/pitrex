' The original MissileBreak OutVaders is a web-browser based game researched and
' modeled by Nathan McCoy and Jonathan S. Fox. Yoy can see it at 
' http://armorgames.com/play/12497/missilebreak-outvaders

if Version() < 114 then
    textSize = {40, 5}
    call TextSizeSprite(textSize)
    message = {{-50, 90, "YOU MUST UPGRADE"}, _
               {-80, 70, "TO VERSION 1.14"}, _
               {-80, 50, "TO RUN THIS GAME."}, _
               {-80, 30, "SEE HOW AT VECTREX32.COM."}, _
               {-80, 1, "PRESS BTN 4 TO EXIT"}}
            
    call TextListSprite(message)

    ' Wait for or button 4
    controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
    while controls[1, 6] = 0
        controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
    endwhile
    stop
endif

call Randomize

frameRate = 30
call SetFrameRate(frameRate)
ticksPerFrame = 960 / frameRate

invaderScale = 30
invaderScaleScreenWidth = 1030
invaderScaleScreenHeight = 1270

invaderWidth = invaderScaleScreenWidth / 17
invaderHeight = invaderScaleScreenHeight / 31
invaderColumnSpacing = invaderWidth
invaderRowSpacing = invaderHeight
invaderShapes1 = {({ _
    {MoveTo, -invaderWidth / 2, -invaderHeight / 2}, _
    {DrawTo, 0, invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, -invaderHeight / 2}, _
    {MoveTo, invaderWidth / 4, 0}, _
    {DrawTo, 0, -invaderHeight / 2}, _
    {DrawTo, -invaderWidth / 4, 0}}), _
    ({ _
    {MoveTo, -invaderWidth / 2, invaderHeight / 2}, _
    {DrawTo, 0, -invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, invaderHeight / 2}, _
    {MoveTo, invaderWidth / 4, 0}, _
    {DrawTo, 0, invaderHeight / 2}, _
    {DrawTo, -invaderWidth / 4, 0}})}
invaderShapes2 = {({ _
    {MoveTo, -invaderWidth / 2, -invaderHeight / 2}, _
    {DrawTo, -invaderWidth * 0.6 / 2, invaderHeight / 2}, _
    {DrawTo, invaderWidth * 0.6 / 2, invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, -invaderHeight / 2}, _
    {MoveTo, invaderWidth * 0.9 / 2, -invaderHeight / 4}, _
    {DrawTo, -invaderWidth * 0.9 / 2, -invaderHeight / 4}}), _
    ({ _
    {MoveTo, -invaderWidth / 2 * 0.6, -invaderHeight / 2}, _
    {DrawTo, -invaderWidth * 0.6 / 2, invaderHeight / 2}, _
    {DrawTo, invaderWidth * 0.6 / 2, invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2 * 0.6, -invaderHeight / 2}, _
    {MoveTo, invaderWidth * 0.9 / 2, -invaderHeight / 4}, _
    {DrawTo, -invaderWidth * 0.9 / 2, -invaderHeight / 4}})}
invaderShapes3 = {({ _
    {MoveTo, -invaderWidth / 2, 0}, _
    {DrawTo, -invaderWidth / 2, invaderHeight / 2}, _
    {DrawTo, -invaderWidth / 4, -invaderHeight / 2}, _
    {DrawTo, invaderWidth / 4, -invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, 0}, _
    {MoveTo, invaderWidth * 3 / 8, 0}, _
    {DrawTo, -invaderWidth * 3 / 8, 0}}), _
    ({ _
    {MoveTo, -invaderWidth / 2, 0}, _
    {DrawTo, -invaderWidth / 2, -invaderHeight / 2}, _
    {DrawTo, -invaderWidth * 5 / 12, 0}, _
    {DrawTo, -invaderWidth / 4, -invaderHeight / 2}, _
    {DrawTo, invaderWidth / 4, -invaderHeight / 2}, _
    {DrawTo, invaderWidth * 3 / 8, 0}, _
    {DrawTo, invaderWidth / 2, -invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, 0}, _
    {MoveTo, invaderWidth * 3 / 8, 0}, _
    {DrawTo, -invaderWidth * 3 / 8, 0}})}
invaderShapes4 = {({ _
    {MoveTo, -invaderWidth / 2, 0}, _
    {DrawTo, -invaderWidth / 2, invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, 0}, _
    {DrawTo, -invaderWidth / 2, 0}, _
    {MoveTo, -invaderWidth / 4, 0}, _
    {DrawTo, -invaderWidth / 4, -invaderHeight / 2}, _
    {DrawTo, -invaderWidth / 3, -invaderHeight / 2}, _
    {MoveTo, invaderWidth / 4, 0}, _
    {DrawTo, invaderWidth / 4, -invaderHeight / 2}, _
    {DrawTo, invaderWidth / 3, -invaderHeight / 2}}), _
    ({ _
    {MoveTo, -invaderWidth / 2, 0}, _
    {DrawTo, -invaderWidth / 2, invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, 0}, _
    {DrawTo, -invaderWidth / 2, 0}, _
    {MoveTo, -invaderWidth / 4, 0}, _
    {DrawTo, -invaderWidth / 3, -invaderHeight / 2}, _
    {DrawTo, -invaderWidth / 2, -invaderHeight / 2}, _
    {MoveTo, invaderWidth / 4, 0}, _
    {DrawTo, invaderWidth / 3, -invaderHeight / 2}, _
    {DrawTo, invaderWidth / 2, -invaderHeight / 2}})}
    
invaderShapes = {invaderShapes1, invaderShapes2, invaderShapes3, invaderShapes4}
    
cityScale = invaderScale
cityScaleScreenWidth = invaderScaleScreenWidth
cityScaleScreenHeight = invaderScaleScreenHeight
cityY = -cityScaleScreenHeight * 4 / 10

cityWidth = invaderWidth * invaderScale * 3 / cityScale / 2
cityHeight = invaderHeight * invaderScale / cityScale
cityShape = { _
    {MoveTo, 0, 0}, _
    {DrawTo, cityWidth / 5, cityHeight / 5}, _
    {DrawTo, cityWidth / 5, cityHeight / 2}, _
    {DrawTo, cityWidth / 4, cityHeight / 2}, _
    {DrawTo, cityWidth / 4, cityHeight}, _
    {DrawTo, cityWidth / 3, cityHeight}, _
    {DrawTo, cityWidth / 3, cityHeight / 7}, _
    {DrawTo, cityWidth / 2, cityHeight / 4}, _
    {DrawTo, cityWidth / 2, cityHeight * 3 / 4}, _
    {DrawTo, cityWidth * 3 / 4, cityHeight * 3 / 4}, _
    {DrawTo, cityWidth * 3 / 4, cityHeight / 4}, _
    {DrawTo, cityWidth, 0} _
    }
call Offset(cityShape, -cityWidth / 2, 0)

paddleScale = invaderScale
paddleScaleScreenWidth = invaderScaleScreenWidth
paddleScaleScreenHeight = invaderScaleScreenHeight
paddleWidth = 127 'cityWidth * cityScale * 3 / paddleScale / 2
paddleHeight = 2
paddleY = cityY * cityScale * 8 / paddleScale / 10
paddleShape = { _
    {MoveTo, 0, paddleY}, _
    {DrawTo, paddleWidth, paddleY}}

invaderColumns = 6
invaderRows = 4

' Keep track of whether each invader is dead or alive
dim invaders[invaderRows, invaderColumns]
' Also keep track which columns still have invaders
dim invadersPerColumn[invaderColumns]

' Create an explosion object. We'll be using it later
expl = Explosion($3f, 0, 0, 1)
' Create a noise for the missile hitting the paddle
bounce = Explosion($30, 0, 0, 30)

fontMetrics = GetFontMetrics()
fontHeight = fontMetrics[2]
fontAdvancement = fontMetrics[3]

intro = {{-80, 60, "JOYSTICK MOVES PADDLE"}, _
         {-80, 40, "PADDLE DEFENDS CITIES"}, _
         {-80, 20, "BTN 1 EXPLODES"}, _
         {2, 20, "REFLECTED MISSILES"}, _
         {-80, 1, "BTN 4 EXITS"}, _
         {-80, -40, "PRESS BTN 1 TO START"}}
         
textXOffset = -450
missileText = TextToLines("MISSILE ")
call Offset(missileText, 0, -fontHeight / 2)
commandText = TextToLines(" COMMAND")
call Offset(commandText, 0, -fontHeight / 2)
breakoutText = TextToLines("BREAK OUT")
call Offset(breakoutText, 0, -fontHeight / 2)
spaceInText = TextToLines("SPACE IN")
call Offset(spaceInText, 0, -fontHeight / 2)
vadersText = TextToLines("VADERS")
call Offset(vadersText, 0, -fontHeight / 2)

' Get the full text
title = TextToLines("MISSILEBREAK OUTVADERS")
call Offset(title, textXOffset, 0)

gameOverText = TextToLines("GAME OVER")
call Offset(gameOverText, -fontAdvancement * 9 / 2, -fontHeight / 2)

' Wait until button 1 is not pressed
repeat
    controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
until controls[1, 3] = 0
            
textSize = {40, 5}
textScale = 32

twoSecs = GetFrameRate() * 2
       
' Loop forever displaying the intro and playing games (exit when button 4 is pressed)
while true

    frameCounter = 0
    
    ' Alternate between showing the game title and showing the instructions
    showInstructionsTime = GetFrameRate() * 8
    showLogoTime = GetFrameRate() * 5
    while true
        call ClearScreen
        call IntensitySprite(80)
        
        if frameCounter mod (showLogoTime + showInstructionsTime) >= showLogoTime then
            ' Display the intro message
            call TextSizeSprite(textSize)
            call TextListSprite(intro)
            
        else
            ' Animate the logo
            call IntensitySprite(80)
            call ScaleSprite(textScale)
            ' Figure out the time position in the logo animation
            animationFrame = float(frameCounter) mod (showLogoTime + showInstructionsTime)

            ' If we're still moving the text
            if animationFrame < twoSecs then
                missileTextOffset = {textXOffset, max(0, int(600 - animationFrame * 600 / twoSecs))}
                commandTextOffset = {missileTextOffset[1] + 7 * fontAdvancement, missileTextOffset[2]}
                breakoutTextOffset = {commandTextOffset[1], commandTextOffset[2]}
                spaceInTextOffset = {breakoutTextOffset[1] + 1 * fontAdvancement, -missileTextOffset[2]}
                vadersTextOffset = {spaceInTextOffset[1] + 8 * fontAdvancement, spaceInTextOffset[2]}
                
                if missileTextOffset[2] < fontHeight / 2 then
                    breakoutSprite = LinesSprite(breakoutText)
                    call SpriteTranslate(breakoutSprite, breakoutTextOffset)
                    show = fontHeight / 2 - missileTextOffset[2] + 1
                    call SpriteClip(breakoutSprite, {{-1000, show}, {1000, -show}})
                    call ReturnToOriginSprite()
                else
                    show = 0
                endif
                
                missileSprite = LinesSprite(missileText)
                call SpriteTranslate(missileSprite, missileTextOffset)
                call ReturnToOriginSprite()
                commandSprite = LinesSprite(commandText)                
                call SpriteTranslate(commandSprite, commandTextOffset)
                call SpriteClip(commandSprite, {{-1000, 1000}, {1000, show}})
                
                call ReturnToOriginSprite()
                spaceInSprite = LinesSprite(spaceInText)
                call SpriteTranslate(spaceInSprite, spaceInTextOffset)
                call SpriteClip(spaceInSprite, {{-1000, -show}, {1000, -1000}})
                call ReturnToOriginSprite()
                vadersSprite = LinesSprite(vadersText)
                call SpriteTranslate(vadersSprite, vadersTextOffset)
            
            ' Else (we're done moving the text) just show a single string
            else
                call LinesSprite(title)
            endif
        endif
        
        controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
        if controls[1, 6] then
            stop
        endif
    
        ' If button 1 is pressed, break out of the intro screens
        if controls[1, 3] then
            exit while
        endif
        
        frameCounter = frameCounter + 1
    endwhile

    ' These are the speeds of the missiles launched by the invaders. Missiles launched from the
    ' top row are faster than those launched from the bottom
    missileScale = invaderScale
    missileScaleScreenWidth = invaderScaleScreenWidth
    missileScaleScreenHeight = invaderScaleScreenHeight
    ' Figure out how many units a missile should travel per frame
    missileSpeeds = {int(missileScaleScreenHeight / 3.5 / GetFrameRate()), _
        missileScaleScreenHeight / 4 / GetFrameRate(), _
        missileScaleScreenHeight / 5 / GetFrameRate(), _
        missileScaleScreenHeight / 5 / GetFrameRate()}
    maxMissileLength = 5000

    missileScalePaddleY = paddleY * paddleScale / missileScale

    ' Keep track of each city
    cityCount = 4
    dim cities[cityCount]
    for city = 1 to cityCount
        cities[city] = true
    next city
    citiesLeft = cityCount
    citySpacing = (cityScaleScreenWidth - cityWidth * cityCount) / (cityCount + 1)

    resetPenInterval = 6
    cityResetPenInterval = 4

    explosionStartRadius = 1
    explosionEndRadius = invaderWidth * 3 / 4
    ' Make the explosion reach its full size in 1/2 second
    explosionIncrement = float(explosionEndRadius) / (GetFrameRate() / 2)

    ' Each row of the missiles array is
    ' {start X, start Y, angle, start frame count, missile speed, reflected flag, current X, current Y, inUse}
    dim missiles[10, 9]
    activeMissiles = 0
    for i = 1 to UBound(missiles)
        missiles[i, 9] = false
    next
    ' Are there any missiles fired by an invader?
    invaderMissiles = false

    ' Each row of the explosions array is
    ' {X, Y, radius, 1 or -1 for expanding/shrinking, inUse}
    dim explosions[5, 5]
    for i = 1 to UBound(explosions)
        explosions[i, 5] = false
    next
    activeExplosions = 0

    enableBtn1 = GetFrameRate() / 2
    frameCounter = 0

    ' Set up scoring
    score = 0
    scoreText = {{-80, 127, "SCORE: " + score}}

    ' How many points do you get for destroying an invader on a given row?
    points = {25, 20, 15, 10}

    bonusCityIncrement = 0
    for i = 1 to UBound(points)
        bonusCityIncrement = bonusCityIncrement + points[i] * invaderColumns
    next i

    survivingCityCredit = points[1] * 4

    bonusCityIncrement = bonusCityIncrement + survivingCityCredit * 2
    bonusCity = bonusCityIncrement

    invaderShapeSelection = 1
    
    ' Play rounds until all the cities are gone
	round = 0
    while citiesLeft do
        frameCounter = 0
		round = round + 1
        
        for column = 1 to invaderColumns
            for row = 1 to invaderRows
                invaders[row, column] = true
            next
            invadersPerColumn[column] = invaderRows
        next
        invadersLeft = invaderRows * invaderColumns
        
        ' Initial altitude of the highest invader
        invaderAltitude = invaderScaleScreenHeight / 2 - invaderHeight * 4
        ' X offset of the invaders
        invaderX = 0
        ' Initial direction of their movement
        movingLeft = false
        invaderLeftmostPosition = InvaderRect(1, 1)
        invaderLeftmostPosition = invaderLeftmostPosition[1]
        invaderRightmostPosition = -invaderLeftmostPosition
        
        invaderMissiles = false
        
        ' Play a round until all the cities are gone and all the missiles are gone
        while (citiesLeft and invadersLeft) or activeMissiles or activeExplosions do
        
            scoreText[1, 3] = "SCORE: " + score
            
            controls = WaitForFrame(JoystickAnalog, Controller1, JoystickX, 0)
            frameCounter = frameCounter + 1
            
            playExplosion = false
            playBounce = false
            
            ' If button 4 is pressed, end the game
            if controls[1, 6] then
                stop
            endif
            ' If we're in btn1's refractory period
            if enableBtn1 then
                enableBtn1 = enableBtn1 - 1
                controls[1, 3] = 0
            ' Elseif btn1 is pressed
            elseif controls[1, 3] then
                ' set up a refractory period
                enableBtn1 = GetFrameRate() / 3
            endif

            ' Start with an empty display list
            call ClearScreen
            
            ' Build the display list
            call IntensitySprite(80)
            
            ' Display the aliens who are still alive
            call ScaleSprite(invaderScale)
            for row = 1 to invaderRows
                rowLines = nil
                for column = 1 to invaderColumns
                    ' If this invader is alive
                    if invaders[row, column] then
                        shape = invaderShapes[row]
                        v = CopyArray(shape[invaderShapeSelection])
                        coords = InvaderCoords(row, column)
                        call Offset(v, coords[1], coords[2])
                        if IsNil rowLines then
                            rowLines = v
                        else
                            rowLines = AppendArrays(rowLines, v)
                        endif
                        
                        ' If we've accumulated a certain number of invaders on this row, draw them.
                        ' Any more and we start getting pen drift
                        if UBound(rowLines) = resetPenInterval then
                            call LinesSprite(rowLines)
                            rowLines = nil
                            call ReturnToOriginSprite()
                        endif
                    endif            
                next column
                if not isnil rowLines then
                    call LinesSprite(rowLines)
                    rowLines = nil
                    call ReturnToOriginSprite()
                endif
            next row

            ' Display the cities that still exist
            call ScaleSprite(cityScale)
            dim cityLines[0, 3]
            for city = 1 to cityCount
                ' If this city exists
                if cities[city] then
                    v = CopyArray(cityShape)
                    call Offset(v, CityX(city), cityY)
                    cityLines = AppendArrays(cityLines, v)
                    ' If we've accumulated a certain number of cities, draw them.
                    ' Any more and we start getting pen drift
                    if UBound(cityLines) = cityResetPenInterval then
                        call LinesSprite(cityLines)
                        dim cityLines[0, 3]
                        call ReturnToOriginSprite()
                    endif
                endif            
            next city
            if UBound(cityLines) then
                call LinesSprite(cityLines)
                call ReturnToOriginSprite
            endif
            
            ' Draw the paddle
            call ScaleSprite(paddleScale)
            paddleX = controls[1, 1] * (paddleScaleScreenWidth - paddleWidth * 8 / 10) / 2 / 128 - paddleWidth / 2
            call Offset(paddleShape, paddleX - paddleShape[1, 2], 0)
            call IntensitySprite(120)
            call LinesSprite(paddleShape)
            call IntensitySprite(80)

            ' Draw the score
            scoreSprite = Text2ListSprite(scoreText)
            
            ' If button 1 was pressed, detonate all the reflected missiles
            if controls[1, 3] then
                i = 1
                ' Go through all the missiles
                while i <= UBound(missiles)
                    ' If it's a reflected missile
                    if missiles[i, 9] and missiles[i, 6] then
                        ' Explode it
                        call AddExplosion(missiles[i, 7], missiles[i, 8])
                        call RemoveMissile(i)
                        continue while
                    endif
                    i = i + 1
                endwhile
            endif
            
            ' Go through all the missiles. Check for collisions and bounces
            for i = 1 to UBound(missiles)
                
                ' If this missile is not active, skip it
                if missiles[i, 9] = false then
                    continue for
                endif
                
                ' Each row in the missile array has {originX, originY, angle, startFrame, speed, isReflected, currentX, currentY, inUse}
                originX = missiles[i, 1]
                originY = missiles[i, 2]
                sangle = sin(missiles[i, 3])
                cangle = cos(missiles[i, 3])
                oldEndX = missiles[i, 7]
                oldEndY = missiles[i, 8]
                length = (frameCounter - missiles[i, 4]) * missiles[i, 5]
                endX = originX + cangle * length
                endY = originY + sangle * length
                missiles[i, 7] = endX
                missiles[i, 8] = endY
                
                ' Get the line segment from the last missile position to the
                ' current one
                missileSegment = {{oldEndX, oldEndY}, {endX, endY}}
                
                ' Check if the missile has hit the left side
                intersect = Intersection(missileSegment, {-missileScaleScreenWidth / 2, 0})
                if not isnil intersect then
                    missiles[i, 1] = intersect[1] + 0.1
                    missiles[i, 2] = intersect[2]
                    missiles[i, 3] = pi - missiles[i, 3]
                    missiles[i, 4] = frameCounter
                    missiles[i, 7] = missiles[i, 1]
                    missiles[i, 8] = missiles[i, 2]
					' Check whether it's also bouncing off the top
					if intersect[2] >= missileScaleScreenHeight / 2 and missiles[i, 3] > 0 then
						missiles[i, 3] = -missiles[i, 3]
					endif
                    continue for
                endif
                ' Check if the missile has hit the right side
                intersect = Intersection(missileSegment, {missileScaleScreenWidth / 2, 0})
                if not isnil intersect then
                    missiles[i, 1] = intersect[1] - 0.1
                    missiles[i, 2] = intersect[2]
                    missiles[i, 3] = pi - missiles[i, 3]
                    missiles[i, 4] = frameCounter
                    missiles[i, 7] = missiles[i, 1]
                    missiles[i, 8] = missiles[i, 2]
					' Check whether it's also bouncing off the top
					if intersect[2] >= missileScaleScreenHeight / 2 and missiles[i, 3] > 0 then
						missiles[i, 3] = -missiles[i, 3]
					endif
                    continue for
                endif
                ' Check if the missile has hit the paddle
                intersect = Intersection(missileSegment, {0, missileScalePaddleY})
                if not isnil intersect then
                    if intersect[1] >= paddleX and intersect[1] <= paddleX + paddleWidth then
                    
                        ' If this missile was fired by an invader
                        if missiles[i, 6] = false then
                            ' It's no longer an invader missile
                            invaderMissiles = false
                        endif
                        
                        missiles[i, 1] = intersect[1]
                        missiles[i, 2] = intersect[2] + 0.1
                        
                        ' Imagine that the paddle is a semicircle. The reflected angle
                        ' of the missile is based on what part of the semicircle it
                        ' hits
                        cosine = (intersect[1] - (paddleX + paddleWidth / 2)) / (paddleWidth * 1.15 / 2)
                        theta = acos(cosine)
                        missiles[i, 3] = theta
                        missiles[i, 4] = frameCounter
                        ' The speed is also based on what part of the paddle it hit.
                        ' Hitting the center gives the slowest speed; hitting the edge 
                        ' gives the fastest
                        missiles[i, 5] = missileSpeeds[round((1 - abs(cosine)) * (UBound(missileSpeeds) - 1)) + 1]
                        missiles[i, 6] = true
                        missiles[i, 7] = missiles[i, 1]
                        missiles[i, 8] = missiles[i, 2]
                        
                        playBounce = true
                        continue for
                    endif
                endif
                ' Check if the missile has hit the level of the cities
                intersect = Intersection(missileSegment, {0, cityY})
                if not isnil intersect then
                    ' Remove the missile. Add an explosion
                    if missiles[i, 6] = false then
                        invaderMissiles = false
                    endif
                    call RemoveMissile(i)
                    call AddExplosion(intersect[1], intersect[2])
                    continue for
                endif
				' Check if the missile has gone below the ground
				if endY < -missileScaleScreenHeight / 2 then
                    if missiles[i, 6] = false then
                        invaderMissiles = false
                    endif
					call RemoveMissile(i)
					continue for
				endif
                ' Check if the missile has hit the top of the screen
                intersect = Intersection(missileSegment, {0, missileScaleScreenHeight / 2})
                if not isnil intersect then
                    ' If there are invaders left, the missile bounces
                    if invadersLeft then
                        missiles[i, 1] = intersect[1]
                        missiles[i, 2] = intersect[2] - 0.1
                        missiles[i, 3] = -missiles[i, 3]
                        missiles[i, 4] = frameCounter
                        missiles[i, 7] = missiles[i, 1]
                        missiles[i, 8] = missiles[i, 2]

                        continue for
                    ' Else (no invaders left)
                    else
                        ' The missile vanishes
                        call RemoveMissile(i)
                        continue for
                    endif
                endif
                
                ' If this is a reflected missile
                if missiles[i, 6] then
                    ' Check if the missile has hit an invader
                    invader = ClosestInvader(missiles[i, 7], missiles[i, 8])
                    if invader[1] >= 1 and invader[1] <= invaderRows and _
                       invader[2] >= 1 and invader[2] <= invaderColumns and _
                       invaders[invader[1], invader[2]] then
                        rect = InvaderRect(invader[1], invader[2])
                        if PtInRect({{rect[1], rect[2]}, {rect[3], rect[4]}}, {missiles[i, 7], missiles[i, 8]}) then
                            ' Explode the invader
                            coords = InvaderCoords(invader[1], invader[2])
                            invaders[invader[1], invader[2]] = false
                            invadersLeft = invadersLeft - 1
                            score = score + points[invader[1]]
                            invadersPerColumn[invader[2]] = invadersPerColumn[invader[2]] - 1
                            call AddExplosion(coords[1], coords[2])
                            ' Change the missile into one emitted by the invader. Its speed
                            ' increases
                            missiles[i, 1] = coords[1]
                            missiles[i, 2] = coords[2]
                            angle = -(Rand() mod 180) * 3.14159 / 180
                            missiles[i, 3] = angle
                            missiles[i, 4] = frameCounter - 1
                            missiles[i, 5] = missiles[i, 5] * 1.4
                            missiles[i, 7] = coords[1]
                            missiles[i, 8] = coords[2]

                            continue for
                        endif
                    endif
                endif
                
            next i
            
            ' Process the explosions
            for i = 1 to UBound(explosions)
                if explosions[i, 5] = false then
                    continue for
                endif
                
                explosions[i, 3] = explosions[i, 3] + explosionIncrement * explosions[i, 4]
                ' If the explosion is expanding and it's reached maximum size
                if explosions[i, 4] > 0 and explosions[i, 3] >= explosionEndRadius then
                    ' Change it to decreasing
                    explosions[i, 4] = -1
                ' Else if it's less than zero
                elseif explosions[i, 3] <= 0
                    call RemoveExplosion(i)
                    continue for
                endif
                
                ' Check whether the explosion has swallowed an invader
                invader = ClosestInvader(explosions[i, 1], explosions[i, 2])
                center = {explosions[i, 1], explosions[i, 2]}
                radius = explosions[i, 3] * 0.9
                for row = max(invader[1] - 1, 1) to min(invader[1] + 1, invaderRows)
                    for column = max(invader[2] - 1, 1) to min(invader[2] + 1, invaderColumns)
                        if invaders[row, column] then
                            rect = InvaderRect(row, column)
                            if RectIntersectsCircle(rect, center, radius) then
                                ' The invader explodes
                                invaders[row, column] = false
                                score = score + points[row]
                                invadersLeft = invadersLeft - 1
                                invadersPerColumn[column] = invadersPerColumn[column] - 1
                                coords = InvaderCoords(row, column)
                                ' Only draw an explosion if the invader is far away
                                dx = coords[1] - explosions[i, 1]
                                dy = coords[2] - explosions[i, 2]
                                if dx * dx + dy * dy > explosionEndRadius * explosionEndRadius then
                                    call AddExplosion(coords[1], coords[2])
                                else
                                    playExplosion = true
                                endif
                                ' And emits a reflected missile
                                angle = -(Rand() mod 135 + 22) * 3.14159 / 180
                                coords[1] = coords[1] + cos(angle) * invaderWidth / 2
                                coords[2] = coords[2] + sin(angle) * invaderHeight / 2
                                call AddMissile(coords[1], coords[2], _
                                   angle, frameCounter, _
                                   int(ceil(missileSpeeds[row] * 1.2)), true, coords[1], coords[2])
                            endif
                        endif
                    next column
                next row
                
                ' Check whether the explosion has swallowed a missile
                missile = 1
                while missile <= UBound(missiles) do
                    ' If this missile is in use
                    if missiles[missile, 9] then
                        dx = missiles[missile, 7] - explosions[i, 1]
                        dy = missiles[missile, 8] - explosions[i, 2]
                        dist2 = dx * dx + dy * dy
                        ' If the explosion swallowed the missile
                        if dist2 < explosions[i, 3] * explosions[i, 3] * 0.8 then
                            if missiles[missile, 6] = false then
                                invaderMissiles = false
                            endif
                            call RemoveMissile(missile)
                        endif
                    endif
                    missile = missile + 1
                endwhile
                
                ' If the explosion is close enough the the ground
                if explosions[i, 2] - explosions[i, 3] <= cityY + cityHeight then
                    ' Figure out the extent of the blast
                    explosionLeft = explosions[i, 1] - explosions[i, 3]
                    explosionRight = explosions[i, 1] + explosions[i, 3]
                    ' Check whether the explosion has swallowed a city
                    for city = 1 to cityCount
                        if cities[city] then
                            x = CityX(city)
                            cityLeft = x - cityWidth / 3
                            cityRight = x + cityWidth / 3
                            if (explosionLeft < cityLeft and explosionRight > cityLeft) or _
                               (explosionLeft < cityRight and explosionRight > cityRight)
                                cities[city] = false
                                ' Only draw a new explosion if it's far away from this explosion
                                if abs(explosions[i, 1] - x) >= explosionEndRadius then
                                    call AddExplosion(x, cityY)
                                else
                                    playExplosion = true
                                endif
                                citiesLeft = citiesLeft - 1
                            endif
                        endif
                    next city
                endif
                
            next i
            
            ' Move the invaders from side to side
            if invadersLeft and frameCounter mod GetFrameRate() = 0 then
                ' Toggle which invader shapes we show
                invaderShapeSelection = 3 - invaderShapeSelection
                if movingLeft then
                    ' Find the first column that has invaders in it
                    for i = 1 to invaderColumns
                        if invadersPerColumn[i] then
                            rect = InvaderRect(1, i)
                            if rect[1] >= invaderLeftmostPosition + invaderWidth / 2 then
                                invaderX = invaderX - invaderWidth / 2
                            else
                                movingLeft = false
                                invaderAltitude = invaderAltitude - invaderHeight / 2
                            endif
                            exit for
                        endif
                    next
                else
                    ' Find the last column that has invaders in it
                    for i = invaderColumns to 1 step -1
                        if invadersPerColumn[i] then
                            rect = InvaderRect(1, i)
                            if rect[3] <= invaderRightmostPosition - invaderWidth / 2 then
                                invaderX = invaderX + invaderWidth / 2
                            else
                                movingLeft = true
                                invaderAltitude = invaderAltitude - invaderHeight / 2
                            endif
                            exit for
                        endif
                    next
                endif
            endif
                    
			
			' For the first 2 seconds, display the round number
			if frameCounter < GetFrameRate() * 2 then
				roundText = Text2ListSprite({{-50, 10, "ROUND " + round}})
				call SpriteSetMagnification(roundText, 2)
			endif
			
            ' After the first two seconds, make sure there's always an invader-launched missile
            if frameCounter > GetFrameRate() * 2 and invaderMissiles = false and citiesLeft then
                invaderMissiles = FireMissile(invaders)
            endif
            
            ' Draw the missiles
            for i = 1 to UBound(missiles)
                if missiles[i, 9] then
                    originX = missiles[i, 1]
                    originY = missiles[i, 2]
                    length = (frameCounter - missiles[i, 4]) * missiles[i, 5]
                    ' If the missile line is too long to fit in a single segment
                    if length > maxMissileLength then
                        ' Change the origin we draw from
                        sangle = sin(missiles[i, 3])
                        cangle = cos(missiles[i, 3])
                        originX = missiles[i, 7] - maxMissileLength * cangle
                        originY = missiles[i, 8] - maxMissileLength * sangle

                    endif

                    call ReturnToOriginSprite()
                    ' This is a kludge. We want to position the missile using invader scale. The
                    ' length we need to move is often more than 127. Lines sprites will
                    ' make multiple segments to accommodate this
                    if missiles[i, 6] then
                        pattern = 0x99
                    else
                        pattern = DrawTo
                    endif
                    missileLines = {{MoveTo, originX, originY}, _
                        {pattern, missiles[i, 7], missiles[i, 8]}, {DrawTo, missiles[i, 7], missiles[i, 8]}}
                    call LinesSprite(missileLines)
                endif
            next
            
            ' Draw the explosions
            for i = 1 to UBound(explosions)
                if explosions[i, 5] then
                    ' Draw the current explosion
                    explLines = RegularPolygon(5, abs(explosions[i, 3]), frameCounter * 20)
                    call Offset(explLines, explosions[i, 1], explosions[i, 2])
                    call ReturnToOriginSprite()
                    call LinesSprite(explLines)
                endif
            next i
            
            if playExplosion then
                call Play(expl)
            elseif playBounce and not MusicIsPlaying()
                call Play(bounce)
            endif
            
        endwhile ' A round of the game
        
        ' Give a bonus for every city left
        score = score + citiesLeft * survivingCityCredit
        
        scoringText = citiesLeft + " CITIES = +" + citiesLeft * survivingCityCredit + " POINTS"
        
        ' Award bonus city(ies)
        awardedCities = 0
        while score >= bonusCity and citiesLeft < UBound(cities) do
            ' Choose the location of the new city
            newCity = Rand() mod UBound(cities) + 1
            while true do
                ' If the new city location is available
                if not cities[newCity] then
                    ' Put the new city there
                    cities[newCity] = true
                    citiesLeft = citiesLeft + 1
                    awardedCities = awardedCities + 1
                    bonusCity = bonusCity + bonusCityIncrement
                    exit while
                ' Else (there's already a city in that spot)
                else
                    ' Look in the next possible city location
                    newCity = newCity + 1
                    if newCity > UBound(cities) then
                        newCity = 1
                    endif
                endif
            endwhile
        endwhile
        
        if awardedCities = 1 then
            scoringText = {{-50, 10, scoringText}, {-50, -10, "1 BONUS CITY"}}
        elseif awardedCities > 1 then
            scoringText = {{-50, 10, scoringText}, {-50, -10, awardedCities + " BONUS CITIES"}}
        else
            scoringText = {{-50, 10, scoringText}}
        endif
        
        ' Announce the bonus points and awarded cities
        scoringText = Text2ListSprite(scoringText)
        frameCounter = 0
        repeat 
            controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
            
            frameCounter = frameCounter + 1
        until frameCounter > GetFrameRate() * 3 or controls[1, 3] or controls[1, 6]
        
        call RemoveSprite(scoringText)
        
        ' Speed up the missiles for the next round
        for i = 1 to UBound(missileSpeeds)
            missileSpeeds[i] = Ceil(missileSpeeds[i] * 1.2)
        next i
    endwhile ' The game
    
    ' Show "Game Over"
    call ReturnToOriginSprite()
    call ScaleSprite(15)
    call IntensitySprite(127)
    goSprite = LinesSprite(gameOverText)
    frameCounter = 0
    repeat 
        if frameCounter <= twoSecs then
            call SpriteSetMagnification(goSprite, 4.0 * frameCounter / twoSecs)
            call SpriteSetRotation(goSprite, 1440 * frameCounter / twoSecs)
        endif
        controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
        
        frameCounter = frameCounter + 1
    until frameCounter > GetFrameRate() * 10 or controls[1, 3] or controls[1, 6]

    ' End of the game
    call ClearScreen

endwhile  ' Display intro and play games

function InvaderCoords(row, column)
    return {(column - 1 - invaderColumns / 2.0) * (invaderWidth + invaderColumnSpacing) + invaderX, _
             invaderAltitude - row * (invaderHeight + invaderRowSpacing)}
endfunction

' Return the bounding rect of an invader as {left, top, right, bottom}
function InvaderRect(row, column)
    dim x, y
    
    origin = InvaderCoords(row, column)
    x = origin[1]
    y = origin[2]
    rect = {x - invaderWidth / 2, y + invaderHeight / 2, x + invaderWidth / 2, y - invaderHeight / 2}
    
    return rect
endfunction

function ClosestInvader(x, y)
    dim column, row
    
    column = float(x - invaderX) / (invaderWidth + invaderColumnSpacing) + invaderColumns / 2.0 + 1
    column = max(min(round(column), invaderColumns), 1)
    row = -(float(y) - invaderAltitude) / (invaderHeight + invaderRowSpacing)
    row = max(min(round(row), invaderRows), 1)
    return {int(row), int(column)}
endfunction

' Return -1, 0, or 1 depending on the sign of x
function sign(x)
    if x < 0 then
        return -1
    elseif x = 0 then
        return 0
    else
        return 1
    endif
endfunction

' Return the (x, y) coordinate where line segment {{x1, y1}, {x2, y2}} intersects
' horizontal line {0, y} or vertical line {x, 0}. If there's no intersection, return nil
function Intersection(segment, line)
    dim x, y
    
    ' If it's a horizontal line
    if line[1] = 0 then
        ' If the segment is horizontal too
        if segment[1, 2] = segment[2, 2] then
            ' If the segment and the horizontal line have the same y coordinate
            if segment[1, 2] = line[2] then
                return {segment[1, 1], segment[1, 2]}
            endif

        ' Else if the segment crosses the line
        elseif sign(segment[1, 2] - line[2]) != sign(segment[2, 2] - line[2]) then
            x = float((line[2] - segment[1, 2]) * (segment[1, 1] - segment[2, 1])) / _
                (segment[1, 2] - segment[2, 2]) + segment[1, 1]
            return {x, line[2]}
        endif
        
    ' Else (it's a vertical line)
    else
        ' If the segment is vertical too
        if segment[1, 1] = segment[2, 1] then
            ' If the segment and the vertical line have the same x coordinate
            if segment[1, 1] = line[1] then
                return {segment[1, 1], segment[1, 2]}
            endif

        ' Else if the segment crosses the line
        elseif sign(segment[1, 1] - line[1]) != sign(segment[2, 1] - line[1]) then
            y = float((line[1] - segment[1, 1]) * (segment[1, 2] - segment[2, 2])) / _
                (segment[1, 1] - segment[2, 1]) + segment[1, 2]
            return {line[1], y}
        endif
    endif
    
    return nil
endfunction

function FireMissile(invaders)
    dim column, row, rect, originX, originY, angle, newMissile
    
    ' Choose a column at random
    column = Rand() mod UBound(invaders, 2) + 1
    ' Starting at the selected column, look for an invader to fire the
    ' missile. If there's no invader in the selected column, try the
    ' next one
    while invadersLeft do
        ' Look in this column for a living invader, starting from the
        ' bottom and going up
        for row = UBound(invaders) to 1 step -1
            if invaders[row, column] then
                ' We've found the bottommost living invader. Launch a missile from here
                rect = InvaderRect(row, column)
                originX = (rect[1] + rect[3]) / 2
                originY = rect[4]
                angle = (Rand() mod 90 - 135) * 3.14159 / 180
                success = AddMissile(originX, originY, angle, frameCounter, missileSpeeds[row], false, originX, originY)
                
                return success
            endif
        next row
    
        column = column + 1
        if column > UBound(invaders, 2) then
            column = 1
        endif
    endwhile
    
    return false
endfunction

function AddMissile(x, y, angle, frameCounter, speed, reflected, currentX, currentY)
    dim i
    for i = 1 to UBound(missiles)
        if missiles[i, 9] = false then
            missiles[i, 1] = x
            missiles[i, 2] = y
            missiles[i, 3] = angle
            missiles[i, 4] = frameCounter
            missiles[i, 5] = speed
            missiles[i, 6] = reflected
            missiles[i, 7] = currentX
            missiles[i, 8] = currentY
            missiles[i, 9] = true
            activeMissiles = activeMissiles + 1
            return true
        endif
    next
    
    return false
endfunction

sub RemoveMissile(index)
    missiles[index, 9] = false
    activeMissiles = activeMissiles - 1
endsub

sub AddExplosion(x, y)
    dim newRow, bestRow, bestSize
    bestRow = 0
    bestSize = 100
    
    for newRow = 1 to UBound(explosions)
        if explosions[newRow, 5] = false then
            bestRow = newRow
            exit for
        elseif explosions[newRow, 4] = -1 and explosions[newRow, 3] < bestSize then
            bestRow = newRow
        endif
    next
    
    if bestRow then
        explosions[bestRow, 1] = x
        explosions[bestRow, 2] = y
        explosions[bestRow, 3] = explosionStartRadius
        explosions[bestRow, 4] = 1
        if not explosions[bestRow, 5] then
            explosions[bestRow, 5] = true
            activeExplosions = activeExplosions + 1
        endif
        playExplosion = true ' global variable
    endif
endsub

sub RemoveExplosion(index)
    explosions[index, 5] = false
    activeExplosions = activeExplosions - 1
endsub

' Remove a row from a 2D array
function RemoveRow(array, row)
    dim columns, i, j
    columns = UBound(array, 2)
    dim newArray[UBound(array) - 1, columns]
    for i = 1 to row - 1
        for j = 1 to columns
            newArray[i, j] = array[i, j]
        next j
    next i
    for i = row + 1 to UBound(array)
        for j = 1 to columns
            newArray[i - 1, j] = array[i, j]
        next j
    next i
    
    return newArray
endfunction

' Returns true if the rect {left, top, right, bottom} intersects 
' the circle {x, y} with the given radius
function RectIntersectsCircle(rect, center, radius)
    dim closestX, closestY, dx, dy
    if center[1] < rect[1] then
        closestX = rect[1]
    elseif center[1] > rect[3]
        closestX = rect[3]
    else
        closestX = center[1]
    endif
    if center[2] < rect[4] then
        closestY = rect[4]
    elseif center[2] > rect[2]
        closestY = rect[2]
    else
        closestY = center[2]
    endif
    
    dx = closestX - center[1];
    dy = closestY - center[2];

    return (dx * dx + dy * dy) <= radius * radius;
endfunction

function CityX(city)
    return (city - 1 - cityCount / 2.0) * (cityWidth + citySpacing) + citySpacing
endfunction

' Return the ceiling of a number (i.e. round the number up)
function Ceil(x)
    dim i
    i = int(x)
    if i < x then
        i = i + 1
    endif
    return i
endfunction
