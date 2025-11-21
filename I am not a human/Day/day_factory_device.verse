using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }
using { Guest }


day_factory_device := class(creative_device):

    @editable 
    DayPull : []day_range = array{}
    @editable
    Arranger : dimensional_arranger_device = dimensional_arranger_device{}
    @editable
    GuestFactory : guest_factory_device = guest_factory_device{}

    @editable
    ActivateButton : button_device = button_device{}


    var DayGrid : []day_settings = array{}

    OnBegin<override>()<suspends>:void=
        ActivateButton.InteractedWithEvent.Subscribe(OnButtonInteracted)

    OnButtonInteracted(Agent : agent):void=
        spawn{LaunchGame()}

    LaunchGame()<suspends>:void=
        Print("DAY_FACTORY: Game Launched")
        var LastIndex : int = 0
        for(DayRange : DayPull):
            if(Bound := Round[DayRange.Bounds.Y]):
                Print("DAY_FACTORY: Rounded bound is {Bound}")
                for(Index := LastIndex..Bound):
                    set DayGrid += array{DayRange.DaySettings}
                    Print("DAY_FACTORY: DayGrid at {Index} set")
                set LastIndex = Bound + 1

        for(SDay : DayGrid):
            Print("DAY_FACTORY: SDay Launched")
            SDay.LaunchDay(Arranger, GuestFactory)
            SDay.FinishDayEvent.Await()



            