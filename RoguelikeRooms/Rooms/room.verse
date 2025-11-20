using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }

wave := class<concrete>:
    @editable SpawnersData : []spawner_data = array{}
    @editable VolumeToTrigger :? volume_enter_handler = false
    @editable TimeToTrigger :? float = false
    @editable ActivateAfterCompletionPastWave : logic = true
    DeactivationWaveEvent : event() = event(){}

    var TotalWaveGuardsCount : int = 0
    var CurrentWaveGuardsCount : int = 0
    var WaveIndex : int = 0
    var Activated : logic = false

volume_enter_handler := class<concrete>:
    @editable Volume : volume_device = volume_device{}
    var Wave<private> : wave = wave{}
    var Room<private> : room = room{}
    var LastSub : ?cancelable = false

    Init(WaveArg : wave, RoomArg : room):void=
        set Wave = WaveArg
        set Room = RoomArg

    Enable():void=
        if(Sub := LastSub?):
            Sub.Cancel()
        set LastSub = option{Volume.AgentEntersEvent.Subscribe(OnAgentEntered)}
    
    Disable():void=
        if(Sub := LastSub?):
            Sub.Cancel()

    OnAgentEntered(Agent : agent):void=
        Room.HandleVolumeEntered(Wave.WaveIndex, Agent)

spawner_data := class<concrete>:
    @editable NPCSpawner : npc_spawner_device = npc_spawner_device{}
    @editable SpawnCount : int = 0
    @editable SpawnDelay :? float = false
    var Wave<private> : wave = wave{}

    var Room<private> : room = room{}
    var LastSub : ?cancelable = false

    Init(WaveArg : wave, RoomArg : room):void=
        set Wave = WaveArg
        set Room = RoomArg

    Enable():void=
        if(Sub := LastSub?):
            Sub.Cancel()
        set LastSub = option{NPCSpawner.EliminatedEvent.Subscribe(OnNPCEliminated)}
    
    Disable():void=
        if(Sub := LastSub?):
            Sub.Cancel()

    OnNPCEliminated(Result : device_ai_interaction_result):void=
        if(Agent := Result.Target?):
            Print("NPC Eliminated, Wave: {Wave.WaveIndex}")
            Room.HandleNPCEliminated(Wave.WaveIndex, Agent)

room := class<concrete>:

    @editable MaxPlayersInRoom : int = 8
    @editable EntryPoint : teleporter_device = teleporter_device{}
    @editable ExitPoint : volume_device = volume_device{}
    @editable Locker : lock_device = lock_device{}

    var TotalGuardsCount<private> : int = 0
    var CurrentGuardsCount<private> : int = 0
    var RoomProgress : float = 1.0
    var RoomIndex : int = 0

    var CurrentPlayerCount : int = 0
    var AgentToSubs : [agent][]cancelable = map{}

    var CancelOnDeactivation : []cancelable = array{}

    DeactivationEvent : event() = event(){}
    @editable Waves : []wave = array{}

    var RoomSearcher : room_searcher = room_searcher{}

    Init(RoomSearcherArg : room_searcher):void=
        set RoomSearcher = RoomSearcherArg
        for(Index -> Wave : Waves):
            set Wave.WaveIndex = Index
            
            if(VolumeHandler := Wave.VolumeToTrigger?):
                VolumeHandler.Init(Wave, Self)

            for(Data : Wave.SpawnersData):
                Data.Init(Wave, Self)
                set TotalGuardsCount += Data.SpawnCount
                set Wave.TotalWaveGuardsCount += Data.SpawnCount
                
    OnRoomJoined(Player : agent):void=
        if(FortChar := Player.GetFortCharacter[]):
            Sub1 := FortChar.EliminatedEvent().Subscribe(OnPlayerEliminated)
            if(set AgentToSubs[Player] = array{Sub1}):  
                if(CurrentPlayerCount = 0):
                    Print("Activating room")
                    ActivateRoom()

                set CurrentPlayerCount += 1
                Print("Player joined room, players in room: {CurrentPlayerCount}")
                EntryPoint.Teleport(Player)
                
    
    OnPlayerEliminated<private>(Result : elimination_result):void=
        if(Player := Result.EliminatedCharacter.GetAgent[]):
            OnRoomLeft(Player)
            Print("Player eliminated")
        
    OnRoomLeft(Player : agent):void=
        if(Subs := AgentToSubs[Player]):
            for(Sub : Subs):
                Sub.Cancel()
            set CurrentPlayerCount -= 1
        Print("Player left room, players in room: {CurrentPlayerCount}")
        if(CurrentPlayerCount = 0):
            DeactivateRoom()
            Locker.Close(Player)
            Print("0 players")

    ActivateRoom():void=
        for(Index -> Wave : Waves):
            set Wave.CurrentWaveGuardsCount = 0
            set Wave.Activated = false
            if(Index = 0):
                ActivateWave(Wave)

            if(VolumeTrigger := Wave.VolumeToTrigger?):
                VolumeTrigger.Enable()

            if(TimeTrigger := Wave.TimeToTrigger?):
                spawn{HandleTimeTrigger(TimeTrigger, Wave)}

            for(Data : Wave.SpawnersData):
                Data.Enable()
        set CancelOnDeactivation += array{ExitPoint.AgentEntersEvent.Subscribe(OnPlayerEnterExitPoint)}
        set CancelOnDeactivation += array{RoomSearcher.GetPlayspace().PlayerRemovedEvent().Subscribe(OnRoomLeft)}
        set CurrentGuardsCount = TotalGuardsCount 
        set RoomProgress = 1.0

    OnPlayerEnterExitPoint(Agent : agent):void=
        if(Player := player[Agent]):
            RoomSearcher.PushPlayerRoom(Player, option{Self})
            OnRoomLeft(Player)
                
    ActivateWave(Wave : wave):void=
        if(Wave.CurrentWaveGuardsCount > 0 or Wave.Activated = true):
            return

        Wave.DeactivationWaveEvent.Signal()    

        set Wave.CurrentWaveGuardsCount = Wave.TotalWaveGuardsCount
        set Wave.Activated = true

        if(Volume := Wave.VolumeToTrigger?):
            Volume.Disable()

        for(Data : Wave.SpawnersData):
                    if(Delay := Data.SpawnDelay?):
                        spawn{CreateSpawnCycleAsync(Delay, Data)}
                    else:
                        CreateSpawnCycle(Data)
        
    HandleVolumeEntered(WaveIndex : int, Agent : agent):void=
        if(Player := player[Agent],
        Wave := Waves[WaveIndex],
        Volume := Wave.VolumeToTrigger?):
            ActivateWave(Wave)
            
    HandleNPCEliminated(WaveIndex : int, Agent : agent):void=
        if:
            Wave := Waves[WaveIndex]
            set Wave.CurrentWaveGuardsCount -= 1
        then:
            set CurrentGuardsCount -= 1
            Print("Current guards: {CurrentGuardsCount}")
            Print("Current wave guards: {Wave.CurrentWaveGuardsCount}")

            NewRoomProgress : float = (1.0 * CurrentGuardsCount) / (1.0 * TotalGuardsCount)
            set RoomProgress = NewRoomProgress

            Print("Room progress {NewRoomProgress}")

            if(Wave.CurrentWaveGuardsCount = 0):
                if(NextWave := Waves[WaveIndex + 1],
                NextWave.ActivateAfterCompletionPastWave = true):
                    ActivateWave(NextWave)
                    Print("Activating next wave")

            if(CurrentGuardsCount = 0):
                OnRoomCompleted(Agent)

    OnRoomCompleted(Agent : agent):void=
        Print("Room completed")
        Locker.Open(Agent)

    HandleTimeTrigger(Delay : float, Wave : wave)<suspends>:void=
        race:
            block:
                Wave.DeactivationWaveEvent.Await()
            block:
                Sleep(Delay)
                ActivateWave(Wave)

    CreateSpawnCycleAsync<private>(Delay : float, SpawnerData : spawner_data)<suspends>:void=
        race:
            block:
                DeactivationEvent.Await()
            block:
                for(X := 1..SpawnerData.SpawnCount):
                    SpawnerData.NPCSpawner.Spawn()
                    Sleep(Delay)

    CreateSpawnCycle<private>(SpawnerData : spawner_data):void=
            for(X := 0..SpawnerData.SpawnCount):
                SpawnerData.NPCSpawner.Spawn()
                

    DeactivateRoom():void=
        DeactivationEvent.Signal()
        set RoomProgress = 1.0
        for(Sub : CancelOnDeactivation):
            Sub.Cancel()
        for(Index -> Wave : Waves):
            if(Volume := Wave.VolumeToTrigger?):
                Volume.Disable()
            for(Data : Wave.SpawnersData):
                Data.NPCSpawner.DespawnAll(false)
                Data.Disable()
        Print("Room deactivated")