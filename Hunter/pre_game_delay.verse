using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }

pre_game_delay<public> := class(game_state):

    @editable LevelBuilder :? Levels.level_builder = false
    @editable FreezeBeforeEndTime : float = 0.0

    EnterState<override>():void=
        (super:)EnterState()
        Print("STATE: PreGameplayDelay")    
        spawn{FreezeBeforeTeleport()}
        StartTimer(DefaultDelay)

    FreezeBeforeTeleport()<suspends>:void=
        Sleep(DefaultDelay - FreezeBeforeEndTime)
        PutInStasisTeam(3)

    OnTimerSucceded<override>(Agent:?agent):void= 
        if(RPlayspace := Playspace?):
            for(Player : RPlayspace.GetParticipants()):
                AssignPlayerToTeam(1, Player)
            if(RLBuilder := LevelBuilder?):
                for(Player : RPlayspace.GetPlayers()):
                    if(RPlayer := player[Player]):
                        RLBuilder.CloseUIForPlayer(RPlayer)
                
        if(RealSpawnDevice := SpawnDevice?,
        RSpectator := SpectatorDevice?):
            RealSpawnDevice.TeleportAllRoundStart()
            RSpectator.RemoveAllAffilations()

        DisposeState(state.RoleChoice)
        
    OnPlayerJoined<override>(Player : agent):void=
        if(RealSpawnDevice := SpawnDevice?):
            RealSpawnDevice.TeleportToLobby(Player)

    OnPlayerLeft<override>(Player : agent):void=
        if(RealPlayspace := Playspace?,
        RealPlayspace.GetParticipants().Length = 1):
            DisposeState(state.WaitingPlayers)

        