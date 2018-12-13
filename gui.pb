OpenWindow(#wnd,#PB_Ignore,#PB_Ignore,640,285,#myName + " " + #myVer,#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible)
;SmartWindowRefresh(#wnd,#True)

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
MenuItem(#menuLocationTenementRoof,"Your tenement roof")
MenuItem(#menuLocationBazaar,"Bazaar")
MenuItem(#menuLocationMarket,"Market")
MenuItem(#menuLocationShroomWorld,"Shroom world")

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Linux
    PanelGadget(#panel,0,50,640,250)
  CompilerCase #PB_OS_MacOS
    ResizeWindow(#wnd,#PB_Ignore,#PB_Ignore,WindowWidth(#wnd)+10,WindowHeight(#wnd)+30)
    ComboBoxGadget(#saveSelector,5,20,640,20)
    PanelGadget(#panel,0,50,650,270)
  CompilerDefault
    ComboBoxGadget(#saveSelector,5,ToolBarHeight(#toolbar)+2,630,20)
    PanelGadget(#panel,0,ToolBarHeight(#toolbar)+30,645,275)
CompilerEndSelect

ForEach saveFiles()
  AddGadgetItem(#saveSelector,-1,saveFiles())
Next
SetGadgetState(#saveSelector,0)

;{ character
AddGadgetItem(#panel,-1,strings\interface("character"))

FrameGadget(#frameName,5,5,305,50,strings\character\captions("name"))
If IsFont(#frameFont) : SetGadgetFont(#frameName,FontID(#frameFont)) : EndIf
StringGadget(#name,15+gadOffsetX,25+gadOffsetY,285,20,"")
ImageGadget(#helpName,300,5+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpName,strings\character\help("name"))
SetGadgetData(#helpName,@strings\character\help("name"))

FrameGadget(#frameSurname,320,5,305,50,strings\character\captions("surname"))
If IsFont(#frameFont) : SetGadgetFont(#frameSurname,FontID(#frameFont)) : EndIf
StringGadget(#surname,330+gadOffsetX,25+gadOffsetY,285,20,"")
ImageGadget(#helpSurname,615,5+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpSurname,strings\character\help("surname"))
SetGadgetData(#helpSurname,@strings\character\help("surname"))

FrameGadget(#frameOC,5,60,305,50,strings\character\captions("openSewerCoins"))
If IsFont(#frameFont) : SetGadgetFont(#frameOC,FontID(#frameFont)) : EndIf
SpinGadget(#oc,15+gadOffsetX,80+gadOffsetY,80,20,0,65535,#PB_Spin_Numeric)
SetGadgetFont(#oc,FontID(#font))
ImageGadget(#helpOC,300,60+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpOC,strings\character\help("openSewerCoins"))
SetGadgetData(#helpOC,@strings\character\help("openSewerCoins"))

FrameGadget(#frameRM,5,115,305,50,strings\character\captions("realMoney"))
If IsFont(#frameFont) : SetGadgetFont(#frameRM,FontID(#frameFont)) : EndIf
SpinGadget(#rm,15+gadOffsetX,135+gadOffsetY,80,20,0,65535,#PB_Spin_Numeric)
SetGadgetFont(#rm,FontID(#font))
ImageGadget(#helpRM,300,115+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpRM,strings\character\help("realMoney"))
SetGadgetData(#helpRM,@strings\character\help("realMoney"))

FrameGadget(#frameLocation,320,60,305,75,strings\character\captions("playerLocation"))
If IsFont(#frameFont) : SetGadgetFont(#frameLocation,FontID(#frameFont)) : EndIf
StringGadget(#location,330+gadOffsetX,80+gadOffsetY,285,20,"")
CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  ButtonGadget(#locationSelector,325,105,295,25,strings\character\captions("playerLocationSelect"))
CompilerElse
  ButtonGadget(#locationSelector,330,105,285,20,strings\character\captions("playerLocationSelect"))
CompilerEndIf
ImageGadget(#helpLocation,615,60+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpLocation,strings\character\help("playerLocation"))
SetGadgetData(#helpLocation,@strings\character\help("playerLocation"))

ImageGadget(#bgCharacter,565,160,64,64,ImageID(#iconCharacter))
;}

;{ stats
AddGadgetItem(#panel,-1,strings\interface("stats"))

; health
ListViewGadget(#statsSelector,5,5,100,215)
AddGadgetItem(#statsSelector,-1,strings\stats\captions("selectHealth"))
AddGadgetItem(#statsSelector,-1,strings\stats\captions("selectNeeds"))
AddGadgetItem(#statsSelector,-1,strings\stats\captions("selectSubstances"))
SetGadgetState(#statsSelector,0)

FrameGadget(#frameHealth,115,5,250,50,strings\stats\captions("health"))
If IsFont(#frameFont) : SetGadgetFont(#frameHealth,FontID(#frameFont)) : EndIf
TrackBarGadget(#health,125+gadOffsetX,22+gadOffsetY,230,26,0,100)
ImageGadget(#helpHealth,355,5+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpHealth,strings\stats\help("health"))
SetGadgetData(#frameHealth,@strings\stats\captions("health"))
SetGadgetData(#helpHealth,@strings\stats\help("health"))

FrameGadget(#frameSMV,375,5,250,50,strings\stats\captions("smv"))
If IsFont(#frameFont) : SetGadgetFont(#frameSMV,FontID(#frameFont)) : EndIf
TrackBarGadget(#smv,385+gadOffsetX,22+gadOffsetY,230,26,0,100)
ImageGadget(#helpSMV,615,5+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpSMV,strings\stats\help("smv"))
SetGadgetData(#frameSMV,@strings\stats\captions("smv"))
SetGadgetData(#helpSMV,@strings\stats\help("smv"))

FrameGadget(#frameDepression,115,60,250,50,strings\stats\captions("depression"))
If IsFont(#frameFont) : SetGadgetFont(#frameDepression,FontID(#frameFont)) : EndIf
TrackBarGadget(#depression,125+gadOffsetX,77+gadOffsetY,230,26,0,100)
ImageGadget(#helpDepression,355,60+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpDepression,strings\stats\help("depression"))
SetGadgetData(#frameDepression,@strings\stats\captions("depression"))
SetGadgetData(#helpDepression,@strings\stats\help("depression"))

FrameGadget(#frameSMVRate,375,60,250,50,strings\stats\captions("smvRate"))
If IsFont(#frameFont) : SetGadgetFont(#frameSMVRate,FontID(#frameFont)) : EndIf
TrackBarGadget(#SMVRate,385+gadOffsetX,77+gadOffsetY,230,26,0,200)
ImageGadget(#helpSMVRate,615,60+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpSMVRate,strings\stats\help("smvRate"))
SetGadgetData(#frameSMVRate,@strings\stats\captions("smvRate"))
SetGadgetData(#helpSMVRate,@strings\stats\help("smvRate"))

FrameGadget(#frameTiredness,115,115,250,50,strings\stats\captions("tiredness"))
If IsFont(#frameFont) : SetGadgetFont(#frameTiredness,FontID(#frameFont)) : EndIf
TrackBarGadget(#tiredness,125+gadOffsetX,132+gadOffsetY,230,26,0,100)
ImageGadget(#helpTiredness,355,115+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpTiredness,strings\stats\help("tiredness"))
SetGadgetData(#frameTiredness,@strings\stats\captions("tiredness"))
SetGadgetData(#helpTiredness,@strings\stats\help("tiredness"))

; needs
FrameGadget(#frameHunger,115,5,250,50,strings\stats\captions("hunger"))
If IsFont(#frameFont) : SetGadgetFont(#frameHunger,FontID(#frameFont)) : EndIf
TrackBarGadget(#hunger,125+gadOffsetX,22+gadOffsetY,230,26,0,100)
ImageGadget(#helpHunger,355,5+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpHunger,strings\stats\help("hunger"))
SetGadgetData(#frameHunger,@strings\stats\captions("hunger"))
SetGadgetData(#helpHunger,@strings\stats\help("hunger"))

FrameGadget(#frameBowel,375,5,250,50,strings\stats\captions("bowel"))
If IsFont(#frameFont) : SetGadgetFont(#frameBowel,FontID(#frameFont)) : EndIf
TrackBarGadget(#bowel,385+gadOffsetX,22+gadOffsetY,230,26,0,100)
ImageGadget(#helpBowel,615,5+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpBowel,strings\stats\help("bowel"))
SetGadgetData(#frameBowel,@strings\stats\captions("bowel"))
SetGadgetData(#helpBowel,@strings\stats\help("bowel"))

FrameGadget(#frameThirst,115,60,250,50,strings\stats\captions("thirst"))
If IsFont(#frameFont) : SetGadgetFont(#frameThirst,FontID(#frameFont)) : EndIf
TrackBarGadget(#thirst,125+gadOffsetX,77+gadOffsetY,230,26,0,100)
ImageGadget(#helpThirst,355,60+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpThirst,strings\stats\help("thirst"))
SetGadgetData(#frameThirst,@strings\stats\captions("thirst"))
SetGadgetData(#helpThirst,@strings\stats\help("thirst"))

FrameGadget(#frameBladder,375,60,250,50,strings\stats\captions("bladder"))
If IsFont(#frameFont) : SetGadgetFont(#frameBladder,FontID(#frameFont)) : EndIf
TrackBarGadget(#bladder,385+gadOffsetX,77+gadOffsetY,230,26,0,100)
ImageGadget(#helpBladder,615,60+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpBladder,strings\stats\help("bladder"))
SetGadgetData(#frameBladder,@strings\stats\captions("bladder"))
SetGadgetData(#helpBladder,@strings\stats\help("bladder"))

; substances
FrameGadget(#frameAlcoholAddiction,115,5,250,50,strings\stats\captions("alcoholAddiction"))
If IsFont(#frameFont) : SetGadgetFont(#frameAlcoholAddiction,FontID(#frameFont)) : EndIf
TrackBarGadget(#alcoholAddiction,125+gadOffsetX,22+gadOffsetY,230,26,0,100)
ImageGadget(#helpAlcoholAddiction,355,5+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpAlcoholAddiction,strings\stats\help("alcoholAddiction"))
SetGadgetData(#frameAlcoholAddiction,@strings\stats\captions("alcoholAddiction"))
SetGadgetData(#helpAlcoholAddiction,@strings\stats\help("alcoholAddiction"))

FrameGadget(#frameSmokingAddiction,375,5,250,50,strings\stats\captions("smokingAddiction"))
If IsFont(#frameFont) : SetGadgetFont(#frameSmokingAddiction,FontID(#frameFont)) : EndIf
TrackBarGadget(#smokingAddiction,385+gadOffsetX,22+gadOffsetY,230,26,0,100)
ImageGadget(#helpSmokingAddiction,615,5+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpSmokingAddiction,strings\stats\help("smokingAddiction"))
SetGadgetData(#frameSmokingAddiction,@strings\stats\captions("smokingAddiction"))
SetGadgetData(#helpSmokingAddiction,@strings\stats\help("smokingAddiction"))

FrameGadget(#frameAlcoholNeed,115,60,250,50,strings\stats\captions("alcoholNeed"))
If IsFont(#frameFont) : SetGadgetFont(#frameAlcoholNeed,FontID(#frameFont)) : EndIf
TrackBarGadget(#alcoholNeed,125+gadOffsetX,77+gadOffsetY,230,26,0,100)
ImageGadget(#helpAlcoholNeed,355,60+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpAlcoholNeed,strings\stats\help("alcoholNeed"))
SetGadgetData(#frameAlcoholNeed,@strings\stats\captions("alcoholNeed"))
SetGadgetData(#helpAlcoholNeed,@strings\stats\help("alcoholNeed"))

FrameGadget(#frameSmokingNeed,375,60,250,50,strings\stats\captions("smokingNeed"))
If IsFont(#frameFont) : SetGadgetFont(#frameSmokingNeed,FontID(#frameFont)) : EndIf
TrackBarGadget(#smokingNeed,385+gadOffsetX,77+gadOffsetY,230,26,0,100)
ImageGadget(#helpSmokingNeed,615,60+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpSmokingNeed,strings\stats\help("smokingNeed"))
SetGadgetData(#frameSmokingNeed,@strings\stats\captions("smokingNeed"))
SetGadgetData(#helpSmokingNeed,@strings\stats\help("smokingNeed"))

ImageGadget(#bgStats,565,160,64,64,ImageID(#iconStats))
;}

;{ inventory
AddGadgetItem(#panel,-1,strings\interface("inventory"))
Define.b x,y
i = 0
For y = 0 To 6
  For x = 0 To 4
    ButtonGadget(#invBegin+i,5+110*x,5+31*y,110,31,strings\inventory\captions("nothing"),#PB_Button_MultiLine|#PB_Button_Toggle)
    SetGadgetFont(#invBegin+i,FontID(#invFont))
    i + 1
  Next
Next
ImageGadget(#bgInventory,565,160,64,64,ImageID(#iconInventory))
;}

;{ tenement
AddGadgetItem(#panel,-1,strings\interface("tenement"))
TextGadget(#placeholderTenement,GadgetWidth(#panel)/2-100,GadgetHeight(#panel)/2-50,200,20,strings\tenement\placeholder,#PB_Text_Center)
ImageGadget(#bgTenement,565,160,64,64,ImageID(#iconTenement))
;}

;{ quests
AddGadgetItem(#panel,-1,strings\interface("quests"))
TextGadget(#placeholderQuests,GadgetWidth(#panel)/2-100,GadgetHeight(#panel)/2-50,200,20,strings\quests\placeholder,#PB_Text_Center)
ImageGadget(#bgQuests,565,160,64,64,ImageID(#iconQuests))
;}

;{ world
AddGadgetItem(#panel,-1,strings\interface("world"))

FrameGadget(#frameTutorial,5,5,305,50,strings\world\captions("tutorial"))
If IsFont(#frameFont) : SetGadgetFont(#frameTutorial,FontID(#frameFont)) : EndIf
CheckBoxGadget(#tutorial,15+gadOffsetX,25+gadOffsetY,285,20,strings\world\captions("tutorialFinished"))
ImageGadget(#helpTutorial,300,5+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpTutorial,strings\world\help("tutorial"))
SetGadgetData(#helpTutorial,@strings\world\help("tutorial"))

FrameGadget(#frameMapMarkers,5,60,305,50,strings\world\captions("mapMarkers"))
If IsFont(#frameFont) : SetGadgetFont(#frameMapMarkers,FontID(#frameFont)) : EndIf
ButtonGadget(#mapMarkers,15+gadOffsetX,80+gadOffsetY,285,20,"")
ImageGadget(#helpMapMarkers,300,60+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpMapMarkers,strings\world\help("mapMarkers"))
SetGadgetData(#helpMapMarkers,@strings\world\help("mapMarkers"))

FrameGadget(#frameTime,320,5,305,75,strings\world\captions("time"))
If IsFont(#frameFont) : SetGadgetFont(#frameTime,FontID(#frameFont)) : EndIf
TextGadget(#timeDayCaption,330+gadOffsetX,27+gadOffsetY,65,20,strings\world\captions("timeDay") + ":")
SpinGadget(#timeDay,400+gadOffsetX,25+gadOffsetY,80,20,0,65535,#PB_Spin_Numeric)
TextGadget(#timeHourMinCaption,330+gadOffsetX,52+gadOffsetY,65,20,strings\world\captions("timeHourMin") + ":")
StringGadget(#timeHourMin,400+gadOffsetX,50+gadOffsetY,80,20,"")
ImageGadget(#helpTime,615,5+helpOffsetY,16,16,ImageID(#iconInfo))
realGadgetToolTip(#helpTime,strings\world\help("time"))
SetGadgetData(#helpTime,@strings\world\help("time"))

ImageGadget(#bgWorld,565,160,64,64,ImageID(#iconWorld))
;}

;SetGadgetState(#panel,5)

; making help icons on top of controls
For i = #controlsBegin+1 To #controlsEnd-1
  ForceGadgetZOrder(i)
Next
For i = #helpBegin+1 To #helpEnd-1
  ForceGadgetZOrder(i)
Next

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  CocoaMessage(0,GadgetID(#name),"setBezelStyle:",10)
  CocoaMessage(0,GadgetID(#name),"setFocusRingType:",1)
  CocoaMessage(0,GadgetID(#surname),"setBezelStyle:",10)
  CocoaMessage(0,GadgetID(#surname),"setFocusRingType:",1)
  CocoaMessage(0,GadgetID(#location),"setBezelStyle:",10)
  CocoaMessage(0,GadgetID(#location),"setFocusRingType:",1)
  CocoaMessage(0,GadgetID(#timeHourMin),"setBezelStyle:",10)
  CocoaMessage(0,GadgetID(#timeHourMin),"setFocusRingType:",1)
CompilerEndIf

RemoveKeyboardShortcut(#wnd,#PB_Shortcut_Tab)
SetActiveGadget(#frameName)

hideNeeds(#True)
hideSubstances(#True)
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 280
; FirstLine = 78
; Folding = H9
; EnableXP