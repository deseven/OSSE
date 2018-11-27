#myName = "Open Sewer Save Editor"
#myNameShort = "OSSE"
#myVer = "0.1.0"
#thanksTo = ~"\nnobody"

Enumeration message
  #mInfo
  #mQuestion
  #mError
EndEnumeration

Enumeration res
  #font
  #frameFont
  #iconInfo
  #iconRevert
  #iconSave
  #iconAbout
  #iconMain
  #iconCharacter
  #iconStats
  #iconInventory
  #iconTenement
  #iconQuests
  #iconWorld
EndEnumeration

Enumeration main
  ; global
  #wnd
  #wndSelect
  #toolbar
  #toolbarSave
  #toolbarRevert
  #toolbarAbout
  #panel
  #saveSelector
  #menuLocation
  
  #controlsBegin
  
  ; character
  #frameName
  #name
  #frameSurname
  #surname
  #frameOC
  #oc
  #frameRM
  #rm
  #frameBM
  #bm
  #frameLocation
  #location
  #locationSelector
  #bgCharacter
  
  ; stats
  #placeholderStats
  #bgStats
  
  ; inventory
  #placeholderInventory
  #bgInventory
  
  ; tenement
  #placeholderTenement
  #bgTenement
  
  ; quests
  #placeholderQuests
  #bgQuests
  
  ; world
  #placeholderWorld
  #bgWorld
  
  #controlsEnd
  
  ; help buttons
  #helpName
  #helpSurname
  #helpOC
  #helpRM
  #helpBM
  #helpLocation
EndEnumeration

Structure value
  value.s
  pcre.s
EndStructure

Structure category
  Map captions.s()
  Map help.s()
  placeholder.s
EndStructure

Structure lang
  langCode.s
  langName.s
  translatedBy.s
  Map options.s()
  Map Interface.s()
  Map messages.s()
  character.category
  stats.category
  inventory.category
  tenement.category
  quests.category
  world.category
EndStructure

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  DataSection
    iconAbout:
    IncludeBinary "icns/about.ico"
    iconInfo:
    IncludeBinary "icns/info.ico"
    iconRevert:
    IncludeBinary "icns/revert.ico"
    iconSave:
    IncludeBinary "icns/save.ico"
  EndDataSection
CompilerElse
  DataSection
    iconAbout:
    IncludeBinary "icns/about.png"
    iconInfo:
    IncludeBinary "icns/info.png"
    iconRevert:
    IncludeBinary "icns/revert.png"
    iconSave:
    IncludeBinary "icns/save.png"
    iconMain:
    IncludeBinary "icns/main48.png"
  EndDataSection
CompilerEndIf

DataSection
  langEN:
  IncludeBinary "lang/en.json"
  LangEND:
EndDataSection

DataSection
  iconCharacter:
  IncludeBinary "icns/character.png"
  iconStats:
  IncludeBinary "icns/stats.png"
  iconInventory:
  IncludeBinary "icns/inventory.png"
  iconTenement:
  IncludeBinary "icns/tenement.png"
  iconQuests:
  IncludeBinary "icns/quests.png"
  iconWorld:
  IncludeBinary "icns/world.png"
EndDataSection

NewMap values.value()

values("name")\pcre               = ~".*PlayerFirstName[ ]*=[ ]*\"([a-zA-Z0-9]+)\""
values("surname")\pcre               = ~".*PlayerLastName[ ]*=[ ]*\"([a-zA-Z0-9]+)\""
values("OC")\pcre               = ".*MONEY_OS[ ]*=[ ]*([0-9]+)"
values("RM")\pcre               = ".*MONEY_RM[ ]*=[ ]*([0-9]+)"
values("BM")\pcre               = ".*MONEY_BANK_COUNT[ ]*=[ ]*([0-9]+)"

; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 37
; Folding = -
; EnableXP
; EnableUnicode