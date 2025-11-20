using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }

after_role_choice_state<public> := class(game_state):

    @editable EliminationManager : elimination_manager_device = elimination_manager_device{}

    @editable HunterTeam :? team_settings_and_inventory_device = false
    @editable RunnerTeam :? team_settings_and_inventory_device = false

    
    EnterState<override>():void=
        (super:)EnterState()
        Print("STATE: AfterRoleChoiceState")
        AddStateSub(EliminationManager.EliminatedEvent.Subscribe(OnPlayerEliminated))
        StartTimer(DefaultDelay)
    
    OnTimerSucceded<override>(Agent:?agent):void=
        DisposeState(state.GameInProgress)

    DisposeState<override>(NextState:state):void=
        ReleaseFromStasisTeam(1)
        ReleaseFromStasisTeam(2)
            
        (super:)DisposeState(NextState)
    
    OnPlayerEliminated(Agent:agent):void=
        Print("Eliminated")
        if(RSpawnDevice := SpawnDevice?){
            RSpawnDevice.TeleportToLobby(Agent)
            
        AssignPlayerToTeam(3, Agent)

        if(RTeam := RunnerTeam?,
        HTeam := HunterTeam?,
        RTeam.GetTeamMembers().Length = 0 or HTeam.GetTeamMembers().Length = 0):          
            DisposeState(state.GameFinished)
        }

    OnPlayerJoined<override>(Player : agent):void=
        AssignPlayerToTeam(3, Player)
        if(RSpawnDevice := SpawnDevice?):
            RSpawnDevice.TeleportToLobby(Player)

    OnPlayerLeft<override>(Player : agent):void=
        if(RealPlayspace := Playspace?,
        RealPlayspace.GetParticipants().Length = 1):
            DisposeState(state.GameFinished)