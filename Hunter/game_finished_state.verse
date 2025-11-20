using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }

game_finished_state<public> := class(game_state):

    @editable HudWin : hud_message_device = hud_message_device{}
    @editable HudLose : hud_message_device = hud_message_device{}
    @editable CinematicSequencers : []cinematic_sequence_device = array{}
    @editable Buttons : []button_device = array{}
    @editable Health : health_powerup_device = health_powerup_device{}
    @editable WinAudioPlayer : audio_player_device = audio_player_device{}
    @editable Save : trigger_device = trigger_device{}

    @editable VFXSpawners : []vfx_spawner_device = array{}
    @editable Turrets : []automated_turret_device = array{}
    @editable DmgVolumes : []damage_volume_device = array{}
    @editable ItemRemover :? item_remover_device = false

    @editable HunterTeam :? team_settings_and_inventory_device = false
    @editable RunnerTeam :? team_settings_and_inventory_device = false

    @editable Stats :? stats_device = false

    @editable EndRound : end_game_device = end_game_device{}

    EnterState<override>():void=
        (super:)EnterState()
        Print("STATE: GameFinishedState")
        if(RPlayspace := Playspace?,
        RHunter := HunterTeam?,
        RRunner := RunnerTeam?,
        RunnerTeamPlayerCount := RRunner.GetTeamMembers().Length,
        HunterTeamPlayerCount := RHunter.GetTeamMembers().Length,
        ItemRemoverReal := ItemRemover?,
        RStats := Stats?):
            Print("{RunnerTeamPlayerCount}")
            Print("{HunterTeamPlayerCount}")
            for(Player : RPlayspace.GetPlayers()):
                ItemRemoverReal.Remove(Player)
            if(RunnerTeamPlayerCount = 0):
                
                if(Hunter := player[RHunter.GetTeamMembers()[0]],
                Team := RPlayspace.GetTeamCollection().GetTeam[Hunter]):
                    RStats.HunterWin(Hunter)
                    AnnounceTeamPlaces(Team)
                    Print("Hunter win")
            else if(HunterTeamPlayerCount = 0):
                
                    for(Index -> Runner : RRunner.GetTeamMembers()):
                        if(RPRunner := player[Runner]):
                            RStats.RunnerWin(RPRunner)
                            Print("Runner win")
                            if(Index = 0,
                            Team := RPlayspace.GetTeamCollection().GetTeam[RPRunner]):
                                AnnounceTeamPlaces(Team)

        
        
        for(Button : Buttons):
            Button.Enable()
        Save.Trigger()
        StartTimer(DefaultDelay)
    
    DisposeState<override>(NextState:state):void=
        if(RPlayspace := Playspace?,
        RHunter := HunterTeam?,
        RRunner := RunnerTeam?,
        RunnerTeamPlayerCount := RRunner.GetTeamMembers().Length,
        HunterTeamPlayerCount := RHunter.GetTeamMembers().Length):
            Print("{RunnerTeamPlayerCount}")
            Print("{HunterTeamPlayerCount}")
            if(RunnerTeamPlayerCount = 0,
            Player := RHunter.GetTeamMembers()[0]):
                EndRound.Activate(Player)
            else if(HunterTeamPlayerCount = 0,
            Player := RRunner.GetTeamMembers()[0]):
                EndRound.Activate(Player)
            else:
                if(RP := Playspace?,
                Player := RP.GetPlayers()[0]):
                    EndRound.Activate(Player)
        
        <#TerminateHud()
        if(RSpawnDevice := SpawnDevice?,
        RPlayspace := Playspace?,
        TeamCollection := RPlayspace.GetTeamCollection(),
        RunnerTeam := TeamCollection.GetTeams()[0],
        HunterTeam := TeamCollection.GetTeams()[1],
        RunnerTeamPlayers := TeamCollection.GetAgents[RunnerTeam],
        HunterTeamPlayers := TeamCollection.GetAgents[HunterTeam]):
            for(Player : RunnerTeamPlayers):
                RSpawnDevice.TeleportToLobby(Player, ?Heal := true)
            for(Player : HunterTeamPlayers):
                RSpawnDevice.TeleportToLobby(Player, ?Heal := true)
            
        WinAudioPlayer.UnregisterAll()

        for(Sequencer : CinematicSequencers):
            Sequencer.SetPlayRate(10.0)
            Sequencer.PlayReverse()   
            
        spawn{DisableAllAnimDevices()}
        
        if(RPlayspace := Playspace?):
            if(RPlayspace.GetParticipants().Length > 1):
                (super:)DisposeState(state.PreGameDelay)
            else if(RPlayspace.GetParticipants().Length = 1):
                (super:)DisposeState(state.WaitingPlayers)#>

    DisableAllAnimDevices()<suspends>:void=
        if(StateManager := GameStateManager?):
            RawGameState := StateManager.GetState(state.PreGameDelay)
            if(PreGameState := RawGameState?):
                Sleep(PreGameState.DefaultDelay)
                for(VFXSpawner : VFXSpawners):
                    VFXSpawner.Disable()
                for(Turret : Turrets):
                    Turret.Disable()
                for(DmgVolume : DmgVolumes):
                    DmgVolume.Disable()
                for(Sequencer : CinematicSequencers):
                    Sequencer.SetPlayRate(1.0)

    OnTimerSucceded<override>(Agent:?agent):void=
        if(RPlayspace := Playspace?):
            if(RPlayspace.GetParticipants().Length > 1):
                DisposeState(state.PreGameDelay)
            else if(RPlayspace.GetParticipants().Length = 1):
                DisposeState(state.WaitingPlayers)
    
    AnnounceTeamPlaces(WinTeam : team):void=
        if(RPlayspace := Playspace?,
        WinTeamPlayers := RPlayspace.GetTeamCollection().GetAgents[WinTeam]):  
            for(WinPlayer : WinTeamPlayers):
                WinAudioPlayer.Register(WinPlayer)
                WinAudioPlayer.Play()
                HudWin.Show(WinPlayer)

    TerminateHud():void=
        if(RPlayspace := Playspace?):
            for(Player : RPlayspace.GetPlayers()):
                HudWin.Hide(Player)
                HudLose.Hide(Player)
    
    OnPlayerJoined<override>(Player : agent):void=
        AssignPlayerToTeam(3, Player)
        if(RSpawnDevice := SpawnDevice?):
            RSpawnDevice.TeleportToLobby(Player)