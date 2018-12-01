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
  If imgID
    If IsWindow(#wndLoading)
      SetGadgetState(#loadingSplash,imgID)
    Else
      If IsWindow(#wnd)
        OpenWindow(#wndLoading,#PB_Ignore,#PB_Ignore,297,140,#myName,#PB_Window_BorderLess|#PB_Window_ScreenCentered,WindowID(#wnd))
      Else
        OpenWindow(#wndLoading,#PB_Ignore,#PB_Ignore,297,140,#myName,#PB_Window_BorderLess|#PB_Window_ScreenCentered)
      EndIf
      StickyWindow(#wndLoading,#True)
      ImageGadget(#loadingSplash,0,0,297,140,imgID)
    EndIf
  Else
    If IsWindow(#wndLoading) : CloseWindow(#wndLoading) : EndIf
  EndIf
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
; CursorPosition = 64
; FirstLine = 36
; Folding = --
; EnableXP