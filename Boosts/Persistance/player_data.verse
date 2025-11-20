using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Currency}

var PlayerData<public>:weak_map(player, player_data) = map{}

player_data<public> := class<final><persistable>:
    CurrencyMap<public> : [currency_type]int = map{}
    Rows<public> : []int = array{}

MakePlayerData<internal><constructor>(Source : player_data):= player_data:
    CurrencyMap := Source.CurrencyMap
    Rows := Source.Rows

currency_change_args<public> := class():
    Player<public> :? player = false
    CurrencyType<public> :? currency_type = false

persistance_device<public> := class(creative_device):
    @editable
    ResetButton : button_device = button_device{}

    OnCurrencyAmountChanged<public> : event(currency_change_args) = event(currency_change_args){}

    var DefaultPlayerData : player_data = player_data{}

    Init<public>(CurrencyBuilder : currency_builder_device, UpgradeAbility : upgrade_abilities_device):void=
        set DefaultPlayerData = MakeDefaultPlayerData(CurrencyBuilder, UpgradeAbility)
        ResetButton.InteractedWithEvent.Subscribe(OnReset)
        for(Player : GetPlayspace().GetPlayers()):
            if(RealData := PlayerData[Player]):
            else if(set PlayerData[Player] = DefaultPlayerData):

    OnReset(Agent : agent):void=
        if(Player := player[Agent],
        set PlayerData[Player] = DefaultPlayerData):
            Print("SDf")


    MakeDefaultPlayerData<public>(CurrencyBuilder : currency_builder_device, UpgradeAbility : upgrade_abilities_device):player_data=
        var RawPlayerData : player_data = player_data{}

        var DefaultCurrencyMap : [currency_type]int = map{}
            for(X -> CurrencyElement : CurrencyBuilder.Currencies):
                if(set DefaultCurrencyMap[CurrencyElement.Name] = CurrencyElement.DefaultCurrencyAmount):
                    Print("Setted {X} to default value {CurrencyElement.DefaultCurrencyAmount}")
        
        var DefaultRows : []int = array{}
            for(X := 0..UpgradeAbility.UpgradesAbilities.Length - 1):
                set DefaultRows += array{0}

        set RawPlayerData = player_data:
            CurrencyMap := DefaultCurrencyMap
            Rows := DefaultRows
            
        return RawPlayerData

    TryDeposit<public>(Agent : agent, CurrencyTypeArg : currency_type, Amount : int):void=
        if(Player := player[Agent]):
            var NewCurrencyMap : [currency_type]int = map{}
            if(PastData := PlayerData[Player],
            set NewCurrencyMap = PastData.CurrencyMap,
            PastAmount := NewCurrencyMap[CurrencyTypeArg]):

                NewAmount := PastAmount + Amount
                if(set NewCurrencyMap[CurrencyTypeArg] = NewAmount):
                    NewPlayerData := player_data:
                        CurrencyMap := NewCurrencyMap
                        MakePlayerData<constructor>(PastData)
                    if(set PlayerData[Player] = NewPlayerData):
                        OnCurrencyAmountChanged.Signal(
                            currency_change_args{Player := option{Player}, CurrencyType := option{CurrencyTypeArg}})
            else if(not PlayerData[Player]):
                if(set PlayerData[Player] = DefaultPlayerData):
                    TryDeposit(Agent, CurrencyTypeArg, Amount)

    TryWithdraw<public>(Agent : agent, CurrencyTypeArg : currency_type, Amount : int):void=
        if(Player := player[Agent]):
            var NewCurrencyMap : [currency_type]int = map{}
            if(PastData := PlayerData[Player],
            set NewCurrencyMap = PastData.CurrencyMap,
            PastAmount := NewCurrencyMap[CurrencyTypeArg],
            PastAmount >= Amount):
                NewAmount := PastAmount - Amount
                if(set NewCurrencyMap[CurrencyTypeArg] = NewAmount):
                    NewPlayerData := player_data:
                        CurrencyMap := NewCurrencyMap
                        MakePlayerData<constructor>(PastData)                 
                    if(set PlayerData[Player] = NewPlayerData):
                        OnCurrencyAmountChanged.Signal(
                            currency_change_args{Player := option{Player}, CurrencyType := option{CurrencyTypeArg}})

            else if(not PlayerData[Player]):
                if(set PlayerData[Player] = DefaultPlayerData):
                    TryWithdraw(Agent, CurrencyTypeArg, Amount)

    TryUpdateRowLevel<public>(Agent : agent, RowIndex : int):void=
        if(Player := player[Agent]):
            var NewRows : []int = array{}
            if(PastData := PlayerData[Player],
            set NewRows = PastData.Rows,
            PastLevel := NewRows[RowIndex]):
                NewLevel := PastLevel + 1
                if(set NewRows[RowIndex] = NewLevel):
                    NewPlayerData := player_data:
                        Rows := NewRows
                        MakePlayerData<constructor>(PastData)                 
                    if(set PlayerData[Player] = NewPlayerData):

            else if(not PlayerData[Player]):
                if(set PlayerData[Player] = DefaultPlayerData):
                    TryUpdateRowLevel(Agent, RowIndex)
            
            
