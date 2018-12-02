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

LoadFont(#invFont,"Arial",8)

EnableExplicit

Define savesPath.s,gamePath.s,lang.s,currentSave.s
Define.i ev,i
Define strings.lang
Define missingValuesKeys.s
Define saveNeeded.b
Define *caption.String
NewList gamePaths.s()
NewList savesPaths.s()
NewList saveFiles.s()
NewList items.item()

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
CatchImage(#splash,?splash)
CatchImage(#splashSave,?splashSave)

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
gamePath = ReadPreferenceString("gamePath","")
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

showSplash(ImageID(#splash))

If Not checkSavesPath(savesPath)
  message(strings\messages("wrongSavesPath"),#mError)
  End 1
EndIf

If Not loadItems(gamePath + "\Open Sewer_Data\StreamingAssets\Items.json")
  message(strings\messages("wrongGamePath"),#mError)
  End 2
EndIf

WritePreferenceString("savesPath",savesPath)
WritePreferenceString("gamePath",gamePath)
WritePreferenceString("lang",lang)

ClosePreferences()

showSplash(ImageID(#splashSave))
FreeImage(#splash)

IncludeFile "gui.pb"

showSplash()
HideWindow(#wnd,#False)

Repeat
  ev = WaitWindowEvent()
  Select ev
    Case #evSaveLoadError
      message(strings\messages("missingValues") + missingValuesKeys,#mWarning)
    Case #evSaveSaveError
      message(strings\messages("saveError"),#mError)
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #locationSelector
          If EventData() <> -1
            DisplayPopupMenu(#menuLocation,WindowID(#wnd))
          EndIf
        Case #invBegin To #invEnd
          If EventData() <> -1
            selectItem(EventGadget())
          EndIf
        Case #itemApply
          If IsWindow(#wndItem)
            SetGadgetState(GetGadgetData(#itemApply),0)
            ForEach items()
              If items()\title = GetGadgetText(#itemTitle)
                ;Debug "setting " + "inventorySlotID" + Str(GetGadgetData(#itemApply)-#invBegin+8)
                values("inventorySlotID" + Str(GetGadgetData(#itemApply)-#invBegin+8))\value = Str(items()\id)
                values("inventorySlotAmount" + Str(GetGadgetData(#itemApply)-#invBegin+8))\value = Str(GetGadgetState(#itemAmount))
                values("inventorySlotOwner" + Str(GetGadgetData(#itemApply)-#invBegin+8))\value = Str(GetGadgetState(#itemOwner))
                Break
              EndIf
            Next
            updateUI()
            CloseWindow(#wndItem)
            DisableWindow(#wnd,#False)
            DisableToolBarButton(#toolbar,#toolbarSave,#False)
            saveNeeded = #True
          EndIf
        Case #itemLeaveEmpty
          If IsWindow(#wndItem)
            SetGadgetState(GetGadgetData(#itemApply),0)
            values("inventorySlotID" + Str(GetGadgetData(#itemApply)-#invBegin+8))\value = "-1"
            values("inventorySlotAmount" + Str(GetGadgetData(#itemApply)-#invBegin+8))\value = "0"
            values("inventorySlotOwner" + Str(GetGadgetData(#itemApply)-#invBegin+8))\value = "0"
            updateUI()
            CloseWindow(#wndItem)
            DisableWindow(#wnd,#False)
            DisableToolBarButton(#toolbar,#toolbarSave,#False)
            saveNeeded = #True
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
                  showSplash(ImageID(#splashSave))
                  loadSave(GetGadgetText(#saveSelector))
                  updateUI()
                  DisableToolBarButton(#toolbar,#toolbarSave,#True)
                  saveNeeded = #False
                  showSplash()
                Else
                  For i = 0 To CountGadgetItems(#saveSelector)-1
                    If GetGadgetItemText(#saveSelector,i) = currentSave
                      SetGadgetState(#saveSelector,i)
                      Break
                    EndIf
                  Next
                EndIf
              Case #itemCategory
                ClearGadgetItems(#itemTitle)
                ForEach items()
                  If items()\category = GetGadgetText(#itemCategory)
                    AddGadgetItem(#itemTitle,-1,items()\title)
                  EndIf
                Next
                SetGadgetText(#itemDescription,"")
              Case #itemTitle
                ForEach items()
                  If items()\title = GetGadgetText(#itemTitle)
                    If Not GetGadgetState(#itemAmount)
                      SetGadgetState(#itemAmount,1)
                    EndIf
                    If Not GetGadgetState(#itemOwner)
                      SetGadgetState(#itemOwner,0)
                    EndIf
                    SetGadgetText(#itemDescription,strings\inventory\captions("description") + ": " + items()\description + ~"\n" + 
                                                   strings\inventory\captions("rarity") + ": " + Str(items()\rarity) + ~"\n" +
                                                   strings\inventory\captions("value") + ": " + Str(items()\value))
                    Break  
                  EndIf
                Next
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
          message(#myName + " " + #myVer + ~"\n© deseven, 2018\n\n" + strings\translatedBy)
        Case #toolbarSave
          showSplash(ImageID(#splashSave))
          updateInternal()
          If saveSave(GetGadgetText(#saveSelector))
            loadSave(GetGadgetText(#saveSelector))
            DisableToolBarButton(#toolbar,#toolbarSave,#True)
            saveNeeded = #False
          Else
            PostEvent(#evSaveSaveError)
          EndIf
          updateUI()
          showSplash()
        Case #toolbarRefresh
          If Not saveNeeded Or message(strings\messages("refreshConfirm"),#mQuestion)
            showSplash(ImageID(#splashSave))
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
            showSplash()
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
      Select EventWindow()
        Case #wnd
          If Not saveNeeded Or message(strings\messages("exitConfirm"),#mQuestion)
            Break
          EndIf
        Case #wndItem
          SetGadgetState(GetGadgetData(#itemApply),0)          
          CloseWindow(#wndItem)
          DisableWindow(#wnd,#False)
     EndSelect
  EndSelect
ForEver
; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 276
; FirstLine = 258
; Folding = -
; EnableXP
; EnableUnicode