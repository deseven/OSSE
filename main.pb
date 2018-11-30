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
NewList gamePaths.s()
NewList savesPaths.s()
NewList saveFiles.s()

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

OpenWindow(#wnd,#PB_Ignore,#PB_Ignore,640,285,#myName + " " + #myVer,#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible)
SmartWindowRefresh(#wnd,#True)

CreateToolBar(#toolbar,WindowID(#wnd))
ToolBarImageButton(#toolbarSave,ImageID(#iconSave))
ToolBarImageButton(#toolbarRefresh,ImageID(#iconRefresh))
ToolBarImageButton(#toolbarAbout,ImageID(#iconAbout))
ToolBarToolTip(#toolbar,#toolbarSave,strings\interface("toolbarSave"))
ToolBarToolTip(#toolbar,#toolbarRefresh,strings\interface("toolbarRefresh"))
ToolBarToolTip(#toolbar,#toolbarAbout,strings\interface("toolbarAbout"))
ResizeWindow(#wnd,#PB_Ignore,#PB_Ignore,WindowWidth(#wnd),WindowHeight(#wnd)+ToolBarHeight(#toolbar))
CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  CocoaMessage(0,CocoaMessage(0,WindowID(#wnd),"standardWindowButton:",1),"setHidden:",#YES)
  CocoaMessage(0,CocoaMessage(0,WindowID(#wnd),"standardWindowButton:",2),"setHidden:",#YES)
CompilerEndIf

CreatePopupMenu(#menuLocation)
MenuItem(#menuLocationTenement,"Your tenement")
MenuItem(#menuLocationBazaar,"Bazaar")
MenuItem(#menuLocationMarket,"Market")

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Linux
    PanelGadget(#panel,0,50,640,250)
  CompilerCase #PB_OS_MacOS
    ResizeWindow(#wnd,#PB_Ignore,#PB_Ignore,WindowWidth(#wnd)+30,WindowHeight(#wnd)+30)
    ComboBoxGadget(#saveSelector,5,20,650,20)
    PanelGadget(#panel,0,50,660,270)
  CompilerDefault
    ComboBoxGadget(#saveSelector,5,ToolBarHeight(#toolbar),630,20)
    PanelGadget(#panel,0,ToolBarHeight(#toolbar)+30,645,275)
CompilerEndSelect

ForEach saveFiles()
  AddGadgetItem(#saveSelector,-1,saveFiles())
Next
SetGadgetState(#saveSelector,0)

AddGadgetItem(#panel,-1,strings\interface("character"))
FrameGadget(#frameName,5,5,305,50,strings\character\captions("name"))
If IsFont(#frameFont) : SetGadgetFont(#frameName,FontID(#frameFont)) : EndIf
StringGadget(#name,15,25,285,20,"Esko")
ImageGadget(#helpName,300,5+helpOffsetY,16,16,ImageID(#iconInfo))
GadgetToolTip(#helpName,strings\character\help("name"))
FrameGadget(#frameSurname,5,60,305,50,strings\character\captions("surname"))
If IsFont(#frameFont) : SetGadgetFont(#frameSurname,FontID(#frameFont)) : EndIf
StringGadget(#surname,15+gadOffsetX,80+gadOffsetY,285,20,"Virtanen")
ImageGadget(#helpSurname,300,60+helpOffsetY,16,16,ImageID(#iconInfo))
GadgetToolTip(#helpSurname,strings\character\help("surname"))
FrameGadget(#frameOC,5,115,305,50,strings\character\captions("openSewerCoins"))
If IsFont(#frameFont) : SetGadgetFont(#frameOC,FontID(#frameFont)) : EndIf
SpinGadget(#oc,15+gadOffsetX,135+gadOffsetY,80,20,0,65535,#PB_Spin_Numeric)
SetGadgetState(#oc,10)
SetGadgetFont(#oc,FontID(#font))
ImageGadget(#helpOC,300,115+helpOffsetY,16,16,ImageID(#iconInfo))
GadgetToolTip(#helpOC,strings\character\help("openSewerCoins"))
FrameGadget(#frameRM,5,170,305,50,strings\character\captions("realMoney"))
If IsFont(#frameFont) : SetGadgetFont(#frameRM,FontID(#frameFont)) : EndIf
SpinGadget(#rm,15+gadOffsetX,190+gadOffsetY,80,20,0,65535,#PB_Spin_Numeric)
SetGadgetState(#rm,0)
SetGadgetFont(#rm,FontID(#font))
ImageGadget(#helpRM,300,170+helpOffsetY,16,16,ImageID(#iconInfo))
GadgetToolTip(#helpRM,strings\character\help("realMoney"))
; |
FrameGadget(#frameLocation,320,5,305,75,strings\character\captions("playerLocation"))
If IsFont(#frameFont) : SetGadgetFont(#frameLocation,FontID(#frameFont)) : EndIf
If IsFont(#frameFont) : SetGadgetFont(#frameName,FontID(#frameFont)) : EndIf
StringGadget(#location,330,25,285,20,"-56.67583,-100.05,90.42398")
CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  ButtonGadget(#locationSelector,325,50,295,25,strings\character\captions("playerLocationSelect"))
CompilerElse
  ButtonGadget(#locationSelector,330,50,285,20,strings\character\captions("playerLocationSelect"))
CompilerEndIf
ImageGadget(#helpLocation,615,5+helpOffsetY,16,16,ImageID(#iconInfo))
GadgetToolTip(#helpLocation,strings\character\help("playerLocation"))
ImageGadget(#bgCharacter,565,160,64,64,ImageID(#iconCharacter))

; ForceGadgetZOrder(#frameMillisPerDay)
; ForceGadgetZOrder(#helpMillisPerDay)
; ForceGadgetZOrder(#frameForestLevel)
; ForceGadgetZOrder(#helpForestLevel)
; ForceGadgetZOrder(#frameForestDensity)
; ForceGadgetZOrder(#helpForestDensity)
; ForceGadgetZOrder(#frameSingleDensity)
; ForceGadgetZOrder(#helpSingleDensity)

AddGadgetItem(#panel,-1,strings\interface("stats"))
TextGadget(#placeholderStats,GadgetWidth(#panel)/2-100,GadgetHeight(#panel)/2-50,200,20,strings\stats\placeholder,#PB_Text_Center)
ImageGadget(#bgStats,565,160,64,64,ImageID(#iconStats))

AddGadgetItem(#panel,-1,strings\interface("inventory"))
TextGadget(#placeholderInventory,GadgetWidth(#panel)/2-100,GadgetHeight(#panel)/2-50,200,20,strings\inventory\placeholder,#PB_Text_Center)
ImageGadget(#bgInventory,565,160,64,64,ImageID(#iconInventory))

AddGadgetItem(#panel,-1,strings\interface("tenement"))
TextGadget(#placeholderTenement,GadgetWidth(#panel)/2-100,GadgetHeight(#panel)/2-50,200,20,strings\tenement\placeholder,#PB_Text_Center)
ImageGadget(#bgTenement,565,160,64,64,ImageID(#iconTenement))

AddGadgetItem(#panel,-1,strings\interface("quests"))
TextGadget(#placeholderQuests,GadgetWidth(#panel)/2-100,GadgetHeight(#panel)/2-50,200,20,strings\quests\placeholder,#PB_Text_Center)
ImageGadget(#bgQuests,565,160,64,64,ImageID(#iconQuests))

AddGadgetItem(#panel,-1,strings\interface("world"))
TextGadget(#placeholderWorld,GadgetWidth(#panel)/2-100,GadgetHeight(#panel)/2-50,200,20,strings\world\placeholder,#PB_Text_Center)
ImageGadget(#bgWorld,565,160,64,64,ImageID(#iconWorld))

;SetGadgetState(#panel,2)

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  CocoaMessage(0,GadgetID(#name),"setBezelStyle:",10)
  CocoaMessage(0,GadgetID(#name),"setFocusRingType:",1)
  CocoaMessage(0,GadgetID(#surname),"setBezelStyle:",10)
  CocoaMessage(0,GadgetID(#surname),"setFocusRingType:",1)
  CocoaMessage(0,GadgetID(#location),"setBezelStyle:",10)
  CocoaMessage(0,GadgetID(#location),"setFocusRingType:",1)
CompilerEndIf

loadSave(GetGadgetText(#saveSelector))
updateUI()
DisableToolBarButton(#toolbar,#toolbarSave,#True)
RemoveKeyboardShortcut(#wnd,#PB_Shortcut_Tab)

HideWindow(#wnd,#False)

Repeat
  ev = WaitWindowEvent()
  Select ev
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #locationSelector
          If EventData() <> 1
            DisplayPopupMenu(#menuLocation,WindowID(#wnd))
          EndIf
        Default
          If EventType() = #PB_EventType_LeftClick
            Select EventGadget()
              Case #helpName
                message(strings\character\help("name"))
              Case #helpSurname
                message(strings\character\help("surname"))
              Case #helpOC
                message(strings\character\help("openSewerCoins"))
              Case #helpRM
                message(strings\character\help("realMoney"))
              Case #helpLocation
                message(strings\character\help("playerLocation"))
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
            EndSelect
          EndIf
      EndSelect
      If EventGadget() > #controlsBegin And EventGadget() < #controlsEnd And EventData() <> 1 And EventType() = #PB_EventType_Change
        DisableToolBarButton(#toolbar,#toolbarSave,#False)
        saveNeeded = #True
      EndIf
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
; CursorPosition = 272
; FirstLine = 256
; Folding = --
; EnableXP
; EnableUnicode