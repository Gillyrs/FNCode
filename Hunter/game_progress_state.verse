using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }

game_progress_state<public> := class(game_state):

    @editable NRSmokeZoneDevice :? smoke_zone_device = false
    @editable EliminationManager : elimination_manager_device = elimination_manager_device{}
    @editable LoseHud : hud_message_device = hud_message_device{}
    @editable LoseAudioPlayer : audio_player_device = audio_player_device{}
    @editable SmokeDamageHandler :? damage_handler_device = false
    @editable RunAlertHud :? hud_message_device = false
    @editable EndRoundTimer :? timer_device = false

    @editable HunterTeam :? team_settings_and_inventory_device = false
    @editable RunnerTeam :? team_settings_and_inventory_device = false

    EnterState<override>():void=
        (super:)EnterState()
        Print("STATE: GameProgressState")
        AddStateSub(EliminationManager.EliminatedEvent.Subscribe(OnPlayerEliminated))

        if(RDevice := NRSmokeZoneDevice?,
        Players1 := RunnerTeam?.GetTeamMembers(),
        Players2 := HunterTeam?.GetTeamMembers()):
      
            var PlayerHUDShow : []player = array{}
            if(RHud := RunAlertHud?):
                for(Player : Players1):
                    RHud.Show(Player)
                    if(RPlayer := player[Player]):
                        set PlayerHUDShow += array{RPlayer}
                for(Player : Players2):
                    if(RPlayer := player[Player]):
                        set PlayerHUDShow += array{RPlayer}
            Print("PLAYERS: {PlayerHUDShow.Length}")
            RDevice.ShowHUD(PlayerHUDShow)
            if(RDmgHandler := SmokeDamageHandler?):
                RDmgHandler.BeginTrackSmokeDamageForPlayers(PlayerHUDShow)
            RDevice.BeginSmokeCycle()
            if(RoundTimer := EndRoundTimer?):
                RoundTimer.Start()
            

    DisposeState<override>(NextState:state):void=
        if(RDevice := NRSmokeZoneDevice?):
            RDevice.RecoverInitiateState()
            RDevice.RemoveHUD()
            if(RoundTimer := EndRoundTimer?):
                RoundTimer.Reset()

        if(RDmgHandler := SmokeDamageHandler?):    
            RDmgHandler.CancelAllSubs()
        (super:)DisposeState(NextState)

    OnPlayerEliminated(Agent:agent):void=
        Print("Eliminated")
        if(RSpawnDevice := SpawnDevice?){
            RSpawnDevice.TeleportToLobby(Agent)

        LoseHud.Show(Agent)
        LoseAudioPlayer.Play(Agent)
        spawn{DisposeLoseHud(5.0, Agent)}
        AssignPlayerToTeam(3, Agent)
        
        if(RTeam := RunnerTeam?,
        HTeam := HunterTeam?,
        RTeam.GetTeamMembers().Length = 0 or HTeam.GetTeamMembers().Length = 0):          
            DisposeState(state.GameFinished)
        }
        
        


    DisposeLoseHud(AfterSeconds : float, Agent : agent)<suspends>:void=
        Sleep(AfterSeconds)
        LoseHud.Hide(Agent)

    OnPlayerJoined<override>(Player : agent):void=
        AssignPlayerToTeam(3, Player)
        if(RSpawnDevice := SpawnDevice?):
            RSpawnDevice.TeleportToLobby(Player)

    OnPlayerLeft<override>(Player : agent):void=
        if(RealPlayspace := Playspace?,
        RealPlayspace.GetParticipants().Length = 1):
            DisposeState(state.GameFinished)