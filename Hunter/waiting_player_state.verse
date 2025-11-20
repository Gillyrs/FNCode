using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }

waiting_player_state<public> := class(game_state):

    EnterState<override>():void=
        Print("EnterChild")
        (super:)EnterState()
        Print("EnterChild2")
        if(RSpawnDevice := SpawnDevice?):
            RSpawnDevice.TeleportAllLobby()
            AssignAllPlayersToTeam(3)
            
        Print("STATE: WaitingPlayersState")

    OnPlayerJoined<override>(Player : agent):void=
        if(RealPlayspace := Playspace?,
        RealPlayspace.GetParticipants().Length > 1):
            Print("Player joined during WaitingPlayersState")
            DisposeState(state.PreGameDelay)