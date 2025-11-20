
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }


level_complexity<public> := class<concrete>:

    @editable Bundles : []level_bundle = array{}
    @editable CoinToReach<public> : int = 0