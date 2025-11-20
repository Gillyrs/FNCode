using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Characters }

state_hud<public> := class<concrete>:

    @editable State : state = state.WaitingPlayers
    @editable Hud :? hud_message_device = false
    @editable Timer :? timer_device = false