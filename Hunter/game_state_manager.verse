using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }

game_state_manager:= class(creative_device):


    @editable StateHudArray : []state_hud = array{}

    @editable var GameStates : []game_state = array{waiting_player_state{}, role_choice_state{},
    after_role_choice_state{}, game_progress_state{}, game_finished_state{}, pre_game_delay{}}

    @editable DefaultTimerDevice : timer_device = timer_device{}
    @editable SpawnDevice : spawn_device = spawn_device{}
    @editable EliminationManager : elimination_manager_device = elimination_manager_device{}
    @editable SpectatorDevice : spectator_device = spectator_device{}
    @editable Load : trigger_device = trigger_device{}
    @editable AvailableLevel : hud_message_device = hud_message_device{}
    @editable LevelBuilder : Levels.level_builder = Levels.level_builder{}
    @editable TeamSelectors : []class_and_team_selector_device = array{}

    var CurrentGameState : state = state.WaitingPlayers

    OnBegin<override>()<suspends>:void=
        InitStates()
        TimeUpdater := time_update{}
        spawn{TimeUpdater.Init(GameStates)}

        PlayerCount := GetPlayspace().GetParticipants().Length
        SpawnDevice.TeleportAllLobby()
        Print("Teleporting all loby")
        AssignAllPlayersToTeam(3)
        Load.Trigger()

        for(Player : GetPlayspace().GetPlayers()):
            if(PlayerData := SavedPlayerData[Player],
            Complexity := LevelBuilder.Complexities[PlayerData.Complexity],
            PlayerData.Coins >= Complexity.CoinToReach):
                AvailableLevel.Show(Player)

        if(PlayerCount = 1):
            EnterState(state.WaitingPlayers)
        else if(PlayerCount > 1):
            EnterState(state.PreGameDelay)
    
    InitStates():void=
        for(State : GameStates):
            var HudArg :? hud_message_device = false
            var TimerArg : timer_device = DefaultTimerDevice
            for(Obj : StateHudArray):
                if(Obj.State = State.State):
                    if(RTimer := Obj.Timer?):
                        set TimerArg = RTimer
                    if(RHudArg := Obj.Hud?):
                        set HudArg = option{RHudArg}
            
            Playspace := GetPlayspace()
            State.Setup(TeamSelectors, TimerArg, Playspace, Self, 
            SpawnDevice, HudArg, SpectatorDevice)

    EnterState(State:state):void=
        for(GameState : GameStates):
            if(GameState.State = State):
               GameState.EnterState()
               set CurrentGameState = GameState.State
    GetState(State:state):?game_state=
        for(GameState : GameStates):
            if(GameState.State = State):
               return option{GameState}
        return false
    GetCurrentState<public>():state=
        return CurrentGameState
        
    AssignAllPlayersToTeam(TeamIndex : int):void=
        RealPlayspace := GetPlayspace()
        TeamCollection := RealPlayspace.GetTeamCollection()
        if(Team := TeamCollection.GetTeams()[TeamIndex - 1]):
            for(Player : RealPlayspace.GetParticipants()):
                if(TeamCollection.AddToTeam[Player, Team]){}
