using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Weapon}
using {Currency}

var PlayerData:weak_map(player, player_data) = map{}

player_data := class<final><persistable>:
    TierMap : [int][weapon_type]rarity_and_clicks = map{}
    CurrencyMap : [currency_type]int = map{}

MakePlayerData<internal><constructor>(Source : player_data):= player_data:
    TierMap := Source.TierMap
    CurrencyMap := Source.CurrencyMap

persistance_device<public> := class(creative_device):

    @editable
    TierBuilder :? tier_builder_device = false

    @editable 
    CurrencyBuilder :? currency_builder_device = false

    var DefaultPlayerData : player_data = player_data{}

    OnBegin<override>():void=
        if(TBuilder := TierBuilder?,
        CBuilder := CurrencyBuilder?):
            set DefaultPlayerData = MakeDefaultPlayerData(TBuilder, CBuilder)

    MakeDefaultPlayerData<internal>(TierBuilderArg : tier_builder_device, CurrencyBuilderArg : currency_builder_device):player_data=
        var RawPlayerData : player_data = player_data{}

        var DefaultTierMap : [int][weapon_type]rarity_and_clicks = map{}
        for(TierIndex -> TierElement : TierBuilderArg.Tiers):
            if(TierIndex = 0):
                var NewMap : [weapon_type]rarity_and_clicks = map{}
                for(WeaponElement : TierElement.WeaponDefinitions):
                    if(set NewMap[WeaponElement.WeaponID] = rarity_and_clicks{}):
                if(set DefaultTierMap[TierIndex] = NewMap):

        var DefaultCurrencyMap : [currency_type]int = map{}
        for(CurrencyElement : CurrencyBuilderArg.Currencies):
            if(set DefaultCurrencyMap[CurrencyElement.Name] = CurrencyElement.DefaultCurrencyAmount):
        
        set RawPlayerData = player_data:
            TierMap := DefaultTierMap
            CurrencyMap := DefaultCurrencyMap
            
        return RawPlayerData

    SetRarityAndClicks<public>(Agent : agent, Tier : int, WeaponType : weapon_type, RarityAndClicks : rarity_and_clicks):void=
        if(Player := player[Agent]):
            var NewTierMap : [int][weapon_type]rarity_and_clicks = map{}
            if(PastData := PlayerData[Player],
            set NewTierMap = PastData.TierMap,
            set NewTierMap[Tier][WeaponType] = RarityAndClicks):
                NewPlayerData := player_data:
                    TierMap := NewTierMap
                    MakePlayerData<constructor>(PastData)
                    
                if(set PlayerData[Player] = NewPlayerData):
            
            else if(not PlayerData[Player]):
                if(set PlayerData[Player] = DefaultPlayerData):
                    SetRarityAndClicks(Agent, Tier, WeaponType, RarityAndClicks)


    TryDeposit<public>(Agent : agent, CurrencyType : currency_type, Amount : int):void=
        if(Player := player[Agent]):
            var NewCurrencyMap : [currency_type]int = map{}
            if(PastData := PlayerData[Player],
            set NewCurrencyMap = PastData.CurrencyMap,
            PastAmount := NewCurrencyMap[CurrencyType]):

                NewAmount := PastAmount + Amount
                if(set NewCurrencyMap[CurrencyType] = NewAmount):
                    NewPlayerData := player_data:
                        CurrencyMap := NewCurrencyMap
                        MakePlayerData<constructor>(PastData)
                        
                    if(set PlayerData[Player] = NewPlayerData):
            else if(not PlayerData[Player]):
                if(set PlayerData[Player] = DefaultPlayerData):
                    TryDeposit(Agent, CurrencyType, Amount)

    TryWithdraw<public>(Agent : agent, CurrencyType : currency_type, Amount : int):void=
        if(Player := player[Agent]):
            var NewCurrencyMap : [currency_type]int = map{}
            if(PastData := PlayerData[Player],
            set NewCurrencyMap = PastData.CurrencyMap,
            PastAmount := NewCurrencyMap[CurrencyType],
            PastAmount >= Amount):
                NewAmount := PastAmount - Amount
                if(set NewCurrencyMap[CurrencyType] = NewAmount):
                    NewPlayerData := player_data:
                        CurrencyMap := NewCurrencyMap
                        MakePlayerData<constructor>(PastData)
                        
                    if(set PlayerData[Player] = NewPlayerData):

            else if(not PlayerData[Player]):
                if(set PlayerData[Player] = DefaultPlayerData):
                    TryWithdraw(Agent, CurrencyType, Amount)
            
            
