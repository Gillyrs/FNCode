using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Random }

game_level := class<concrete>:
    @editable GameRooms : []room = array{}

advanced_game_level := class(game_level):
    @editable Really : int = 10

room_searcher := class(creative_device):

    @editable GameLevels : []game_level = array{}
    @editable EntryPoint : volume_device = volume_device{}
    @editable EliminationManager : elimination_manager_device = elimination_manager_device{}
    @editable_slider(float):
        MinValue := option{0.0}
        MaxValue := option{1.0}
        SliderExponent := option{1.0}
        SliderDelta := option{0.1}
    ProbabilityRange : float = 1.0

    var AgentToExcludeList : [agent]?[]room = map{}

    OnBegin<override>()<suspends>:void=
        EntryPoint.AgentEntersEvent.Subscribe(OnAgentEntered)
        EliminationManager.EliminatedEvent.Subscribe(OnPlayerEliminated)
        for(Level : GameLevels):
            for(X -> Room : Level.GameRooms):
                Room.Init(Self)
                set Room.RoomIndex = X
                Print("Room initialized with index {X}")

    OnAgentEntered(Agent : agent):void=
        PushPlayerRoom(Agent, false)
        
    PushPlayerRoom(Agent : agent, LastRoom :? room):void=
        if(Player := player[Agent]):
            var OptionalExcludeList :?[]room = false

            if(List := AgentToExcludeList[Agent]?):
                if(ExcludeRoom := LastRoom?):
                    NewArray :[]room = List + array{ExcludeRoom}
                    set OptionalExcludeList = option{NewArray}
                    if(set AgentToExcludeList[Agent] = option{NewArray}):
                        Print("There is exclude layer: {NewArray.Length} rooms, added current room in it")  
                else:
                    set OptionalExcludeList = option{List}
                     Print("Added current room in exclude list")
            else if(ExcludeRoom := LastRoom?,
            set AgentToExcludeList[Agent] = option{array{ExcludeRoom}}):
                set OptionalExcludeList = option{array{ExcludeRoom}}
                Print("First room")
 
            Room := FindRoom(OptionalExcludeList)
            Room.OnRoomJoined(Player)
                   
            
                

    OnPlayerEliminated(Agent : agent):void=
        Print("ELIMINATED")
        if(Player := player[Agent],
        set AgentToExcludeList[Agent] = false):
            Print("Recreated exclude list for player")
            

    FindRoom(ExcludeList :?[] room):room=
        DefaultRoom : room = room{}
        if:
            Level := GameLevels[0]
            var SortedArray : []room = array{}
            MergedRooms := MergeSortRooms[Level.GameRooms]
            set SortedArray = MergedRooms.Reverse()

        then:
            if(RExcludeList := ExcludeList?):
                set SortedArray = RemoveExcludedRooms(SortedArray, RExcludeList)
                        
            if(BestOption := SortedArray[0]):

                var RandomArray : []room = array{BestOption}
                
                for(X := 1..SortedArray.Length - 1):
                    if(Room := SortedArray[X]):
                        Print("Iterated sorted array, BestOption {BestOption.RoomProgress} - {Room.RoomProgress}")
                    if(Room := SortedArray[X],
                    BestOption.RoomProgress - Room.RoomProgress <= ProbabilityRange):
                        set RandomArray += array{Room}

                if(RandomArray.Length = 1):
                    Print("Found only one room")
                    return BestOption
                else if(RandomArray.Length > 1,
                ChosenRoom := RandomArray[GetRandomInt(0, RandomArray.Length - 1)]):
                    Print("Found few rooms: {RandomArray.Length}")
                    return ChosenRoom

        return DefaultRoom  
    
    RemoveExcludedRooms(SortedArray : []room, ExcludeList : []room) : []room =
        var ResultArray : []room = array{}
        
        for (Element : SortedArray):
            var ShouldKeep : logic = true

            for (ExcludeElement : ExcludeList):
                if (Element.RoomIndex = ExcludeElement.RoomIndex):
                    set ShouldKeep = false
            

            if (ShouldKeep = true):
                set ResultArray = ResultArray + array{Element}
    
        return ResultArray

    Merge(Left : []room, Right : []room)<transacts><decides>:[]room =
        var Result : []room = array{}
        var LeftIndex : int = 0
        var RightIndex : int = 0
    
        loop:
            if (LeftIndex >= Left.Length and RightIndex >= Right.Length):
                break
    
            if (LeftIndex < Left.Length and RightIndex < Right.Length):
                if (LeftRoom := Left[LeftIndex], RightRoom := Right[RightIndex]):
                    if (LeftRoom.RoomProgress <= RightRoom.RoomProgress):
                        set Result += array{LeftRoom}
                        set LeftIndex += 1
                    else:
                        set Result += array{RightRoom}
                        set RightIndex += 1
            else if (LeftIndex < Left.Length):
                if (LeftRoom := Left[LeftIndex]):
                    set Result += array{LeftRoom}
                    set LeftIndex += 1
            else if (RightIndex < Right.Length):
                if (RightRoom := Right[RightIndex]):
                    set Result += array{RightRoom}
                    set RightIndex += 1
    
        Result
 
    MergeSortRooms(RawRooms : []room)<transacts><decides>:[]room =
        if (RawRooms.Length <= 1):
            RawRooms
        else:
            if (MidIndex := Floor[RawRooms.Length * 1.0 / 2.0]):
                if (Left := RawRooms.Slice[0, MidIndex], Right := RawRooms.Slice[MidIndex, RawRooms.Length]):
                    if (SortedLeft := MergeSortRooms[Left], SortedRight := MergeSortRooms[Right]):
                        return Merge[SortedLeft, SortedRight]
                    else:
                        return RawRooms
                else:
                    return RawRooms
            else:
                return RawRooms

    (Input:[]t where t:type).Reverse()<computes>:[]t=
        for (Index -> Unused : Input, Element := Input[Input.Length - Index - 1]). Element

            