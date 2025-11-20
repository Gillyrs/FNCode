using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Persistance}

currency_granter := class<concrete>:
    @editable 
    GrantAmount : int = 0

    @editable_slider(float):
        MinValue := option{0.0}
        MaxValue := option{1.0}
    GrantChance : float = 1.0
    
    @editable
    GrantMultiplierTreshold : vector2 = vector2{X := 1.0, Y := 1.0}

    var GranterCurrency<private> : currency = currency{}

    Init(CurrencyArg : currency):void=
        set GranterCurrency = CurrencyArg

    OnGrant<protected>(Agent : agent):void=
        if(RollChance[GrantChance],
        NewAmount := Round[GrantAmount * GetRandomFloat(GrantMultiplierTreshold.X, GrantMultiplierTreshold.Y)]):
            GranterCurrency.PersistanceHandler.TryDeposit(Agent, GranterCurrency.Name, NewAmount)
    
    RollChance<private>(Chance:float)<decides><transacts>:void =
        Chance > 0.0 and (Chance >= 1.0 or GetRandomFloat(0.0, 1.0) < Chance)


elimination_granter := class(currency_granter):

    @editable
    EliminationManager : elimination_manager_device = elimination_manager_device{}

    Init<override>(CurrencyArg : currency):void=
        (super:)Init(CurrencyArg)
        EliminationManager.EliminationEvent.Subscribe(OnElimination)

    OnElimination(Agent :? agent):void=
        if(Player := player[Agent?]):
            OnGrant(Player)

timer_granter := class(currency_granter):

    @editable
    Timer : timer_device = timer_device{}

    Init<override>(CurrencyArg : currency):void=
        (super:)Init(CurrencyArg)
        Timer.SuccessEvent.Subscribe(OnTimerSucceded)

    OnTimerSucceded(Agent :? agent):void=
        if(Player := player[Agent?]):
            OnGrant(Player)

event_granter := class(currency_granter):

    @editable
    Event : channel_device = channel_device{}

    Init<override>(CurrencyArg : currency):void=
        (super:)Init(CurrencyArg)
        Event.ReceivedTransmitEvent.Subscribe(OnEventSucceded)

    OnEventSucceded(Agent :? agent):void=
        if(Player := player[Agent?]):
            OnGrant(Player)
