using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

var SavedSessionData : weak_map(session, session_data) = map{}
var SavedPlayerData:weak_map(player, player_data) = map{}

SetPlayerData(Player : agent, Data : player_data):logic=
    if(RPlayer := player[Player],
    set SavedPlayerData[RPlayer] = Data):
        return true
    return false

SetSessionData(Session : session, Data : session_data):logic=
    if(set SavedSessionData[Session] = Data):
        return true
    return false


hunter_queue_device := class(creative_device):

    OnBegin<override>()<suspends>:void=       
        if:
            Players := GetPlayspace().GetPlayers()
            var ProvidedQueueIndexR : int = 0
            not SavedSessionData[GetSession()]
            set SavedSessionData[GetSession()] = session_data{}
        then:
            for(X := 0..Players.Length - 1):
                if(Player := player[Players[X]],
                PlayerData := SavedPlayerData[Player]):
                    NewData := player_data:
                        QueueIndex := ProvidedQueueIndexR
                        MakePlayerData<constructor>(PlayerData)
                        
                    Print("Player initialized, his queue index: {ProvidedQueueIndexR}")
                    set ProvidedQueueIndexR += 1
                    if(set SavedPlayerData[Player] = NewData){}
            NewSessionData := session_data{ProvidedQueueIndex := ProvidedQueueIndexR}
            if(set SavedSessionData[GetSession()] = NewSessionData):

        

        GetPlayspace().ParticipantAddedEvent().Subscribe(OnPlayerAdded)
        GetPlayspace().ParticipantRemovedEvent().Subscribe(OnPlayerRemoved)

    GetHunter(): ?player =
        Players := GetPlayersInQueue()
        if(Player := Players[0]):
            return option{Player}
        return false

    OnPlayerAdded(Agent : agent):void=
        if:
            Player := player[Agent]
            SessionData := SavedSessionData[GetSession()]
            PlayerData := SavedPlayerData[Player]
        then:
            NewPlayerData := player_data:
                QueueIndex := SessionData.ProvidedQueueIndex
                MakePlayerData<constructor>(PlayerData)
                
            NewSessionData := session_data:
                ProvidedQueueIndex := SessionData.ProvidedQueueIndex + 1
                MakeSessionData<constructor>(SessionData)
                
            Print("Player joined, his queue index: {NewSessionData.ProvidedQueueIndex}")
            if:
                set SavedPlayerData[Player] = NewPlayerData
                set SavedSessionData[GetSession()] = NewSessionData


    OnPlayerRemoved(Agent : agent):void=     
        Players := GetPlayersInQueue()
        if:
            Player := player[Agent]
            SessionData := SavedSessionData[GetSession()]
            PlayerData := SavedPlayerData[Player]
      
            var ProvidedQueueIndexR : int = 0
        then:
            NewPlayerData := player_data:
                QueueIndex := -1
                MakePlayerData<constructor>(PlayerData)
                
            for(X := 0..Players.Length - 1):
                if:
                    RPlayer := player[Players[X]]
                    PlayerDataR := SavedPlayerData[RPlayer]
                then:
                    NewPlayerDataR := player_data:
                        QueueIndex := X
                        MakePlayerData<constructor>(PlayerDataR)
                        
                    if (set SavedPlayerData[RPlayer] = NewPlayerDataR):
                            set ProvidedQueueIndexR += 1
            Print("Player removed, queue recounted")
            NewSessionData := session_data:
                ProvidedQueueIndex := ProvidedQueueIndexR
                MakeSessionData<constructor>(SessionData)
                
            if:
                set SavedPlayerData[Player] = NewPlayerData
                set SavedSessionData[GetSession()] = NewSessionData

    GetPlayersInQueue() : []player =
        # Filter players with QueueIndex > -1
        var FilteredPlayers : []player = array{}
        for (Player : GetPlayspace().GetPlayers()):
            if (Data := SavedPlayerData[Player], Data.QueueIndex > -1):
                set FilteredPlayers += array{Player}
    
        # Sort players by QueueIndex (ascending)
        var SortedPlayers : []player = array{}
        var RemainingPlayers : []player = FilteredPlayers
    
        # Manual selection sort
        loop:
            if (RemainingPlayers.Length = 0):
                break
    
            var MinIndex : int = 0
            var MinValue : int = 999999 # Use a large number instead of MaxInt
    
            # Find player with smallest QueueIndex
            for (Index -> Player : RemainingPlayers):
                if (Data := SavedPlayerData[Player], Data.QueueIndex < MinValue):
                    set MinIndex = Index
                    set MinValue = Data.QueueIndex
    
            # Add to sorted array and remove from remaining
            if (MinPlayer := RemainingPlayers[MinIndex]):
                set SortedPlayers += array{MinPlayer}
                if (NewRemaining := RemainingPlayers.RemoveElement[MinIndex]):
                    set RemainingPlayers = NewRemaining
    
        return SortedPlayers
