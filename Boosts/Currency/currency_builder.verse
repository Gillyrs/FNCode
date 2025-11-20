using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { Persistance }


currency_builder_device<public> := class(creative_device):
    @editable
    Currencies<public> : []currency = array{}
    @editable 
    PersistanceHandler : persistance_device = persistance_device{}
    
    OnBegin<override>():void=
        for(Element : Currencies):
            Element.Init(PersistanceHandler)