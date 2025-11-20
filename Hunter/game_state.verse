using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Characters }

game_state<public> := class<concrete>:

    var Timer : timer_device = timer_device{}
    var GameStateManager :? game_state_manager = false
    var SpawnDevice :? spawn_device = false
    var Playspace :? fort_playspace = false
    var HudMessageDevice<private> :? hud_message_device = false
    var SpectatorDevice :?spectator_device = false

    var TeamSelectors :? []class_and_team_selector_device = false
    var IsTicking : logic = false

    DeviceActivationDelay : float = 1.0

    Setup(TeamSelectorsArg : []class_and_team_selector_device,
    TimerArg:timer_device, PlayspaceArg:fort_playspace, GameStateManagerArg:game_state_manager, SpawnDeviceArg:spawn_device,
    HudMessageDeviceArg :? hud_message_device, SpectatorDeviceArg : spectator_device):void=
        set Timer = TimerArg
        set Playspace = option{PlayspaceArg}
        set GameStateManager = option{GameStateManagerArg}
        set SpawnDevice = option{SpawnDeviceArg}
        set HudMessageDevice = HudMessageDeviceArg
        set SpectatorDevice = option{SpectatorDeviceArg}
        set TeamSelectors = option{TeamSelectorsArg}

    @editable DefaultDelay : float = 0.0
    @editable State<public> : state = state.WaitingPlayers

    
    var StateSubs<private> : []cancelable = array{}

    EnterState<public>():void=
        if(RealPlayspace := Playspace?):
            AddStateSub(RealPlayspace.ParticipantAddedEvent().Subscribe(OnPlayerJoined))
            AddStateSub(RealPlayspace.ParticipantRemovedEvent().Subscribe(OnPlayerLeft))
            AddStateSub(Timer.SuccessEvent.Subscribe(OnTimerSucceded))
            if(RHud := HudMessageDevice?):
                RHud.Show()

    SetDynamicText<localizes>(value:string) : message="{value}"

    OnSecondPast():void=
        if(IsTicking = true):
            UpdateHUD()
        return

    UpdateHUD():void=
        if(RHud := HudMessageDevice?):
            Duration := Timer.GetActiveDuration()
            var DurationRounded : int = 0
            if(Ceiled := Ceil[Duration]){
                set DurationRounded = Ceiled}

            RHud.SetText(SetDynamicText("{DurationRounded}"))
            
    UpdateHUDSpecific(Message : float):void=
        if(RHud := HudMessageDevice?):
            Duration := Message
            var DurationRounded : int = 0
            if(Ceiled := Ceil[Duration]){
                set DurationRounded = Ceiled}

            RHud.SetText(SetDynamicText("{DurationRounded}"))

    DisposeState(NextState:state):void=
        ClearAllStateSubs()
        if(StateManager := GameStateManager?):
            set IsTicking = false
            StateManager.EnterState(NextState)
            if(RHud := HudMessageDevice?):
                RHud.Hide()
                
    OnPlayerJoined(Player:agent):void=
        Print("Player joined")
        if(RHud := HudMessageDevice?):
            RHud.Show(Player)

    OnPlayerLeft(Player:agent):void=
        Print("Player left")
        return

    StartTimer(Duration : float):void=     
        UpdateHUDSpecific(Duration)
        spawn{StartTimerAwait(Duration)}

    StartTimerAwait(Duration : float)<suspends>:void=
        Timer.Reset()
        Sleep(DeviceActivationDelay)
        set IsTicking = true
        Timer.SetMaxDuration(Duration - DeviceActivationDelay)
        Timer.SetActiveDuration(Duration - DeviceActivationDelay)
        Timer.Start()

        
    OnTimerSucceded(Agent :? agent):void=
        set IsTicking = false
        return

    ClearAllStateSubs<private>():void=
        var Index : int = 0
        for(Sub : StateSubs):
            Sub.Cancel()

        set StateSubs = array{}
                

    GetPlayerTeamIndex(Agent : agent):?int=
        if(RPlayspace := Playspace?):
            TeamCollection := RPlayspace.GetTeamCollection()

            if (AgentsTeam := TeamCollection.GetTeam[Agent]):

                TeamArray := TeamCollection.GetTeams()

                for (TeamNumber->Team : TeamArray):
                    
                    if (AgentsTeam = Team):
                        return option{TeamNumber}

        return false

    AddStateSub(Sub : cancelable):void=
        set StateSubs = StateSubs + array{Sub}

    AssignPlayerToTeam(TeamIndex : int, Player : agent):void=
        if(RealPlayspace := Playspace?,
        Selectors := TeamSelectors?):
            if(Team := Selectors[TeamIndex - 1]):
                Team.ChangeTeam(Player)

    AssignAllPlayersToTeam(TeamIndex : int):void=
        if(Selectors := TeamSelectors?):
            if(Team := Selectors[TeamIndex - 1],
            RPlayspace := Playspace?):
                for(Player : RPlayspace.GetParticipants()):
                    Team.ChangeTeam(Player)

    PutInStasisTeam(TeamIndex:int):void=
        if(RealPlayspace := Playspace?,
        TeamCollection := RealPlayspace.GetTeamCollection(),
        Team := TeamCollection.GetTeams()[TeamIndex - 1]
        StasisPlayers := TeamCollection.GetAgents[Team]):
            Args := stasis_args{ AllowEmotes := false, AllowFalling :=  false, AllowTurning := true}
            for(StasisPlayer : StasisPlayers):
                if(FortChar := StasisPlayer.GetFortCharacter[],
                FortChar.PutInStasis(Args)){}

    ReleaseFromStasisTeam(TeamIndex:int):void=
        if(RealPlayspace := Playspace?,
        TeamCollection := RealPlayspace.GetTeamCollection(),
        Team := TeamCollection.GetTeams()[TeamIndex - 1]
        StasisPlayers := TeamCollection.GetAgents[Team]):
            for(StasisPlayer : StasisPlayers):
                if(FortChar := StasisPlayer.GetFortCharacter[],
                FortChar.ReleaseFromStasis()){}
                


    

