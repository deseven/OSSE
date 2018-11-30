#myName = "Open Sewer Save Editor"
#myNameShort = "OSSE"
#myVer = "0.2.0"
#thanksTo = ~"\nnobody"

Enumeration message
  #mInfo
  #mWarning
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
  #frameSMVRate
  #SMVRate
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
  
  #helpBegin
  
  ; help buttons
  #helpName
  #helpSurname
  #helpOC
  #helpRM
  #helpBM
  #helpLocation
  #helpHealth
  #helpSMV
  #helpSMVRate
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
  
  #helpEnd
  
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

values("health")\pcre             = ~".*PLAYER_STATS_Health[ ]*=[ ]*([0-9\\-.]+)"
values("depression")\pcre         = ~".*PLAYER_STATS_Depression[ ]*=[ ]*([0-9\\-.]+)"
values("SMVProgression")\pcre     = ~".*PLAYER_STATS_SMVProgression[ ]*=[ ]*([0-9\\-.]+)"
values("SMVProgressionRate")\pcre = ~".*PLAYER_STATS_SMVProgressionRate[ ]*=[ ]*([0-9\\-.]+)"
values("tiredness")\pcre          = ~".*PLAYER_STATS_Tiredness[ ]*=[ ]*([0-9\\-.]+)"
values("hunger")\pcre             = ~".*PLAYER_STATS_Hunger[ ]*=[ ]*([0-9\\-.]+)"
values("bowel")\pcre              = ~".*PLAYER_STATS_Bowel[ ]*=[ ]*([0-9\\-.]+)"
values("thirst")\pcre             = ~".*PLAYER_STATS_Thirst[ ]*=[ ]*([0-9\\-.]+)"
values("bladder")\pcre            = ~".*PLAYER_STATS_Bladder[ ]*=[ ]*([0-9\\-.]+)"
values("smokingAddiction")\pcre   = ~".*PLAYER_STATS_SmokingAddiction[ ]*=[ ]*([0-9\\-.]+)"
values("smokingNeed")\pcre        = ~".*PLAYER_STATS_SmokingNeed[ ]*=[ ]*([0-9\\-.]+)"
values("alcoholAddiction")\pcre   = ~".*PLAYER_STATS_AlcoholAddiction[ ]*=[ ]*([0-9\\-.]+)"
values("alcoholNeed")\pcre        = ~".*PLAYER_STATS_AlcoholNeed[ ]*=[ ]*([0-9\\-.]+)"

; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 218
; FirstLine = 182
; EnableXP
; EnableUnicode