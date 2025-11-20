using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Characters }

time_update<public> := class<concrete>:

    var GameStates : []game_state = array{}
    var Break : logic = false
    Init(GameStatesArg : []game_state)<suspends>:void=
        set GameStates += GameStatesArg
        StartCountDown()
    
    StartCountDown()<suspends>:void=
        loop:
            if(Break = true):
                break
            Sleep(0.1)
            for(GameState : GameStates):      
                GameState.OnSecondPast()
