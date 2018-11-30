IncludeFile "const.pb"

UsePNGImageDecoder()

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
    IncludeFile "reg-read.pbi"
    LoadFont(#font,"Arial",10,#PB_Font_HighQuality)
  CompilerCase #PB_OS_Linux
    ImportC ""
      gtk_window_close(wndid.i)
      gtk_widget_destroy(id.i)
      gtk_window_set_icon(wndid.i,imgid.i)
      gtk_window_set_default_icon(imgid.i)
    EndImport
    LoadFont(#font,"Arial",10)
    LoadFont(#frameFont,"Arial",9)
  CompilerCase #PB_OS_MacOS
    LoadFont(#font,"Arial",10)
CompilerEndSelect

EnableExplicit

Define savesPath.s,lang.s,currentSave.s
Define ev.i,i.i
Define strings.lang
Define saveNeeded.b
Define *caption.String
NewList gamePaths.s()
NewList savesPaths.s()
NewList saveFiles.s()

IncludeFile "helpers.pb"
IncludeFile "proc.pb"

CatchImage(#iconAbout,?iconAbout)
CatchImage(#iconInfo,?iconInfo)
CatchImage(#iconRefresh,?iconRefresh)
CatchImage(#iconSave,?iconSave)
CatchImage(#iconCharacter,?iconCharacter)
CatchImage(#iconStats,?iconStats)
CatchImage(#iconInventory,?iconInventory)
CatchImage(#iconTenement,?iconTenement)
CatchImage(#iconQuests,?iconQuests)
CatchImage(#iconWorld,?iconWorld)

Define gadOffsetX = 0
Define gadOffsetY = 0
Define helpOffsetY = 0

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  ResizeImage(#iconSave,20,20,#PB_Image_Smooth)
  ResizeImage(#iconRevert,20,20,#PB_Image_Smooth)
  ResizeImage(#iconAbout,20,20,#PB_Image_Smooth)
  CatchImage(#iconMain,?iconMain)
  ;gtk_window_set_icon(WindowID(#wnd),ImageID(#iconMain))
  gtk_window_set_default_icon(ImageID(#iconMain))
  gadOffsetX = -6
  gadOffsetY = -2
CompilerEndIf

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  Define imageSize.NSSize
  imageSize\width = 16
  imageSize\height = 16
  CocoaMessage(0,ImageID(#iconAbout),"setSize:@",@ImageSize)
  CocoaMessage(0,ImageID(#iconSave),"setSize:@",@ImageSize)
  CocoaMessage(0,ImageID(#iconRefresh),"setSize:@",@ImageSize)
  CocoaMessage(0,ImageID(#iconInfo),"setSize:@",@ImageSize)
  helpOffsetY = 5
CompilerEndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  ResizeImage(#iconInfo,16,16,#PB_Image_Smooth)
  If FileSize(GetEnvironmentVariable("APPDATA") + "\osse") <> -2
    CreateDirectory(GetEnvironmentVariable("APPDATA") + "\osse")
  EndIf
  Define myCfg.s = GetEnvironmentVariable("APPDATA") + "\osse\config.ini"
CompilerElse
  If FileSize(GetEnvironmentVariable("HOME") + "/.config") <> -2
    CreateDirectory(GetEnvironmentVariable("HOME") + "/.config")
  EndIf
  If FileSize(GetEnvironmentVariable("HOME") + "/.config/osse") <> -2
    CreateDirectory(GetEnvironmentVariable("HOME") + "/.config/osse")
  EndIf
  Define myCfg.s = GetEnvironmentVariable("HOME") + "/.config/osse/config.ini"  
CompilerEndIf
OpenPreferences(myCfg)
savesPath = ReadPreferenceString("savesPath","")
lang = ReadPreferenceString("lang","")

getGamePaths()

Select lang
  Case "ru"
    If Not loadLang(lang)
      loadLang("en")
    EndIf
  Default
    lang = "en"
    loadLang("en")
EndSelect

langPathSelect()

If checkSavesPath(savesPath)

Else
  message(strings\messages("wrongSavesPath"),#mError)
  End
EndIf

WritePreferenceString("savesPath",savesPath)
WritePreferenceString("lang",lang)

ClosePreferences()

IncludeFile "gui.pb"

Repeat
  ev = WaitWindowEvent()
  Select ev
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #locationSelector
          If EventData() <> -1
            DisplayPopupMenu(#menuLocation,WindowID(#wnd))
          EndIf
        Default
          If IsGadget(EventGadget()) And GadgetType(EventGadget()) = #PB_GadgetType_TrackBar
            If IsGadget(EventGadget()-1) And GetGadgetData(EventGadget()-1)
              *caption = GetGadgetData(EventGadget()-1)
              Select EventGadget()
                Case #SMVRate
                  SetGadgetText(EventGadget()-1,ReplaceString(*caption\s,"%p",signStr((GetGadgetState(EventGadget())-100)))) ; functional programming is great
                Default
                  SetGadgetText(EventGadget()-1,ReplaceString(*caption\s,"%p",Str(GetGadgetState(EventGadget())))) ; oh shit
              EndSelect
            EndIf
            If EventData() <> -1
              DisableToolBarButton(#toolbar,#toolbarSave,#False)
              saveNeeded = #True
            EndIf
          EndIf
          If EventType() = #PB_EventType_LeftClick
            Select EventGadget()
              Case #statsSelector
                Select GetGadgetText(#statsSelector)
                  Case strings\stats\captions("selectHealth")
                    hideHealth(#False)
                    hideNeeds(#True)
                    hideSubstances(#True)
                  Case strings\stats\captions("selectNeeds")
                    hideHealth(#True)
                    hideNeeds(#False)
                    hideSubstances(#True)
                  Case strings\stats\captions("selectSubstances")
                    hideHealth(#True)
                    hideNeeds(#True)
                    hideSubstances(#False)
                EndSelect
              Default
                If IsGadget(EventGadget()) And GetGadgetData(EventGadget()) And GadgetType(EventGadget()) = #PB_GadgetType_Image
                  *caption = GetGadgetData(EventGadget())
                  message(*caption\s)
                EndIf
            EndSelect
          ElseIf EventType() = #PB_EventType_Change
            Select EventGadget()
              Case #saveSelector
                If Not saveNeeded Or message(strings\messages("selectConfirm"),#mQuestion)
                  loadSave(GetGadgetText(#saveSelector))
                  updateUI()
                  DisableToolBarButton(#toolbar,#toolbarSave,#True)
                  saveNeeded = #False
                Else
                  For i = 0 To CountGadgetItems(#saveSelector)-1
                    If GetGadgetItemText(#saveSelector,i) = currentSave
                      SetGadgetState(#saveSelector,i)
                      Break
                    EndIf
                  Next
                EndIf
              Default
                If EventGadget() > #controlsBegin And EventGadget() < #controlsEnd And EventData() <> -1
                  DisableToolBarButton(#toolbar,#toolbarSave,#False)
                  saveNeeded = #True
                EndIf
            EndSelect
          EndIf
      EndSelect
    Case #PB_Event_Menu
      Select EventMenu()
        Case #toolbarAbout
          message(~"Open Sewer Save Editor\n© deseven, 2018\n\n" + strings\translatedBy)
        Case #toolbarSave
          updateInternal()
          If saveSave(GetGadgetText(#saveSelector))
            loadSave(GetGadgetText(#saveSelector))
            DisableToolBarButton(#toolbar,#toolbarSave,#True)
            saveNeeded = #False
          Else
            message(strings\messages("saveError"),#mError)
          EndIf
        Case #toolbarRefresh
          If Not saveNeeded Or message(strings\messages("refreshConfirm"),#mQuestion)
            ClearList(saveFiles())
            checkSavesPath(savesPath)
            ClearGadgetItems(#saveSelector)
            ForEach saveFiles()
              AddGadgetItem(#saveSelector,-1,saveFiles())
            Next
            SetGadgetState(#saveSelector,0)
            loadSave(GetGadgetText(#saveSelector))
            updateUI()
            DisableToolBarButton(#toolbar,#toolbarSave,#True)
            saveNeeded = #False
          EndIf
        Case #menuLocationTenement
          SetGadgetText(#location,"73.62659,-99.900,35.45837")
          PostEvent(#PB_Event_Gadget,#wnd,#location,#PB_EventType_Change)
        Case #menuLocationMarket
          SetGadgetText(#location,"7.122754,-99.900,-26.292")
          PostEvent(#PB_Event_Gadget,#wnd,#location,#PB_EventType_Change)
        Case #menuLocationBazaar
          SetGadgetText(#location,"19.98339,-99.900,118.622")
          PostEvent(#PB_Event_Gadget,#wnd,#location,#PB_EventType_Change)
      EndSelect
    Case #PB_Event_CloseWindow
      Break
  EndSelect
ForEver
; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 125
; FirstLine = 194
; Folding = -
; EnableXP
; EnableUnicode