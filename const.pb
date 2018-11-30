#myName = "Open Sewer Save Editor"
#myNameShort = "OSSE"
#myVer = "0.2.0"
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
  #iconRefresh
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
  #toolbarRefresh
  #toolbarAbout
  #panel
  #saveSelector
  #menuLocation
  #menuLocationTenement
  #menuLocationMarket
  #menuLocationBazaar
  #statsSelector
  
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
  #frameHealth
  #health
  #frameSMV
  #SMV
  #frameDepression
  #depression
  ; -
  #frameHunger
  #hunger
  #frameBowel
  #bowel
  #frameBladder
  #bladder
  #frameThirst
  #thirst
  #frameTiredness
  #tiredness
  ; -
  #frameAlcoholAddiction
  #alcoholAddiction
  #frameAlcoholNeed
  #alcoholNeed
  #frameSmokingAddiction
  #smokingAddiction
  #frameSmokingNeed
  #smokingNeed
  ; -
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
  #helpHealth
  #helpSMV
  #helpDepression
  #helpHunger
  #helpThirst
  #helpBowel
  #helpBladder
  #helpTiredness
  #helpAlcoholAddiction
  #helpAlcoholNeed
  #helpSmokingAddiction
  #helpSmokingNeed
  
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

DataSection
    iconAbout:
    IncludeBinary "icns/about.png"
    iconInfo:
    IncludeBinary "icns/info.png"
    iconRefresh:
    IncludeBinary "icns/refresh.png"
    iconSave:
    IncludeBinary "icns/save.png"
EndDataSection

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

values("name")\pcre               = ~".*PlayerFirstName[ ]*=[ ]*\"([^\"]+)\""
values("surname")\pcre            = ~".*PlayerLastName[ ]*=[ ]*\"([^\"]+)\""
values("OC")\pcre                 = ".*MONEY_OS[ ]*=[ ]*([0-9]+)"
values("RM")\pcre                 = ".*MONEY_RM[ ]*=[ ]*([0-9]+)"
values("BM")\pcre                 = ".*MONEY_BANK_COUNT[ ]*=[ ]*([0-9]+)"
values("location")\pcre           = ~".*Position_Open_Sewer[ ]*=[ ]*\"([0-9\\-.]+,[0-9\\-.]+,[0-9\\-.]+)"
values("SmokingAddiction")\pcre           = ~".*Smoking_Addiction[ ]*=[ ]*\"([0-9\\-.]+,[0-9\\-.]+,[0-9\\-.]+)"
; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 2
; EnableXP
; EnableUnicode