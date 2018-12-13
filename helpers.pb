Procedure realGadgetToolTip(gadget.i,tooltip.s)
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Shared hToolTips()
    Protected gadgetID.i = GadgetID(gadget)
    Protected cWndFlags
    
    If hToolTips(Str(gadgetID)) <> 0 : DestroyWindow_(hToolTips(Str(gadgetID))) : EndIf
        
    Protected hToolTip.i = CreateWindowEx_(0,"ToolTips_Class32","",#TTS_NOPREFIX,0,0,0,0,0,0,GetModuleHandle_(0),0)
    
    hToolTips(Str(gadgetID)) = hToolTip
    
    SendMessage_(hToolTip,#TTM_SETTIPTEXTCOLOR,GetSysColor_(#COLOR_INFOTEXT),0)
    SendMessage_(hToolTip,#TTM_SETTIPBKCOLOR,GetSysColor_(#COLOR_INFOBK),0)
    
    Protected tti.TOOLINFO\cbSize = SizeOf(TOOLINFO)
    tti\uFlags = #TTF_SUBCLASS|#TTF_IDISHWND
    SendMessage_(hToolTip,#TTM_SETMAXTIPWIDTH,0,300)
    
    tti\hWnd = gadgetID
    tti\uId = gadgetID  
    tti\hinst = 0
    tti\lpszText = @tooltip
        
    SendMessage_(hToolTip,#TTM_ADDTOOL,0,tti)
    
    SendMessage_(hToolTip,#TTM_SETDELAYTIME,#TTDT_INITIAL,100)
    SendMessage_(hToolTip,#TTM_SETDELAYTIME,#TTDT_AUTOPOP,20000)
    SendMessage_(hToolTip,#TTM_UPDATE,0,0)
  CompilerElse
    GadgetToolTip(gadget,tooltip)
  CompilerEndIf
EndProcedure

Macro hideHealth(state)
  HideGadget(#frameHealth,state)
  HideGadget(#health,state)
  HideGadget(#helpHealth,state)
  HideGadget(#frameSMV,state)
  HideGadget(#SMV,state)
  HideGadget(#helpSMV,state)
  HideGadget(#frameDepression,state)
  HideGadget(#depression,state)
  HideGadget(#helpDepression,state)
  HideGadget(#frameSMVRate,state)
  HideGadget(#SMVRate,state)
  HideGadget(#helpSMVRate,state)
  HideGadget(#frameTiredness,state)
  HideGadget(#tiredness,state)
  HideGadget(#helpTiredness,state)
EndMacro

Macro hideNeeds(state)
  HideGadget(#frameHunger,state)
  HideGadget(#hunger,state)
  HideGadget(#helpHunger,state)
  HideGadget(#frameThirst,state)
  HideGadget(#thirst,state)
  HideGadget(#helpThirst,state)
  HideGadget(#frameBowel,state)
  HideGadget(#bowel,state)
  HideGadget(#helpBowel,state)
  HideGadget(#frameBladder,state)
  HideGadget(#bladder,state)
  HideGadget(#helpBladder,state)
EndMacro

Macro hideSubstances(state)
  HideGadget(#frameAlcoholAddiction,state)
  HideGadget(#alcoholAddiction,state)
  HideGadget(#helpAlcoholAddiction,state)
  HideGadget(#frameAlcoholNeed,state)
  HideGadget(#alcoholNeed,state)
  HideGadget(#helpAlcoholNeed,state)
  HideGadget(#frameSmokingAddiction,state)
  HideGadget(#smokingAddiction,state)
  HideGadget(#helpSmokingAddiction,state)
  HideGadget(#frameSmokingNeed,state)
  HideGadget(#smokingNeed,state)
  HideGadget(#helpSmokingNeed,state)
EndMacro

Procedure showSplash(imgID.i = 0)
  CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS ; it turned out that mac is so fast it doesn't even need this shit
    If imgID
      If IsWindow(#wndLoading)
        SetGadgetState(#loadingSplash,imgID)
      Else
        If IsWindow(#wnd)
          OpenWindow(#wndLoading,#PB_Ignore,#PB_Ignore,400,180,#myName,#PB_Window_BorderLess|#PB_Window_WindowCentered,WindowID(#wnd))
        Else
          OpenWindow(#wndLoading,#PB_Ignore,#PB_Ignore,400,180,#myName,#PB_Window_BorderLess|#PB_Window_ScreenCentered)
        EndIf
        StickyWindow(#wndLoading,#True)
        ImageGadget(#loadingSplash,0,0,400,180,imgID)
      EndIf
    Else
      If IsWindow(#wndLoading) : CloseWindow(#wndLoading) : EndIf
    EndIf
    ;While WindowEvent() : Wend
  CompilerEndIf
EndProcedure

Procedure ForceGadgetZOrder(gadget)
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    If IsGadget(gadget)
      SetWindowLong_(GadgetID(gadget),#GWL_STYLE,GetWindowLong_(GadgetID(gadget),#GWL_STYLE)|#WS_CLIPSIBLINGS)
      SetWindowPos_(GadgetID(gadget),#HWND_TOP,0,0,0,0,#SWP_NOSIZE|#SWP_NOMOVE)
    EndIf
  CompilerEndIf
EndProcedure

Procedure.s signStr(val.i)
  If val > 0
    ProcedureReturn "+" + Str(val)
  EndIf
  ProcedureReturn Str(val)
EndProcedure

Procedure.s signStrF(val.f,dec = 2)
  If val > 0
    ProcedureReturn "+" + StrF(val,dec)
  EndIf
  ProcedureReturn StrF(val,dec)
EndProcedure

Procedure message(message.s,type.b = #mInfo)
  Protected wndID.i
  If IsWindow(#wnd) : wndID = WindowID(#wnd) : EndIf
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Select type
      Case #mError
        MessageBox_(wndID,message,"PERKELE!",#MB_OK|#MB_ICONERROR)
      Case #mWarning
        MessageBox_(wndID,message,"PERKELE!",#MB_OK|#MB_ICONWARNING)
      Case #mQuestion
        If MessageBox_(wndID,message,#myNameShort,#MB_YESNO|#MB_ICONQUESTION) = #IDYES
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      Default
        MessageBox_(wndID,message,#myNameShort,#MB_OK|#MB_ICONINFORMATION)
    EndSelect
  CompilerElse
    Select type
      Case #mQuestion
        If MessageRequester(#myNameShort,message,#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      Case #mError
        MessageRequester("PERKELE!",message)
      Default
        MessageRequester(#myNameShort,message)
    EndSelect
  CompilerEndIf
  ProcedureReturn #True
EndProcedure
; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 8
; Folding = ---
; EnableXP