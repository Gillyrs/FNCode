using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Persistance}

currency_type<public> := enum<persistable>:
    Money
    Diamonds

currency<public> := class<concrete>:
    @editable
    Name<public> : currency_type = currency_type.Money
    @editable
    DefaultCurrencyAmount<public> : int = 0
    @editable
    CurrencyGranters : []currency_granter = array{}
    var PersistanceHandler : persistance_device = persistance_device{}

    Init(PersistanceArg : persistance_device):void=
        set PersistanceHandler = PersistanceArg
        for(Granter : CurrencyGranters):
            Granter.Init(Self)

