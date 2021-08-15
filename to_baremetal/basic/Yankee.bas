
call SetFrameRate(45)

notice = { _
    {-70, 70, "ADAPTED FROM THE"}, _
    {-70, 50, "VECTREX TUTORIAL BY"}, _
    {-70, 30, "CHRISTOPHER SALOMON"}, _
    {-70, 0, "BTN 4 EXITS"}}
call IntensitySprite(100)
textSize = {40, 5}
call TextSizeSprite(textSize)
call TextListSprite(notice)

yankee = { _
    {NA2, 12}, _
    {NG2, 12}, _
    {NA2, 12}, _
    {NG2, 12}, _
    {NA2, 6}, _
    {NG2, 6}, _
    {NA2, 6}, _
    {NG2, 6}, _
    {NA2, 6}, _
    {NG2, 6}, _
    {NA2, 12}, _
    {NG2, 12}, _
    {NA2, 12}, _
    {NG2, 12}, _
    {NA2, 12}, _
    {NG2, 12}, _
    {NA2, 6}, _
    {NG2, 6}, _
    {NA2, 6}, _
    {NG2, 6}, _
    {NA2, 6}, _
    {NG2, 6}, _
    {NA2, 6}, _
    {NG2, 6}, _
    {NA2, 12}, _
    {NG2, 12}, _
    {ABC(NA2, NA4, NA4 - NOctave), 12}, _
    {ABC(NG2, ND5, ND5 - NOctave), 12}, _
    {ABC(NA2, ND5, ND5 - NOctave), 12}, _
    {ABC(NG2, NE5, NE5 - NOctave), 12}, _
    {ABC(NA2, NFS5, NFS5 - NOctave), 12}, _
    {ABC(NG2, ND5, ND5 - NOctave), 12}, _
    {ABC(NA2, NFS5, NFS5 - NOctave), 12}, _
    {ABC(NG2, NE5, NE5 - NOctave), 12}, _
    {ABC(NA2, NA4, NA4 - NOctave), 12}, _
    {ABC(NG2, ND5, ND5 - NOctave), 12}, _
    {ABC(NA2, ND5, ND5 - NOctave), 12}, _
    {ABC(NG2, NE5, NE5 - NOctave), 12}, _
    {ABC(NA2, NFS5, NFS5 - NOctave), 12}, _
    {ABC(NG2, ND5, ND5 - NOctave), 12}, _
    {NA2, 12}, _
    {ABC(NG2, NCS5, NCS5 - NOctave), 12}, _
    {ABC(NA2, NA4, NA4 - NOctave), 12}, _
    {ABC(NG2, ND5, ND5 - NOctave), 12}, _
    {ABC(NA2, ND5, ND5 - NOctave), 12}, _
    {ABC(NG2, NE5, NE5 - NOctave), 12}, _
    {ABC(NA2, NFS5, NFS5 - NOctave), 12}, _
    {ABC(NG2, NG5, NG5 - NOctave), 12}, _
    {ABC(NA2, NFS5, NFS5 - NOctave), 12}, _
    {ABC(NG2, NE5, NE5 - NOctave), 12}, _
    {ABC(NA2, ND5, ND5 - NOctave), 12}, _
    {ABC(NG2, NCS5, NCS5 - NOctave), 12}, _
    {ABC(NA2, NA4, NA4 - NOctave), 12}, _
    {ABC(NG2, NB4, NB4 - NOctave), 12}, _
    {ABC(NA2, NCS5, NCS5 - NOctave), 12}, _
    {ABC(NG2, ND5, ND5 - NOctave), 12}, _ 
    {NA2, 12}, _
    {ABC(NG2, ND5, ND5 - NOctave), 12}, _
    {NA2, 12}, _
    {ABC(NG2, NB4, NB4 - NOctave), 18}, _  
    {ABC(NCS5, NCS5 - NOctave), 6}, _
    {ABC(NA2, NB4, NB4 - NOctave), 12}, _
    {ABC(NG2, NA4, NA4 - NOctave), 12}, _
    {ABC(NA2, NB4, NB4 - NOctave), 12}, _ 
    {ABC(NG2, NCS5, NCS5 - NOctave), 12}, _
    {ABC(NA2, ND5, ND5 - NOctave), 12}, _
    {NG2, 12}, _
    {ABC(NG2, NA4, NA4 - NOctave), 18}, _
    {ABC(NB4, NB4 - NOctave), 6}, _
    {ABC(NA2, NA4, NA4 - NOctave), 12}, _
    {ABC(NG2, 24, 24 - NOctave), 12}, _
    {ABC(NA2, 23, 23 - NOctave), 12}, _
    {NG2, 12}, _
    {ABC(NA2, NA4, NA4 - NOctave), 12}, _
    {NG2, 12}, _
    {ABC(NA2, NB4, NB4 - NOctave), 18}, _
    {ABC(NCS5, NCS5 - NOctave), 6}, _
    {ABC(NG2, NB4, NB4 - NOctave), 12}, _
    {ABC(NA2, NA4, NA4 - NOctave), 12}, _
    {ABC(NG2, NB4, NB4 - NOctave), 12}, _
    {ABC(NA2, NCS5, NCS5 - NOctave), 12}, _
    {ABC(NG2, ND5, ND5 - NOctave), 12}, _
    {ABC(NA2, NB4, NB4 - NOctave), 12}, _
    {ABC(NG2, NA4, NA4 - NOctave), 12}, _
    {ABC(NA2, ND5, ND5 - NOctave), 12}, _
    {ABC(NG2, NCS5, NCS5 - NOctave), 12}, _
    {ABC(NA2, NE5, NE5 - NOctave), 12}, _
    {ABC(NG2, ND5, ND5 - NOctave), 12}, _
    {NA2, 12}, _
    {ABC(NG2, ND5, ND5 - NOctave), 12}, _
    {NA2, 12}}
ydmusic = Music(yankee)
call Play(ydmusic)
while MusicIsPlaying()
    controls = WaitForFrame(JoystickNone, Controller1, JoystickNone)
    if controls[1, 6] then
        stop
    endif
endwhile

