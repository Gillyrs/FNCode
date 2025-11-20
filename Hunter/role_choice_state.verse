using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Characters }
role_choice_state<public> := class(game_state):

    @editable PopUpRunner : popup_dialog_device = popup_dialog_device{}
    @editable PopUpHunter : popup_dialog_device = popup_dialog_device{}
    @editable MutatorZoneRunners :? mutator_zone_device = false
    @editable MutatorZoneHunter :? mutator_zone_device = false
    @editable HunterQueue :? hunter_queue_device = false
    @editable MutatorZoneTips : []mutator_zone_device = array{}
    @editable HunterClass :? class_and_team_selector_device = false

    @editable IsRandom : logic = false
    EnterState<override>():void=
        (super:)EnterState()
        Print("STATE: RoleChoiceState")      
        spawn{BeginPutInStasis()}
        spawn{BeginTrackPlayersPosition()}
        StartTimer(DefaultDelay)   


    BeginTrackPlayersPosition()<suspends>:void=
        var TickTime : float = 0.5
        var StopBefore : float = 1.0
        if(RZoneRunner := MutatorZoneRunners?,
        RZoneHunter := MutatorZoneHunter?,
        RPlayspace := Playspace?,
        TeamCollection := RPlayspace.GetTeamCollection()
        Team := TeamCollection.GetTeams()[0],
        Players := TeamCollection.GetAgents[Team],
        TicksQuantity := Round[(DefaultDelay - StopBefore) / TickTime]):
            for(X := 0..TicksQuantity):
                Sleep(TickTime)
                for(Player : Players):
                    if(not RZoneRunner.IsInVolume[Player],
                    not RZoneHunter.IsInVolume[Player]):
                        if(RealSpawnDevice := SpawnDevice?):
                            RealSpawnDevice.TeleportToRunners(Player, ?Heal := true)
                            Print("Teleported to runners")
                            
    BeginPutInStasis()<suspends>:void=
        Delay := 0.2
        if(Count := Round[DefaultDelay / Delay]):
            for(X := 0..Count):
                Sleep(Delay)
                PutInStasisTeam(1)
    
    DisposeState<override>(NextState:state):void=
        if(NextState <> state.AfterRoleChoiceDelay):
            ReleaseFromStasisTeam(1)
            ReleaseFromStasisTeam(2)

        (super:)DisposeState(NextState)


    OnTimerSucceded<override>(Agent:?agent):void=
        var CurrentState :?state = false
        if(Manager := GameStateManager?):
            Nor := Manager.GetCurrentState()
            set CurrentState =  option{Nor}

        if(RSpawnDevice := SpawnDevice?,
        RQueue := HunterQueue?,
        RState := CurrentState?,
        State = RState):
           var Player :? agent = false
            if(IsRandom = true):
                set Player = CompleteRoleChoiceProcesss()
                
                if(RPlayer := player[Player?],
                PlayerData := SavedPlayerData[RPlayer]):
                        if(RClass := HunterClass?):
                            RClass.ChangeClass(RPlayer)
                            Print("Hunter class changed")
                        if(PlayerData.FirstTimeHunter = true):
                            SetPlayerData(RPlayer, player_data{
                                FirstTimeHunter := false
                                MakePlayerData<constructor>(PlayerData)
                                })
                            for(Zone : MutatorZoneTips):
                                Zone.Enable()
                            
            else:
                set Player = RQueue.GetHunter()
                if(RPlayer := Player?):     
                    PopUpRunner.Show()
                    PopUpRunner.Hide(RPlayer)   
                    PopUpHunter.Show(RPlayer)
                    if(PlayerData := SavedPlayerData[RPlayer]):
                        if(RClass := HunterClass?):
                            RClass.ChangeClass(RPlayer)
                            Print("Hunter class changed")
                        if(PlayerData.FirstTimeHunter = true):
                            SetPlayerData(RPlayer, player_data{
                                FirstTimeHunter := false
                                MakePlayerData<constructor>(PlayerData)
                                })
                            for(Zone : MutatorZoneTips):
                                Zone.Enable()
                    
           if(RPlayer := Player?):        
            AssignPlayerToTeam(2, RPlayer) 
            if(FortChar := RPlayer.GetFortCharacter[]):
                FortChar.ReleaseFromStasis()
            RSpawnDevice.TeleportToHunter(RPlayer)
            DisposeState(state.AfterRoleChoiceDelay)
    
    CompleteRoleChoiceProcesss() :? agent =
        if(RPlayspace := Playspace?):
            Players := RPlayspace.GetParticipants()
            PlayerIndex := GetRandomInt(0, Players.Length - 1)
            if(Player := Players[PlayerIndex], PopUpRunner, PopUpHunter):
                PopUpRunner.Show()
                PopUpRunner.Hide(Player)   
                PopUpHunter.Show(Player)
                return option{Player}

        return false

    OnPlayerJoined<override>(Player : agent):void=
        AssignPlayerToTeam(1, Player)
        if(RSpawnDevice := SpawnDevice?):
            RSpawnDevice.TeleportToRunners(Player)

    OnPlayerLeft<override>(Player : agent):void=
        if(RealPlayspace := Playspace?,
        RealPlayspace.GetParticipants().Length = 1):
            DisposeState(state.WaitingPlayers)
