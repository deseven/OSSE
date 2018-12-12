Procedure getGamePaths()
  Shared gamePaths.s()
  Protected NewList paths.s()
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      Protected steamPath.s = ReplaceString(Reg_GetValue("HKEY_CURRENT_USER\Software\Valve\Steam","SteamPath"),"/","\")
      If Len(steamPath)
        AddElement(paths())
        paths() = steamPath + "\steamapps\common\Open Sewer"
        If ReadFile(0,steamPath + "\steamapps\libraryfolders.vdf",#PB_File_SharedRead)
          CreateRegularExpression(0,~"\"[0-9]\"[ \t]*\"([a-zA-Z:\\\\]+)\"",#PB_RegularExpression_AnyNewLine|#PB_RegularExpression_NoCase)
          While Not Eof(0)
            Protected line.s = ReadString(0)
            ;Debug line
            If ExamineRegularExpression(0,line)
              While NextRegularExpressionMatch(0)
                AddElement(paths())
                paths() = RegularExpressionGroup(0,1) + "\steamapps\common\Open Sewer"
              Wend
            EndIf
          Wend
          CloseFile(0)
        EndIf
      EndIf
      AddElement(paths())
      paths() = "C:\games\Open Sewer"
    CompilerCase #PB_OS_MacOS
      AddElement(paths())
      paths() = GetEnvironmentVariable("HOME") + "/Library/Application Support/Steam/SteamApps/common/Open Sewer"
    CompilerCase #PB_OS_Linux
      AddElement(paths())
      paths() = GetEnvironmentVariable("HOME") + "/.steam/steam/SteamApps/common/Open Sewer"
      AddElement(paths())
      paths() = GetEnvironmentVariable("HOME") + "/.local/share/Steam/SteamApps/common/Open Sewer"
      AddElement(paths())
      paths() = GetEnvironmentVariable("HOME") + "/Steam/SteamApps/common/Open Sewer"
      AddElement(paths())
      paths() = GetEnvironmentVariable("HOME") + "/.steam/common/Open Sewer"
  CompilerEndSelect
  ForEach paths()
    ;Debug "trying " + paths()
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If FileSize(paths() + "\Open Sewer_Data\StreamingAssets\Items.json") > 0
        AddElement(gamePaths())
        gamePaths() = paths()
      EndIf
    CompilerElse
      If FileSize(paths() + "/Open Sewer_Data/StreamingAssets/Items.json") > 0
        AddElement(gamePaths())
        gamePaths() = paths()
      EndIf
    CompilerEndIf
  Next
EndProcedure

Procedure checkSavesPath(path.s)
  Protected saveFound.b
  Shared saveFiles.s()
  If FileSize(path) = -2
    If ExamineDirectory(0,path,"*.sav")
      While NextDirectoryEntry(0)
        If DirectoryEntryType(0) = #PB_DirectoryEntry_File
          ;Debug "found " + DirectoryEntryName(0)
          AddElement(saveFiles())
          CompilerIf #PB_Compiler_OS = #PB_OS_Windows
            saveFiles() = path + "\" + DirectoryEntryName(0)
          CompilerElse
            saveFiles() = path + "/" + DirectoryEntryName(0)
          CompilerEndIf
          saveFound = #True
        EndIf
      Wend
      FinishDirectory(0)
      SortList(saveFiles(),#PB_Sort_Ascending|#PB_Sort_NoCase)
      ForEach(saveFiles())
        If LCase(GetFilePart(saveFiles())) = "slot10_save.sav"
          MoveElement(saveFiles(),#PB_List_Last)
          Break
        EndIf
      Next
      ForEach(saveFiles())
        If LCase(GetFilePart(saveFiles())) = "autosave.sav"
          MoveElement(saveFiles(),#PB_List_Last)
          Break
        EndIf
      Next
      If saveFound : ProcedureReturn #True : EndIf
    EndIf
  EndIf
EndProcedure

Procedure loadLang(code.s)
  Shared strings.lang
  Select code
    Case "en"
      CatchJSON(0,?langEN,?LangEND-?langEN,#PB_JSON_NoCase)
  EndSelect
  If IsJSON(0)
    ExtractJSONStructure(JSONValue(0),@strings.lang,lang)
    FreeJSON(0)
    If strings\langCode = code
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure loadItems(path.s)
  Shared items.item()
  Protected.s json
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    path + "\Open Sewer_Data\StreamingAssets\Items.json"
  CompilerElse
    path + "/Open Sewer_Data/StreamingAssets/Items.json"
  CompilerEndIf
  If ReadFile(0,path,#PB_UTF8|#PB_File_SharedRead)
    json = ReadString(0,#PB_UTF8|#PB_File_IgnoreEOL)
    If Left(json,1) <> Chr(123) ; fml
      ;Debug "removing BOM"
      json = Right(json,Len(json)-1)
    EndIf
    CloseFile(0)
    If ParseJSON(0,json,#PB_JSON_NoCase)
      ExtractJSONList(JSONValue(0),items())
      ForEach items()
        If UCase(Left(items()\category,1)) <> Left(items()\category,1)
          DeleteElement(items())
        EndIf
      Next
      SortStructuredList(items(),#PB_Sort_Ascending|#PB_Sort_NoCase,OffsetOf(item\title),#PB_String)
      ;Debug ListSize(items())
      ProcedureReturn #True
    EndIf
  EndIf
  Debug JSONErrorMessage()
  Debug JSONErrorLine()
  Debug JSONErrorPosition()
  ProcedureReturn #False
EndProcedure

Procedure.s getItemInfo(*item.item)
  Shared items.item()
  Shared strings.lang
  Protected atLeastOneValidEffect.b
  Protected itemInfo.s
  itemInfo = strings\inventory\captions("description") + ": " + *item\description + ~"\n" + 
             strings\inventory\captions("rarity") + ": " + Str(*item\rarity) + ~"\n" +
             strings\inventory\captions("value") + ": " + Str(*item\value)  + ~" OC \n"
  Select LCase(*item\use)
    Case "eat","drink","smoke":
      If LCase(*item\use) = "eat"
        itemInfo + strings\inventory\captions("usageCanBeEaten") + ~":\n"
      ElseIf LCase(*item\use) = "drink"
        itemInfo + strings\inventory\captions("usageCanBeDrinked") + ~":\n"
      Else
        itemInfo + strings\inventory\captions("usageCanBeSmoked") + ~":\n"
      EndIf
      Protected itemHungerThirstSmokeChange.s = StringField(*item\arguments,1," ")
      Protected itemAlcoholChange.s      = StringField(*item\arguments,2," ")
      Protected itemGivesItem.s          = StringField(*item\arguments,3," ")
      Protected itemSMVChange.s          = StringField(*item\arguments,4," ")
      Protected itemHealthChange.s       = StringField(*item\arguments,5," ")
      Protected itemDepressionChange.s   = StringField(*item\arguments,6," ")
      If Val(itemHungerThirstSmokeChange) <> 0
        atLeastOneValidEffect = #True
        If LCase(*item\use) = "eat"
          If Val(itemHungerThirstSmokeChange) > 0
            itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerHunger"),"%p",itemHungerThirstSmokeChange) + ~"\n"
          Else
            itemInfo + " • " + ReplaceString(strings\inventory\captions("usageIncreaseHunger"),"%p",LTrim(itemHungerThirstSmokeChange,"-")) + ~"\n"
          EndIf
        ElseIf LCase(*item\use) = "drink"
          If Val(itemHungerThirstSmokeChange) > 0
            itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerThirst"),"%p",itemHungerThirstSmokeChange) + ~"\n"
          Else
            itemInfo + " • " + ReplaceString(strings\inventory\captions("usageIncreaseThirst"),"%p",LTrim(itemHungerThirstSmokeChange,"-")) + ~"\n"
          EndIf
        Else
          If Val(itemHungerThirstSmokeChange) > 0
            itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerSmokeNeed"),"%p",itemHungerThirstSmokeChange) + ~"\n"
          Else
            itemInfo + " • " + ReplaceString(strings\inventory\captions("usageIncreaseSmokeNeed"),"%p",LTrim(itemHungerThirstSmokeChange,"-")) + ~"\n"
          EndIf
        EndIf
      EndIf
      If Val(itemAlcoholChange) <> 0
        atLeastOneValidEffect = #True
        If Val(itemAlcoholChange) < 0
          itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerAlcohol"),"%p",LTrim(itemAlcoholChange,"-")) + ~"\n"
        Else
          itemInfo + " • " + ReplaceString(strings\inventory\captions("usageIncreaseAlcohol"),"%p",itemAlcoholChange) + ~"\n"
        EndIf
      EndIf
      If Val(itemGivesItem) <> -1
        ForEach items()
          If items()\id = Val(itemGivesItem)
            atLeastOneValidEffect = #True
            itemInfo + " • " + ReplaceString(strings\inventory\captions("usageGiveItem"),"%s",items()\title) + ~"\n"
            Break
          EndIf
        Next
      EndIf
      If Val(itemSMVChange) <> 0
        atLeastOneValidEffect = #True
        If Val(itemSMVChange) < 0
          itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerSMV"),"%p",LTrim(itemSMVChange,"-")) + ~"\n"
        Else
          itemInfo + " • " + ReplaceString(strings\inventory\captions("usageIncreaseSMV"),"%p",itemSMVChange) + ~"\n"
        EndIf
      EndIf
      If Val(itemHealthChange) <> 0
        atLeastOneValidEffect = #True
        If Val(itemHealthChange) < 0
          itemInfo + " • " + ReplaceString(strings\inventory\captions("usageHurt"),"%p",LTrim(itemHealthChange,"-")) + ~"\n"
        Else
          itemInfo + " • " + ReplaceString(strings\inventory\captions("usageHeal"),"%p",itemHealthChange) + ~"\n"
        EndIf
      EndIf
      If Val(itemDepressionChange) <> 0
        atLeastOneValidEffect = #True
        If Val(itemDepressionChange) < 0
          itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerDepression"),"%p",LTrim(itemDepressionChange,"-")) + ~"\n"
        Else
          itemInfo + " • " + ReplaceString(strings\inventory\captions("usageIncreaseDepression"),"%p",itemDepressionChange) + ~"\n"
        EndIf
      EndIf
    Case "open","break":
      If LCase(*item\use) = "open"
        itemInfo + strings\inventory\captions("usageCanBeOpened") + ~":\n"
      Else
        itemInfo + strings\inventory\captions("usageCanBeBroken") + ~":\n"
      EndIf
      Protected itemOutput.s    = StringField(*item\arguments,1," ")
      Protected itemAmount.s    = StringField(*item\arguments,2," ")
      Protected itemContainer.s = StringField(*item\arguments,3," ")
      If Val(itemOutput) <> -1
        ForEach items()
          If items()\id = Val(itemOutput)
            If Val(itemAmount) > 1
              atLeastOneValidEffect = #True
              itemInfo + " • " + ReplaceString(ReplaceString(strings\inventory\captions("usageGiveItems"),"%s",items()\title),"%i",itemAmount) + ~"\n"
            ElseIf Val(itemAmount) = 1
              atLeastOneValidEffect = #True
              itemInfo + " • " + ReplaceString(strings\inventory\captions("usageGiveItem"),"%s",items()\title) + ~"\n"
            EndIf
            Break
          EndIf
        Next
      EndIf
      If Val(itemContainer) <> -1
        ForEach items()
          If items()\id = Val(itemContainer)
            atLeastOneValidEffect = #True
            itemInfo + " • " + ReplaceString(strings\inventory\captions("usageGiveItem"),"%s",items()\title) + ~"\n"
            Break
          EndIf
        Next
      EndIf
    Default
      itemInfo + ReplaceString(strings\inventory\captions("usageDefault"),"%s",*item\use) + ~"\n"
      atLeastOneValidEffect = #True
  EndSelect
  If Not atLeastOneValidEffect
    itemInfo + " • " + strings\inventory\captions("usageNothing")
  EndIf
  Select *item\id ; hardcoded because reasons!
    Case 20310:
      itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerTiredness"),"%p","15") + ~"\n"
    Case 20311:
      itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerTiredness"),"%p","20") + ~"\n"
    Case 20312:
      itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerTiredness"),"%p","25") + ~"\n"
    Case 20313:
      itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerTiredness"),"%p","15") + ~"\n"
    Case 20110:
      itemInfo + " • " + ReplaceString(strings\inventory\captions("usageLowerTiredness"),"%p","30") + ~"\n"
    Case 140030:
      itemInfo + " • " + ReplaceString(strings\inventory\captions("usageIncreaseTiredness"),"%p","65") + ~"\n"
  EndSelect
  ProcedureReturn itemInfo
EndProcedure

Procedure selectItem(gadget.i)
  Shared strings.lang
  Shared values.value()
  Shared items.item()
  Protected i.i,foundCat.b
  Shared item.item
  Protected NewMap uniqueCategories.b()
  Protected NewList categories.s()
  ClearStructure(@item,item)
  OpenWindow(#wndItem,#PB_Ignore,#PB_Ignore,250,300,ReplaceString(strings\interface("itemSelectTitle"),"%s",Str(gadget-#invBegin+1)),#PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_SystemMenu,WindowID(#wnd))
  ComboBoxGadget(#itemCategory,5,5,240,20)
  ForEach items()
    uniqueCategories(items()\category) = 1
  Next
  ForEach uniqueCategories()
    AddElement(categories())
    categories() = MapKey(uniqueCategories())
    ;Debug "adding category " + MapKey(uniqueCategories())
  Next
  SortList(categories(),#PB_Sort_Ascending|#PB_Sort_NoCase)
  ForEach categories()
    AddGadgetItem(#itemCategory,-1,categories())
  Next
  ; finding item
  ForEach items()
    If Val(values("inventorySlotID" + Str(gadget-#invBegin+8))\value) = items()\id
      item = items()
      Break
    EndIf
  Next
  For i = 0 To CountGadgetItems(#itemCategory)-1
    If item\category = GetGadgetItemText(#itemCategory,i)
      SetGadgetState(#itemCategory,i)
      Break
    EndIf
  Next
  ComboBoxGadget(#itemTitle,5,30,240,20)
  ForEach items()
    If items()\category = GetGadgetText(#itemCategory)
      AddGadgetItem(#itemTitle,-1,items()\title)
    EndIf
  Next
  For i = 0 To CountGadgetItems(#itemTitle)-1
    If item\title = GetGadgetItemText(#itemTitle,i)
      SetGadgetState(#itemTitle,i)
      Break
    EndIf
  Next
  TextGadget(#itemDescription,9,60,232,160,strings\inventory\captions("nothing"))
  If Len(item\title)
    SetGadgetText(#itemDescription,getItemInfo(item))
  EndIf
  FrameGadget(#itemSeparator,5,230,240,1,"",#PB_Frame_Flat)
  TextGadget(#itemAmountCaption,9,243,50,20,strings\inventory\captions("amount") + ":")
  SpinGadget(#itemAmount,55,240,65,20,0,65535,#PB_Spin_Numeric)
  If item\stackable > 0
    SetGadgetAttribute(#itemAmount,#PB_Spin_Maximum,item\stackable)
  EndIf
  SetGadgetState(#itemAmount,Val(values("inventorySlotAmount" + Str(gadget-#invBegin+8))\value))
  TextGadget(#itemOwnerCaption,139,243,50,20,strings\inventory\captions("owner") + ":")
  SpinGadget(#itemOwner,180,240,65,20,0,65535,#PB_Spin_Numeric)
  SetGadgetState(#itemOwner,Val(values("inventorySlotOwner" + Str(gadget-#invBegin+8))\value))
  ButtonGadget(#itemLeaveEmpty,5,270,118,25,strings\inventory\captions("leaveEmpty"))
  ButtonGadget(#itemApply,130,270,118,25,strings\inventory\captions("apply"))
  SetGadgetData(#itemApply,gadget)
  DisableWindow(#wnd,#True)
EndProcedure

Procedure langPathSelect()
  Shared lang.s
  Shared strings.lang
  Shared savesPath.s
  Shared gamePath.s
  Shared gamePaths.s()
  Shared savesPaths.s()
  OpenWindow(#wndSelect,#PB_Ignore,#PB_Ignore,400,315,#myName + " [settings]",#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SystemMenu)
  StickyWindow(#wndSelect,#True)
  ImageGadget(#PB_Any,0,0,400,180,ImageID(#splash))
  TextGadget(0,10,192,120,20,strings\options("langSelect"))
  ComboBoxGadget(1,140,190,250,20)
  AddGadgetItem(1,-1,"English")
  ;Select lang
  ;  Default
      lang = "en"
      SetGadgetState(1,0)
  ;EndSelect
  TextGadget(2,10,222,120,20,strings\options("savesPath"))
  ComboBoxGadget(3,140,220,250,20)
  AddElement(savesPaths())
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    savesPaths() = "/Volumes/Data/work/osse/saves"
  CompilerElse
    savesPaths() = GetEnvironmentVariable("USERPROFILE") + "\AppData\LocalLow\Loiste Interactive\Open Sewer"
  CompilerEndIf
  ForEach savesPaths()
    If LCase(savesPaths()) <> LCase(savesPath)
      AddGadgetItem(3,-1,savesPaths())
    EndIf
  Next
  If Len(savesPath) And FileSize(savesPath) = -2
    AddGadgetItem(3,-1,savesPath)
    SetGadgetState(3,CountGadgetItems(3)-1)
  Else
    If CountGadgetItems(3) = 0
      SetGadgetState(3,-1)
    Else
      SetGadgetState(3,0)
    EndIf
  EndIf
  AddGadgetItem(3,-1,"...")
  TextGadget(5,10,252,120,20,strings\options("gamePath"))
  ComboBoxGadget(6,140,250,250,20)
  ForEach gamePaths()
    If LCase(gamePaths()) <> LCase(gamePath)
      AddGadgetItem(6,-1,gamePaths())
    EndIf
  Next
  If Len(gamePath) And FileSize(gamePath)
    AddGadgetItem(6,-1,gamePath)
    SetGadgetState(6,CountGadgetItems(6)-1)
  Else
    If CountGadgetItems(6) = 0
      SetGadgetState(6,-1)
    Else
      SetGadgetState(6,0)
    EndIf
  EndIf
  AddGadgetItem(6,-1,"...")
  ButtonGadget(4,270,280,120,25,strings\options("apply"),#PB_Button_Default)
  Protected ev.i
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    SetGadgetFont(0,FontID(#font))
    SetGadgetFont(1,FontID(#font))
    SetGadgetFont(2,FontID(#font))
    SetGadgetFont(3,FontID(#font))
    Protected maxWidth.i = GadgetWidth(1)
    If GadgetWidth(3) > maxWidth
      maxWidth = GadgetWidth(3)
    EndIf
    If maxWidth > 220
      ResizeWindow(#wndSelect,#PB_Ignore,#PB_Ignore,WindowWidth(#wndSelect)+maxWidth-220,#PB_Ignore)
    EndIf
    ResizeGadget(4,WindowWidth(#wndSelect)-GadgetWidth(4)-10,#PB_Ignore,#PB_Ignore,#PB_Ignore)
    ResizeGadget(0,#PB_Ignore,GadgetY(0)+6,#PB_Ignore,#PB_Ignore)
    ResizeGadget(2,#PB_Ignore,GadgetY(2)+6,#PB_Ignore,#PB_Ignore)
  CompilerEndIf
  Repeat
    ev = WaitWindowEvent()
    If ev = #PB_Event_Gadget
      Select EventGadget()
        Case 1
          ;Select GetGadgetText(1)
          ;  Default
              lang = "en"
          ;EndSelect
          loadLang(lang)
          SetGadgetText(0,strings\options("langSelect"))
          SetGadgetText(2,strings\options("savesPath"))
          SetGadgetText(4,strings\options("apply"))
        Case 4
          ;Select GetGadgetText(1)
          ;  Default
              lang = "en"
          ;EndSelect
              savesPath = GetGadgetText(3)
              gamePath = GetGadgetText(6)
          Break
        Case 3
          If EventType() = #PB_EventType_Change And GetGadgetState(3) = CountGadgetItems(3)-1
            SetActiveGadget(2)
            savesPath = PathRequester(strings\options("savesPath"),GetGadgetText(3))
            If Len(savesPath)
              AddGadgetItem(3,0,savesPath)
            EndIf
            If CountGadgetItems(3) = 1
              SetGadgetState(3,-1)
            Else
              SetGadgetState(3,0)
            EndIf
          EndIf
        Case 6
          If EventType() = #PB_EventType_Change And GetGadgetState(6) = CountGadgetItems(6)-1
            SetActiveGadget(2)
            gamePath = PathRequester(strings\options("savesPath"),GetGadgetText(6))
            If Len(gamePath)
              AddGadgetItem(6,0,gamePath)
            EndIf
            If CountGadgetItems(6) = 1
              SetGadgetState(6,-1)
            Else
              SetGadgetState(6,0)
            EndIf
          EndIf
      EndSelect
    ElseIf ev = #PB_Event_CloseWindow
      End
    EndIf
  ForEver 
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    ;gtk_window_close(WindowID(#wndSelect))
    ;CloseWindow(#wndSelect)
    gtk_widget_destroy(WindowID(#wndSelect))
  CompilerElse
    CloseWindow(#wndSelect)
  CompilerEndIf
EndProcedure

Procedure loadSave(path.s)
  Shared currentSave.s
  Shared values.value()
  Shared strings.lang
  Shared missingValuesKeys.s
  currentSave = path
  Protected startTime.i = ElapsedMilliseconds()
  ;Debug "loading " + path
  If FileSize(path) < 1
    ProcedureReturn #False
  EndIf
  If Not OpenFile(0,path,#PB_File_SharedRead)
    ProcedureReturn #False
  EndIf
  Protected line.s = ReadString(0,#PB_Unicode|#PB_File_IgnoreEOL)
  ForEach values()
    values()\value = ""
    Select MapKey(values())
      Case "landmarksNotActivated"
        values()\value = "false"
        If CreateRegularExpression(0,values()\pcre,#PB_RegularExpression_AnyNewLine|#PB_RegularExpression_NoCase)
          If ExamineRegularExpression(0,line)
            While NextRegularExpressionMatch(0)
              ;Debug RegularExpressionGroup(0,1)
              If RegularExpressionGroup(0,1) = "true"
                values()\value = "true"
                Break
              EndIf
            Wend
          EndIf
          FreeRegularExpression(0)
        EndIf
      Default
        If CreateRegularExpression(0,values()\pcre,#PB_RegularExpression_AnyNewLine|#PB_RegularExpression_NoCase)
          If ExamineRegularExpression(0,line)
            While NextRegularExpressionMatch(0)
              values()\value = RegularExpressionGroup(0,1)
              Break ; should save a lot of time
            Wend
          EndIf
          FreeRegularExpression(0)
        EndIf
    EndSelect
  Next
  CloseFile(0)
  line = ""
  Protected missingValues.i = 0
  missingValuesKeys = ~"\n"
  ForEach values()
    If Not Len(values()\value)
      ;Debug "missing " + values()\pcre
      missingValues + 1
      missingValuesKeys + Str(missingValues) + ". " + MapKey(values()) + ~"\n"
    EndIf
  Next
  If missingValues
    PostEvent(#evSaveLoadError)
  EndIf
  ;Debug "took " + Str(ElapsedMilliseconds() - startTime)
  ProcedureReturn #True
EndProcedure

Procedure saveSave(path.s) ; no pun intended
  Shared values.value()
  Protected startTime.i = ElapsedMilliseconds()
  ;Debug "saving " + path
  If FileSize(path) < 1
    ProcedureReturn #False
  EndIf
  If Not OpenFile(0,path,#PB_File_SharedRead)
    ProcedureReturn #False
  EndIf
  Protected line.s = ReadString(0,#PB_Unicode|#PB_File_IgnoreEOL)
  Protected newLine.s
  Protected i.i
  ForEach values()
    ;Debug "saving " + MapKey(values()) + "=" + values()\value + ", regex: " + values()\pcre
    Select MapKey(values())
      Case "landmarksNotActivated"
        If values()\value = "false"
          Protected landmarksCount.i = 0
          If CreateRegularExpression(0,#specialNonActivatedLandmark)
            If ExamineRegularExpression(0,line)
              While NextRegularExpressionMatch(0)
                landmarksCount + 1
              Wend
            EndIf
            FreeRegularExpression(0)
          EndIf
          If landmarksCount
            For i = 1 To landmarksCount
              If CreateRegularExpression(0,#specialNonActivatedLandmark)
                If ExamineRegularExpression(0,line)
                  While NextRegularExpressionMatch(0)
                    ;Debug RegularExpressionGroup(0,1)
                    newLine = Left(line,RegularExpressionMatchPosition(0)+RegularExpressionMatchLength(0)-RegularExpressionGroupLength(0,1)-1) + values()\value + Right(line,Len(line)-RegularExpressionMatchPosition(0)-RegularExpressionMatchLength(0)+1)
                    If line <> newLine
                      line = newLine
                    EndIf
                    Break
                  Wend
                EndIf
                FreeRegularExpression(0)
              EndIf
            Next
          EndIf
        EndIf
    Default
      If CreateRegularExpression(0,values()\pcre)
        If ExamineRegularExpression(0,line)
          While NextRegularExpressionMatch(0)
            newLine = Left(line,RegularExpressionMatchPosition(0)+RegularExpressionMatchLength(0)-RegularExpressionGroupLength(0,1)-1) + values()\value + Right(line,Len(line)-RegularExpressionMatchPosition(0)-RegularExpressionMatchLength(0)+1)
            If line <> newLine
              line = newLine
            EndIf
            Break ; should save a lot of time
          Wend
        EndIf
        FreeRegularExpression(0)
      EndIf
    EndSelect
  Next
  CloseFile(0)
  ;path="C:\Users\deseven\AppData\LocalLow\Loiste Interactive\Open Sewer\slot0.txt"
  If Not CreateFile(0,path,#PB_File_SharedWrite)
    ProcedureReturn #False
  EndIf
  WriteString(0,line,#PB_Unicode)
  CloseFile(0)
  ;Debug "took " + Str(ElapsedMilliseconds() - startTime)
  ProcedureReturn #True
EndProcedure

Procedure updateInternal()
  Shared values.value()
  values("name")\value = ReplaceString(GetGadgetText(#name),~"\"","'")
  values("surname")\value = ReplaceString(GetGadgetText(#surname),~"\"","'")
  values("name")\value = RTrim(values("name")\value,"\")
  values("surname")\value = RTrim(values("surname")\value,"\")
  values("OC")\value = Str(GetGadgetState(#oc))
  values("RM")\value = Str(GetGadgetState(#rm))
  ;values("BM")\value = Str(GetGadgetState(#bm))
  values("location")\value = GetGadgetText(#location)
  
  values("health")\value = Str(GetGadgetState(#health))
  values("depression")\value = Str(GetGadgetState(#depression))
  values("SMVProgression")\value = Str(GetGadgetState(#SMV))
  values("SMVProgressionRate")\value = Str(GetGadgetState(#SMVRate)-100)
  values("tiredness")\value = Str(GetGadgetState(#tiredness))
  
  values("hunger")\value = Str(GetGadgetState(#hunger))
  values("thirst")\value = Str(GetGadgetState(#thirst))
  values("bowel")\value = Str(GetGadgetState(#bowel))
  values("bladder")\value = Str(GetGadgetState(#bladder))
  
  values("alcoholAddiction")\value = Str(GetGadgetState(#alcoholAddiction))
  values("alcoholNeed")\value = Str(GetGadgetState(#alcoholNeed))
  values("smokingAddiction")\value = Str(GetGadgetState(#smokingAddiction))
  values("smokingNeed")\value = Str(GetGadgetState(#smokingNeed))
  
  If GetGadgetState(#tutorial) = #PB_Checkbox_Checked
    values("tutorialFinished")\value = "true"
  Else
    values("tutorialFinished")\value = "false"
  EndIf
  
  values("timeGlobalDay")\value = Str(GetGadgetState(#timeDay))
  If Val(values("timeGlobalDay")\value) < 0
    values("timeGlobalDay")\value = "0"
  EndIf
  values("timeGlobalHour")\value = Str(Val(StringField(GetGadgetText(#timeHourMin),1,":")))
  values("timeGlobalMin")\value = Str(Val(StringField(GetGadgetText(#timeHourMin),2,":")))
  If Val(values("timeGlobalHour")\value) > 23
    values("timeGlobalHour")\value = "23"
  EndIf
  If Val(values("timeGlobalMin")\value) > 59
    values("timeGlobalMin")\value = "59"
  EndIf
  values("timeGlobal")\value = Str(Val(values("timeGlobalHour")\value) * 3600 + Val(values("timeGlobalMin")\value) * 60)
EndProcedure

Procedure updateUI()
  Shared values.value()
  Shared items.item()
  Shared strings.lang
  Protected i.i
  SetGadgetText(#name,values("name")\value)
  SetGadgetText(#surname,values("surname")\value)
  SetGadgetState(#oc,Val(values("OC")\value))
  SetGadgetState(#rm,Val(values("RM")\value))
  ;SetGadgetState(#bm,Val(values("BM")\value))
  SetGadgetText(#location,values("location")\value)
  
  SetGadgetState(#health,ValF(values("health")\value))
  SetGadgetState(#depression,ValF(values("depression")\value))
  SetGadgetState(#smv,ValF(values("SMVProgression")\value))
  SetGadgetState(#SMVRate,ValF(values("SMVProgressionRate")\value)+100)
  SetGadgetState(#tiredness,ValF(values("tiredness")\value))
  
  SetGadgetState(#hunger,ValF(values("hunger")\value))
  SetGadgetState(#thirst,ValF(values("thirst")\value))
  SetGadgetState(#bowel,ValF(values("bowel")\value))
  SetGadgetState(#bladder,ValF(values("bladder")\value))
  
  SetGadgetState(#alcoholAddiction,ValF(values("alcoholAddiction")\value))
  SetGadgetState(#alcoholNeed,ValF(values("alcoholNeed")\value))
  SetGadgetState(#smokingAddiction,ValF(values("smokingAddiction")\value))
  SetGadgetState(#smokingNeed,ValF(values("smokingNeed")\value))
  
  If values("tutorialFinished")\value = "true"
    SetGadgetState(#tutorial,#PB_Checkbox_Checked)
  Else
    SetGadgetState(#tutorial,#PB_Checkbox_Unchecked)
  EndIf
  
  If values("landmarksNotActivated")\value = "true"
    SetGadgetText(#mapMarkers,strings\world\captions("mapMarkersUnlock"))
    DisableGadget(#mapMarkers,#False)
  Else
    SetGadgetText(#mapMarkers,strings\world\captions("mapMarkersUnlocked"))
    DisableGadget(#mapMarkers,#True)
  EndIf
  
  SetGadgetState(#timeDay,Val(values("timeGlobalDay")\value))
  
  Protected hour.s
  If Len(values("timeGlobalHour")\value) = 1
    hour = "0" + values("timeGlobalHour")\value
  Else
    hour = values("timeGlobalHour")\value
  EndIf
  
  Protected min.s
  If Len(values("timeGlobalMin")\value) = 1
    min = "0" + values("timeGlobalMin")\value
  Else
    min = values("timeGlobalMin")\value
  EndIf
  
  SetGadgetText(#timeHourMin,hour + ":" + min)
  
  Protected itemFound.b
  For i = 0 To 34
    itemFound = #False
    ForEach items()
      If items()\id = Val(values("inventorySlotID" + Str(i+8))\value)
        SetGadgetText(#invBegin+i,values("inventorySlotAmount" + Str(i+8))\value + "x " + items()\title)
        GadgetToolTip(#invBegin+i,items()\description + ~" | " + 
                                  strings\inventory\captions("rarity") + ": " + Str(items()\rarity) + ~" | " +
                                  strings\inventory\captions("value") + ": " + Str(items()\value))
        itemFound = #True
        Break
      EndIf
    Next
    If Not itemFound
      SetGadgetText(#invBegin+i,strings\inventory\captions("nothing"))
      GadgetToolTip(#invBegin+i,"")
    EndIf
  Next
  
  ; sending events to update captions
  For i = #controlsBegin To #controlsEnd
    PostEvent(#PB_Event_Gadget,#wnd,i,0,-1)
  Next
EndProcedure

Procedure checkUpdate(dummy.i)
  If InitNetwork()
    Protected *buf = ReceiveHTTPMemory(#updateCheckURL,0,#myNameShort + "/" + #myVer)
    If *buf
      If PeekS(*buf,MemorySize(*buf),#PB_UTF8|#PB_ByteLength) <> #myVer
        PostEvent(#evUpdateFound)
      EndIf
      FreeMemory(*buf)
    EndIf
  EndIf
EndProcedure

Procedure applyUpdate()
  Shared myDir.s
  HideWindow(#wnd,#True)
  ;PostEvent(#evUpdateFailed)
  ;ProcedureReturn
  If RenameFile(myDir + "osse.exe",myDir + "osse.old")
    If ReceiveHTTPFile(#updateApplyURL,myDir + "osse.exe",0,#myNameShort + "/" + #myVer)
      RunProgram(myDir + "osse.exe","--wait-a-sec",myDir)
      End
    Else
      RenameFile(myDir + "osse.old",myDir + "osse.exe")
    EndIf
  EndIf
  PostEvent(#evUpdateFailed)
EndProcedure
; IDE Options = PureBasic 5.62 (MacOS X - x64)
; CursorPosition = 583
; FirstLine = 551
; Folding = ----
; EnableXP