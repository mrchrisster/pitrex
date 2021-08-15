' Build a list of all the sounds we can make. The first item in
' each row is the name of the sound. The second item is an array
' giving the initial values of the registers
' SIREN: Start the siren with a high pitch tone. The ProcessSiren function will
'        change it to a low pitch tone after 1/3 sec
' GUNSHOT: The Envelope Generator registers will handle the attack and decay
'          on the gunshot sound; ProcessGunshot just needs to indicate when
'          the sound is done
' EXPLOSION: The Envelope Generator registers will handle the attack and decay
'            on the explosion sound; ProcessExplosion just needs to indicate when
'            the sound is done
' PHASER: The ProcessPhaser function will change the tone over time
' BOMB: The ProcessBomb function will change the tone over time
sounds = { _
    {"SIREN", ({{0, $fe}, {1, 0}, {7, $3e}, {8, 15}})}, _
    {"GUNSHOT", ({{6, 15}, {7, 7}, {8, 16}, {9, 16}, {10, 16}, {11, 0}, {12, 14}, {13, 0}})}, _
    {"EXPLOSION", ({{7, 7}, {8, 16}, {9, 16}, {10, 16}, {11, 1}, {11, 0}, {12, 56}, {13, 1}, {13, 0}})}, _
    {"PHASER", ({{7, $3e}, {8, 15}, {0, $30}})}, _
    {"BOMB", ({{7, $3e}, {8, 15}, {0, $30}})}, _
    {"RACE CAR", ({{3, 15}, {7, 60}, {8, 15}, {9, 10}})}}

call IntensitySprite(80)

' Build an array for a text list sprite
dim menu[min(6, UBound(sounds)), 3]
for i = 1 to UBound(menu)
    menu[i, 1] = -70
    menu[i, 2] = (UBound(menu) / 2.0 - i + 1) * 15 + 1
    menu[i, 3] = ""
next i

instructions = { _
    {menu[1, 1] + 10, menu[1, 2] + 50, "JOYSTICK a & c."}, _
    {menu[1, 1] + 10, menu[1, 2] + 35, "PLAY WITH BTN 1"}, _
    {menu[1, 1] + 10, menu[1, 2] + 20, "EXIT WITH BTN 4"}}

' Put the names of the sounds into the text list
topOfMenu = 1
call FillMenu(sounds, topOfMenu, menu)

' Select the sound we're currently pointing at and put an arrow pointing to it
currentSound = 1
menu[currentSound, 3] = "->" + Mid(menu[currentSound, 3], 3)

' Display the text on the screen
textSize = {40, 5}
call TextSizeSprite(textSize)
texts1 = TextListSprite(instructions)
texts2 = TextListSprite(menu)

texts3 = TextListSprite({{menu[1, 1], menu[1, 2], "PLAYING..."}})
call SpriteEnable(texts3, false)

' Ignore the joystick for a brief time after it's been moved. That way,
' we don't move the currentSound too fast
ignoreJoystick = 0

playSound = 0
sequence = 0

' Set the frame rate; this is the maximum rate that we can change
' the sound registers
call SetFrameRate(60)

' Wait until buttons 1 and 4 are not being pressed
repeat
    ' Get the current control state
    controls = WaitForFrame(JoystickDigital, Controller1, JoystickY)
until controls[1, 3] = 0 and controls[1, 6] = 0

' Do forever
while true
    ' Get the current control state
    controls = WaitForFrame(JoystickDigital, Controller1, JoystickY)

    if ignoreJoystick != 0 then
        ignoreJoystick = ignoreJoystick - 1

    else
        ' If the user moved the joystick up or down
        if controls[1, 2] != 0 then
            ' Ignore the joystick for 1/4 second
            ignoreJoystick = GetFrameRate() / 4

            ' Remove the arrow on the currently selected sound
            menu[currentSound, 3] = "  " + Mid(menu[currentSound, 3], 3)

            ' If he moved it up
            if controls[1, 2] > 0 then
                ' Move the current sound up
                currentSound = currentSound - 1
                ' If the current sound has moved off the top of the menu
                if currentSound = 0 then
                    ' If there are some sounds that have been scrolled off the top
                    ' of the menu
                    if topOfMenu > 1 then
                        ' Scroll the menu down
                        topOfMenu = topOfMenu - 1
                        call FillMenu(sounds, topOfMenu, menu)
                        currentSound = 1
                    ' Else (we're at the top of the list of BASIC programs)
                    else
                        ' Don't move the pointer up
                        currentSound = 1
                    endif
                endif

            ' Else (the joystick is moving the pointer down)
            else
                ' Move the current sound down
                currentSound = currentSound + 1
                ' If the current sound has moved off the bottom of the menu
                if currentSound > UBound(menu) then
                    ' If there are some sounds that can be scrolled into
                    ' the menu
                    if topOfMenu + UBound(menu) <= UBound(sounds) then
                        ' Scroll the menu down
                        topOfMenu = topOfMenu + 1
                        call FillMenu(sounds, topOfMenu, menu)
                        currentSound = UBound(menu)
                    ' Else (we're at the bottom of the list of BASIC programs)
                    else
                        ' Don't move the pointer down
                        currentSound = currentSound - 1
                    endif
                endif
            endif

            ' Display a pointer on the current sound
            menu[currentSound, 3] = "->" + Mid(menu[currentSound, 3], 3)

        ' Else (the joystick is not being moved)
        else
            ignoreJoystick = 0
        endif
    endif

    ' If button 1 is pressed
    if controls[1, 3] then
        ' Turn off any sound that's currently playing
        call Play(nil)

        ' Wait until the button is released
        while controls[1, 3]
            controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
        endwhile
        ' start playing the sound
        playSound = currentSound + topOfMenu - 1
        sequence = 0
        ' Turn off the text so it doesn't slow down the frame rate
        call SpriteEnable(texts1, false)
        call SpriteEnable(texts2, false)
        call SpriteEnable(texts3, true)
    endif

    ' If button 4 is pressed
    if controls[1, 6] then
        ' Exit the program
        stop
    endif

    ' If we're playing a sound
    if playSound != 0 then
        ' If the sequence number is 0, set up the initial registers
        ' for this sound
        if sequence = 0 then
            call Sound(sounds[playSound, 2])
        ' Else (a higher sequence number)
        else
            done = true
            ' Use the appropriate function for playing the sound
            if playSound = 1 then
                done = ProcessSiren(sequence)
            elseif playSound = 2 then
                done = ProcessGunshot(sequence)
            elseif playSound = 3 then
                done = ProcessExplosion(sequence)
            elseif playSound = 4 then
                done = ProcessPhaser(sequence)
            elseif playSound = 5 then
                done = ProcessBomb(sequence)
                ' When the whistling sound of the bomb dropping is done
                if done then
                    ' Play the explosion sound for the boom
                    playSound = 3
                    sequence = -1
                    done = false
                endif
            elseif playSound = 6 then
                done = ProcessRaceCar(sequence)
            endif

            ' If we're done playing the sound, turn it off
            if done then
                call Play(nil)
                playSound = 0
                call SpriteEnable(texts1, true)
                call SpriteEnable(texts2, true)
                call SpriteEnable(texts3, false)
            endif
        endif

        ' Go to the next step in playing the sound
        sequence = sequence + 1
    endif
endwhile

' Copy a list of options to the menu
sub FillMenu(options, firstOption, menu)
    dim i
    for i = 1 to min(UBound(menu), UBound(options) - (firstOption - 1))
        menu[i, 3] = "  " + ToUpper(options[i + firstOption - 1, 1])
    next i
endsub

function ProcessSiren(sequence)
    dim done, soundTime, thirdOfASec

    done = false
    ' Let the sound play for 2 seconds
    soundTime = GetFrameRate() * 2
    ' How many frames is 1/3 of a second?
    thirdOfASec = GetFrameRate() / 3
    ' We alternate between a high tone and a low tone every 1/3 of a sec.
    ' Figure out which we should do
    if (sequence / thirdOfASec) mod 2 = 0 then
        call Sound({{0, $3e}, {1, 0}})
    else
        call Sound({{0, $56}, {1, 1}})
    endif
    ' Check for done
    if sequence > soundTime then
        done = true
    endif

    return done
endfunction

function ProcessGunshot(sequence)
    dim soundTime
    ' Let the sound play for 2 frames
    soundTime = 2
    if sequence > soundTime then
        return true
    else
        return false
    endif
endfunction

function ProcessExplosion(sequence)
    dim soundTime
    ' Let the sound play for 1/5 second
    soundTime = GetFrameRate() / 5
    if sequence > soundTime then
        return true
    else
        return false
    endif
endfunction

function ProcessPhaser(sequence)
    dim done, soundTime, increment

    done = false
    ' How many frames is 1/3 of a second?
    soundTime = GetFrameRate() / 3
    ' In the 1/3 sec the sound will play, we want to sweep the tone
    ' from 48 to 112. Figure out how much we need to step by
    increment = (112 - 48) / soundTime
    ' Play this sequence's tone
    call Sound({{0, 48 + increment * (sequence - 1)}})

    if sequence > soundTime then
        done = true
    endif

    return done
endfunction

function ProcessBomb(sequence)
    dim done, soundTime
    done = false
    ' How many frames is 3.6 seconds?
    soundTime = GetFrameRate() * 36 / 10
    ' Play this sequence's tone
    call Sound({{0, 48 + sequence - 1}})

    if sequence > soundTime then
        done = true
    endif

    return done
endfunction


function ProcessRaceCar(sequence)
    dim sweepRanges, time, range, toneIncrement, tone
    ' We're going to change the tone in channel A. First, we'll sweep
    ' it from 2519 to 915 in 5.3 seconds, then we'll sweep it from 2062 to 687
    ' in 4.6 seconds, and finally from 1374 to 229 in 7.6 seconds
    ' (These numbers come from the AY-3-8912 Manual, adjusted for the Vectrex's
    ' 1.6MHz clock)
    sweepRanges = {{2519, 915, 5.3}, {2062, 687, 4.6}, {1374, 229, 7.6}}

    ' Get the number of seconds we've been making the sound
    time = float(sequence) / GetFrameRate()

    ' Figure out which range we're in. 'sequence' holds the frame count since we
    ' started playing the sound, but we want the frame number since we started
    ' playing the current sweepRange. That's what we put in rangeSequence
    if time <= sweepRanges[1, 3] then
        range = 1
        rangeSequence = sequence
    elseif time <= sweepRanges[2, 3] + sweepRanges[1, 3] then
        range = 2
        rangeSequence = sequence - int(sweepRanges[1, 3] * GetFrameRate())
    elseif time <= sweepRanges[3, 3] + sweepRanges[2, 3] + sweepRanges[1, 3] then
        range = 3
        rangeSequence = sequence - int((sweepRanges[2, 3] + sweepRanges[1, 3]) * GetFrameRate())
    ' Else we've finished the last range; return done = true
    else
        return true
    endif

    ' Figure out the tone we should play. First we calculate how much
    ' we should increment the tone every frame. That's the range we need
    ' to sweep through divided by the number of frames we should do the sweep in
    toneIncrement = (sweepRanges[range, 2] - sweepRanges[range, 1]) / _
                    (sweepRanges[range, 3] * GetFrameRate())
    ' The tone is the start of the range, plus the increment to get to this frame number
    tone = sweepRanges[range, 1] + int(rangeSequence * toneIncrement)

    ' Set the tone for channel A
    call Sound({{1 , tone / 256}, {0, tone mod 256}})

    ' Return false, meaning we're not done yet
    return false
endfunction
