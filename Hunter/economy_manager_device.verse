using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }

economy_manager_device<public>  := class(creative_device):

    @editable CollectibleZones : []collectible_zone = array{}
    @editable PlayerHUD : hud_message_device = hud_message_device{}
    @editable PlayerHUDLevel : hud_message_device = hud_message_device{}
    @editable SignalResetStats : channel_device = channel_device{}
    @editable LevelBuilder : level_builder = level_builder{}
    @editable DamageHandler : damage_handler_device = damage_handler_device{}
    @editable NewLevelAvailable : hud_message_device = hud_message_device{}
    @editable DefaultClass : class_and_team_selector_device = class_and_team_selector_device{}
    @editable SavePlayer : trigger_device = trigger_device{}
    @editable LoadPlayer : trigger_device = trigger_device{}
    @editable Accolode : accolades_device = accolades_device{}
    @editable SpawnDevice : spawn_device = spawn_device{}

    SetDynamicText<localizes>(value:string) : message="{value}"

    OnBegin<override>()<suspends>:void=
        Players := GetPlayspace().GetPlayers()

        GetPlayspace().ParticipantAddedEvent().Subscribe(OnPlayerAdded)
        for(SpawnPad : SpawnDevice.Team3SpawnPads):
            SpawnPad.SpawnedEvent.Subscribe(OnPlayerSpawned)
        InitialPlayerData := player_data{}
        for (Player : Players):
            if(not SavedPlayerData[Player]):
                if(set SavedPlayerData[Player] = InitialPlayerData):
                
            LevelBuilder.HandleClassLoad(Player)
        
        SignalResetStats.ReceivedTransmitEvent.Subscribe(OnResetPlayerStats)
        DefineActiveCoins()
        InitPlayersHUD()
        Print("Init player hud")
    
    OnPlayerSpawned(Player : agent):void=
        if(RPlayer := player[Player],
        PlayerData := SavedPlayerData[RPlayer],
        Complexity := LevelBuilder.Complexities[PlayerData.Complexity],
        PlayerData.Coins >= Complexity.CoinToReach):
            NewLevelAvailable.Show(RPlayer)



    OnResetPlayerStats(Agent :? agent):void=
        if(Player := player[Agent?],
        set SavedPlayerData[Player] = player_data{}):
            DefaultClass.ChangeClass(Player)
            Print("Class changed to default")
            OnLevelUpdate(Agent)
            OnMoneyUpdate(Agent)
                
    InitPlayersHUD()<suspends>:void=
        DamageHandler.InitPlayersHud(LevelBuilder)

    OnLevelUpdate(Agent :? agent):void=
        if(Player := player[Agent?],
        PlayerData := SavedPlayerData[Player]):
            DamageHandler.UpdateLevel(Player, PlayerData.Complexity)
    OnMoneyUpdate(Agent :? agent):void=
        if(Player := player[Agent?],
        PlayerData := SavedPlayerData[Player],
        CoinsToReach := LevelBuilder.Complexities[PlayerData.Complexity].CoinToReach):
            DamageHandler.UpdateMoneyCounter(Player, SetDynamicText("{PlayerData.Coins}/{CoinsToReach}"))

    DefineActiveCoins():void=
        var ActiveElements : []collectible_object_device = array{}      
        for(Zone : CollectibleZones):
            var AllElements : []collectible_object_device = Zone.CollectibleObjects
            for(Element : AllElements):
                Element.Hide()

            for(X := 0..Zone.ActiveObjects - 1):
                if:
                    Index := GetRandomInt(0, AllElements.Length - 1)
                    Obj := AllElements[Index]
                    NewArray := AllElements.RemoveElement[Index]
                then:
                    set AllElements = NewArray
                    set ActiveElements += array{Obj}

        for(ActiveElement : ActiveElements):
            ActiveElement.CollectedEvent.Subscribe(OnItemCollected)
            ActiveElement.Show()

    OnItemCollected(Agent : agent):void=

        if(Player := player[Agent]):
            if:
                CheckSaveDataForPlayer[Agent]
                SourceData := SavedPlayerData[Player]   
            then:
                ResultData := player_data:
                    Coins := SourceData.Coins + 1
                    MakePlayerData<constructor>(SourceData)
                    
                Print("Transmitted")
                if:
                    set SavedPlayerData[Player] = ResultData
                    CoinToReach := LevelBuilder.Complexities[ResultData.Complexity].CoinToReach
                then:
                    OnMoneyUpdate(option{Agent})
                    Accolode.Award(Player)
                    if(CoinToReach = ResultData.Coins):
                        NewLevelAvailable.Show(Player)
            else:
                if:
                    SourceData := SavedPlayerData[Player] 
                then:
                    ResultData := player_data:
                        Coins := 1 
                        MakePlayerData<constructor>(SourceData)
                        
                    Print("Transmitted")
                    if:
                        set SavedPlayerData[Player] = ResultData
                    then:
                        OnMoneyUpdate(option{Agent})
                    

    CheckSaveDataForPlayer(Agent:agent)<decides><transacts>:void=
        if(Player := player[Agent]):
            if(SavedPlayerData[Player]):
                # no-op
            else:
                set SavedPlayerData[Player] = player_data{}

    OnPlayerAdded(Agent : agent):void=
        InitialPlayerData := player_data{}
        if(Player := player[Agent]):
            if(not SavedPlayerData[Player]):
                    if(set SavedPlayerData[Player] = InitialPlayerData){}
                    
            DamageHandler.CreateUIForPlayer(Player, LevelBuilder)
            LevelBuilder.HandleClassLoad(Player)
            LoadPlayer.Trigger(Player)

collectible_zone := class<concrete>:
    @editable CollectibleObjects : []collectible_object_device = array{}
    @editable ActiveObjects : int = 0
