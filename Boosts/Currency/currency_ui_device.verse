using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { MyUI }
using { Persistance }
using { Currency }

currency_ui_device<public> := class(creative_device):
    @editable 
    PersistanceHandler : persistance_device = persistance_device{}

    var UIMap : [player]widget = map{}

    SetDynamicText<localizes>(value:string) : message="{value}"

    OnBegin<override>():void=
        for(Player : GetPlayspace().GetPlayers()):
            InitCurrencyWidget(Player)
        
        GetPlayspace().PlayerAddedEvent().Subscribe(InitCurrencyWidget)
        spawn{AwaitCurrencyChange()}

    InitCurrencyWidget(Player : player):void=
        if(PlayerUI := GetPlayerUI[Player]):
                if(CurrencyWidget := MyUI.CurrencyUI{},
                set UIMap[Player] = CurrencyWidget,
                Amount := PlayerData[Player].CurrencyMap[currency_type.Money]):
                    PlayerUI.AddWidget(CurrencyWidget)
                    set CurrencyWidget.Money = SetDynamicText("{Amount}")
                    Print("Currency ui inited")

    AwaitCurrencyChange()<suspends>:void=
        loop:
            CurrencyArgs := PersistanceHandler.OnCurrencyAmountChanged.Await()
            if(RType := CurrencyArgs.CurrencyType?,
            RType = currency_type.Money,
            Player := CurrencyArgs.Player?
            Amount := PlayerData[Player].CurrencyMap[RType],
            PlayerWidget := MyUI.CurrencyUI[UIMap[Player]]):
                set PlayerWidget.Money = SetDynamicText("{Amount}")

