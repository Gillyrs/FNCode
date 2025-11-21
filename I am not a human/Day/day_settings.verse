using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { Events }
using { Guest }

day_settings := class():
   
    @editable 
    GameEvents : []event_trigger = array{}

    @editable 
    FatigueRange : vector2 = vector2{}

    FinishDayEvent : event() = event(){}
    
    LaunchDay(Arranger : dimensional_arranger_device, GuestFactory : guest_factory_device):void=
        for(GameEvent : GameEvents):
            GameEvent.LaunchEvent()
    
    LaunchEvents<private>():void=
        for(GameEvent : GameEvents):
            GameEvent.LaunchEvent()
    
    AbortEvents<public>():void=
        for(GameEvent : GameEvents):
            GameEvent.Abort()

    FinishDay():void=
        FinishDayEvent.Signal()

day_settings_amount := class(day_settings):
    
    @editable
    GuestAmount : vector2 = vector2{}
    var RealGuestAmount : int = 0
    var ProvidedGuests : int = 0
    @editable
    MonsterAmount : vector2 = vector2{}
    var RealMonsterAmount : int = 0
    var ProvidedMonsters : int = 0
    @editable
    VisitDelayRange : vector2 = vector2{}

    var Arranger : dimensional_arranger_device = dimensional_arranger_device{}
    var GuestFactory : guest_factory_device = guest_factory_device{}


    LaunchDay<override>(ArrangerArg : dimensional_arranger_device, GuestFactoryArg : guest_factory_device):void=
        (super:)LaunchDay(ArrangerArg, GuestFactoryArg)
        Print("DAY: Events Launched")
        set Arranger = ArrangerArg
        set GuestFactory = GuestFactoryArg

        set RealGuestAmount = GuestAmount.GetRandomInt()

        set RealMonsterAmount = MonsterAmount.GetRandomInt()
            

        spawn{RollProvide()}

    RollProvide()<suspends>:void=
        TypeChoice := GetRandomInt(0,1)
        Print("RollProvide: type choice {TypeChoice}")
        if(TypeChoice = 0):
            if(ProvidedGuests <> RealGuestAmount,
            RealGuestAmount <> 0):
                ProvideGuest()
            else if(ProvidedMonsters <> RealMonsterAmount,
            RealMonsterAmount <> 0):
                ProvideMonster()
            else:
                FinishDay()
        else if(TypeChoice = 1):
            if(ProvidedMonsters <> RealMonsterAmount,
            RealMonsterAmount <> 0):
                ProvideMonster()
            else if(ProvidedGuests <> RealGuestAmount,
            RealGuestAmount <> 0):
                ProvideGuest()
            else:
                FinishDay()
        Print("DAY: Roll provided")

    ProvideGuest()<suspends>:void=
        VisitDelay := VisitDelayRange.GetRandomInt()
        Print("DAY: Awaiting visit delay {VisitDelay}")
        Sleep(VisitDelay * 1.0)
        NewGuest := GuestFactory.GetNewGuest()
        Arranger.PutGuestInEntryPoint(NewGuest)
        Print("DAY: Awaiting guest entry")
        set ProvidedGuests += 1
        AwaitGuestEntryResponse()

    ProvideMonster()<suspends>:void=
        VisitDelay := VisitDelayRange.GetRandomInt()
        Sleep(VisitDelay * 1.0)
        NewGuest := GuestFactory.GetNewMonster()
        Arranger.PutGuestInEntryPoint(NewGuest)
        set ProvidedMonsters += 1
        AwaitGuestEntryResponse()

    AwaitGuestEntryResponse()<suspends>:void=
        race:
            block:
                GuestFactory.GuestAcceptedEvent.Await()
                RollProvide()
            block:
                GuestFactory.GuestRejectedEvent.Await()
                RollProvide()
        


    

    
    