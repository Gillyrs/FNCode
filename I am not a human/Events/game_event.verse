using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { Guest }

game_event<public> := class():
    Call():void=return
    ValidatedCall<protected>():void=return

trigger_event<public> := class(game_event):
    @editable 
    Trigger : trigger_device = trigger_device{}
    Call<override>():void=
        Print("TRIGGER EVENT: triggered")
        Trigger.Trigger()

guest_event := class(game_event):
    var EventGuest<private> :? guest = false
    var ExistingGuest<protected> : guest = guest{}
    Init(GuestArg : guest):void=
        set EventGuest = option{GuestArg}

    Call<override>():void=
        if(EventGuest?):
            ValidatedCall()

toggle_dialog := class(guest_event):
    @editable
    TurnOn : logic = true
    ValidatedCall<override>():void=
        ExistingGuest.DialogToggled.Signal(TurnOn)






