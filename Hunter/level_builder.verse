
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }

level_builder<public> := class(creative_device):

    @editable Complexities<public> : []level_complexity = array{}
    @editable OnBuildLevelSignal : channel_device = channel_device{}
    @editable OnComplexityRaised : channel_device = channel_device{}
    @editable EconomyManagerNR :? economy_manager_device = false
    @editable ClassSelectors<public> : []class_and_team_selector_device = array{}
    @editable NotEnoughMoney : hud_message_device = hud_message_device{}
    @editable Save : trigger_device = trigger_device{}

    var PlayerProvidedBundles : [agent]?[]level_bundle = map{}

    UIBuilder : level_ui_builder = level_ui_builder{}

    OnBegin<override>()<suspends>:void=
        OnBuildLevelSignal.ReceivedTransmitEvent.Subscribe(OnBuildLevelHandler)
        OnComplexityRaised.ReceivedTransmitEvent.Subscribe(OnComplexityRaisedHandler)

        set UIBuilder.LevelBuilder = option{Self}

    CloseUIForPlayer<public>(Player : player):void=
        UIBuilder.CloseUI(Player)

    OnComplexityRaisedHandler(Agent :? agent):void=
        if(Player := player[Agent?]):
            if:
                CheckSaveDataForPlayer[Player]
                SourceData := SavedPlayerData[Player]
            then:
                ResultData := player_data:
                    Complexity := SourceData.Complexity + 1
                    MakePlayerData<constructor>(SourceData)
                    
                if:
                    set SavedPlayerData[Player] = ResultData
            else:
                if:
                    SourceData := SavedPlayerData[Player] 
                then:
                    ResultData := player_data:
                        Complexity := 1
                        MakePlayerData<constructor>(SourceData)
                        
                    if:
                        set SavedPlayerData[Player] = ResultData
            

    OnBuildLevelHandler(Agent :? agent):void=
            if (Player := player[Agent?],
            PlayerCoins := SavedPlayerData[Player].Coins,
            PlayerData := SavedPlayerData[Player],
            Complexity := Complexities[PlayerData.Complexity]):
                if(PlayerCoins >= Complexity.CoinToReach):
                    BuildLevel(Player)
                else:
                    BuildNotEnoughCoins(Player)

    BuildNotEnoughCoins(Player : player):void=
        NotEnoughMoney.Show(Player)             
                    
    BuildLevel(Player : player):void=
        var Bundles : []level_bundle = array{}
             
        #Sset quantity you want. Level builder will bring this quantity
        #of random bundles in player complexity to level_ui_builder.BuildUI()
        BundleQuantity : int = 2


        var Complexity : level_complexity = level_complexity{}
        if(CheckSaveDataForPlayer[Player],
        PlayerComplexityInt := SavedPlayerData[Player].Complexity):
            if(ProvidedComplexity := Complexities[PlayerComplexityInt]):
                set Complexity = ProvidedComplexity
        
        if(PlayerData := SavedPlayerData[Player],
        PlayerData.ProvidedBundles.Length = BundleQuantity):
            for(BundleInt : PlayerData.ProvidedBundles):
                if(Bundle := Complexity.Bundles[BundleInt]):
                    set Bundles += array{Bundle}
            Print("Have provided Bundles")
            if:       
                set PlayerProvidedBundles[Player] = option{Bundles}
            UIBuilder.BuildUI(Bundles, Player)
            return
        
        ShuffledArray := Shuffle(Complexity.Bundles)
        for(X := 0..BundleQuantity - 1):
            if(Bundle := ShuffledArray[X]):
                set Bundles += array{Bundle}
        if:       
            set PlayerProvidedBundles[Player] = option{Bundles}

        Print("Level Built on new bundles")
        if:
            Bundle1 := Bundles[0]
            Bundle2 := Bundles[1]
            PlayerData := SavedPlayerData[Player]
        then:
            Bundle1Index := Complexity.Bundles.FindLevelBundleIndex(Bundle1)
            Bundle2Index := Complexity.Bundles.FindLevelBundleIndex(Bundle2)
            Newdata := player_data:
                ProvidedBundles := array{Bundle1Index, Bundle2Index}
                    MakePlayerData<constructor>(PlayerData)
                    
            if:
                set SavedPlayerData[Player] = Newdata
            then:
                 UIBuilder.BuildUI(Bundles, Player)

        return

    HandleButtonPressed(BundleChosenIndex : int, Player : player):void=
        if(Bundles := PlayerProvidedBundles[Player]?):
            Print("Activating bundle... {Bundles.Length}")
            if(ChosenBundle := Bundles[BundleChosenIndex]):
                ActivateBundle(ChosenBundle, Player)
    
    
    ActivateBundle(Bundle : level_bundle, Player : player):void=
        if:
            set PlayerProvidedBundles[Player] = false
            PlayerData := SavedPlayerData[Player]
            Complexity := Complexities[PlayerData.Complexity]
        then:
            NewData := player_data:
                Coins := PlayerData.Coins - Complexity.CoinToReach
                ProvidedBundles := array{}
                MakePlayerData<constructor>(PlayerData)
                
            if: 
                set SavedPlayerData[Player] = NewData
            then:
                if(ItemGranter := Bundle.ItemsProvide?):
                    ItemGranter.GrantItem(Player)
                if(ClassInt := Bundle.ClassInt?,
                ClassSelector := ClassSelectors[ClassInt - 1],
                RData := SavedPlayerData[Player]):
                    Print("Class changed")
                    ClassSelector.ChangeClass(Player)
                    NewClassData := player_data:
                        ClassNumber := ClassInt
                        MakePlayerData<constructor>(RData)
                        
                    SetPlayerData(Player, NewClassData)

                OnComplexityRaised.Transmit(option{Player})
                if(RManager := EconomyManagerNR?):
                    RManager.OnLevelUpdate(option{Player})
                    RManager.OnMoneyUpdate(option{Player})
                    Save.Trigger(Player)

        return
    
    
    HandleClassLoad(Player : player):void=
        if(PlayerClass := SavedPlayerData[Player].ClassNumber,
        Selector := ClassSelectors[PlayerClass - 1]):
            Selector.ChangeClass(Player)


    RemoveKeyFromMap(Map:[agent]int, ElementToRemove:agent):[agent]int=
        var NewMap:[agent]int = map{}
        for (Key -> Value : Map, Key <> ElementToRemove):
             set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
        return NewMap

    CheckSaveDataForPlayer(Agent:agent)<decides><transacts>:void=
        if(Player := player[Agent]):
            if(SavedPlayerData[Player]):
                # no-op
            else:
                set SavedPlayerData[Player] = player_data{}