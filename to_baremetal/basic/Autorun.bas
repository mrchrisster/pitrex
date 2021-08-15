' Display a menu of BASIC programs and allow the user to run one

call SetFrameRate(30)

files = dir()
' Count the number of BASIC files
basicCount = 0
for i = 1 to UBound(files)
    if StrComp(".bas", Right(files[i], 4), 1) = 0 and _
       StrComp("Autorun.bas", files[i], 1) != 0 and _
       StrComp("GameMenu.bas", files[i], 1) != 0 then
        basicCount = basicCount + 1
    endif
next i

' Copy the names of the BASIC files into an array
dim basicFiles[basicCount]
basicIndex = 1
for i = 1 to UBound(files)
    if StrComp(".bas", Right(files[i], 4), 1) = 0 and _
       StrComp("Autorun.bas", files[i], 1) != 0 and _
       StrComp("GameMenu.bas", files[i], 1) != 0 then
        basicFiles[basicIndex] = Left(files[i], Len(files[i]) - 4)
        basicIndex = basicIndex + 1
    endif
next i

' Build an array for a text list sprite
dim menu[min(4, basicCount), 3]
for i = 1 to UBound(menu)
    menu[i, 1] = -70
    menu[i, 2] = (UBound(menu) / 2.0 - i + 1) * 20 + 1
    menu[i, 3] = ""
next i

instructions = { _
    {menu[1, 1] + 10, menu[1, 2] + 70, "JOYSTICK a & c."}, _
    {menu[1, 1] + 10, menu[1, 2] + 50, "RUN WITH BTN 1"}, _
    {menu[1, 1] + 10, menu[1, 2] + 30, "MENU SCROLLS a & c"}}

' Put the names of the BASIC files into the text list
topOfMenu = 1
call FillMenu(basicFiles, topOfMenu, menu)

' Select the game we're currently pointing at and put an arrow pointing to it
currentGame = 1
menu[currentGame, 3] = "->" + Mid(menu[currentGame, 3], 3)

' Display the text on the screen
call IntensitySprite(100)
textSize = {40, 5}
call TextSizeSprite(textSize)
call TextListSprite(instructions)
call TextListSprite(menu)

' Ignore the joystick for a brief time after it's been moved. That way,
' we don't move the currentGame too fast
ignoreJoystick = GetFrameRate() / 2

' Do forever
while true
    ' Get the current control state
    controls = WaitForFrame(JoystickDigital, Controller1, JoystickY)
    
    if ignoreJoystick != 0 then
        ignoreJoystick = ignoreJoystick - 1
        
    else
        ' If the user moved the joystick up or down
        if controls[1, 2] != 0 then
            ' Ignore the joystick for 1/2 second
            ignoreJoystick = GetFrameRate() / 2
        
            ' Remove the arrow on the currently selected game
            menu[currentGame, 3] = "  " + Mid(menu[currentGame, 3], 3)
            
            ' If he moved it up
            if controls[1, 2] > 0 then
                ' Move the current game up
                currentGame = currentGame - 1
                ' If the current game has moved off the top of the menu
                if currentGame = 0 then
                    ' If there are some BASIC programs that have been scrolled off the top
                    ' of the menu
                    if topOfMenu > 1 then
                        ' Scroll the menu down
                        topOfMenu = topOfMenu - 1
                        call FillMenu(basicFiles, topOfMenu, menu)
                        currentGame = 1
                    ' Else (we're at the top of the list of BASIC programs)
                    else
                        ' Don't move the pointer up
                        currentGame = 1
                    endif
                endif
                
            ' Else (the joystick is moving the pointer down)
            else
                ' Move the current game down
                currentGame = currentGame + 1
                ' If the current game has moved off the bottom of the menu
                if currentGame > UBound(menu) then
                    ' If there are some BASIC programs that can be scrolled into
                    ' the menu
                    if topOfMenu + UBound(menu) <= UBound(basicFiles) then
                        ' Scroll the menu down
                        topOfMenu = topOfMenu + 1
                        call FillMenu(basicFiles, topOfMenu, menu)
                        currentGame = UBound(menu)
                    ' Else (we're at the bottom of the list of BASIC programs)
                    else
                        ' Don't move the pointer down
                        currentGame = currentGame - 1
                    endif
                endif
            endif
            
            ' Display a pointer on the current game
            menu[currentGame, 3] = "->" + Mid(menu[currentGame, 3], 3)
            
        ' Else (the joystick is not being moved)
        else
            ignoreJoystick = 0
        endif
    endif
    
    ' If button 1 is pressed
    if controls[1, 3] then
        ' Wait until the button is released
        while controls[1, 3]
            controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
        endwhile
        ' Chain to the selected program
        chain mid(menu[currentGame, 3], 3) rerun
    endif
endwhile

' Copy a list of options to the menu
sub FillMenu(options, firstOption, menu)
    for i = 1 to min(UBound(menu), UBound(options) - (firstOption - 1))
        menu[i, 3] = "  " + ToUpper(options[i + firstOption - 1])
    next i
endsub
