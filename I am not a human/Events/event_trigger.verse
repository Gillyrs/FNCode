using { /Fortnite.com }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { Guest }

event_trigger<public> := class():
    @editable 
    GameEvent<protected> : game_event = game_event{}

    OnLaunchAborted : event() = event(){}

    LaunchEvent<public>():void=
        return

    Abort<public>():void=
        OnLaunchAborted.Signal()

evented_event_trigger := class(event_trigger):
    @editable
    GuestFactory : guest_factory_device = guest_factory_device{}

    @editable
    AwaitAnyEntries : int = 0
    @editable
    AwaitAnyAccept : int = 0
    @editable
    AwaitAnyReject : int = 0
    @editable
    AwaitAnyRemoved : int = 0
    @editable
    AwaitLightToggle :? logic = false

    var RAwaitAnyEntries : int = 0
    var RAwaitAnyAccept : int = 0
    var RAwaitAnyReject : int = 0
    var RAwaitAnyRemoved : int = 0
    var RAwaitLightToggle :? logic = false

    LaunchEvent<override>():void=
        Print("EVENTED TRIGGER: Awaiting events")
        spawn{AwaitFactoryEvent(AwaitAnyEntries, GuestFactory.GuestInEntryEvent)}
        spawn{AwaitFactoryEvent(AwaitAnyAccept, GuestFactory.GuestAcceptedEvent)}
        spawn{AwaitFactoryEvent(AwaitAnyReject, GuestFactory.GuestRejectedEvent)}
        spawn{AwaitFactoryEvent(AwaitAnyRemoved, GuestFactory.GuestRemovedEvent)}
        spawn{AwaitFactoryEvent(AwaitLightToggle, GuestFactory.LightToggledEvent)}

    AwaitFactoryEvent(Field : int, AwaitEvent : event(guest), ?TempFieldArg : int = 0)<suspends>:void=
        var TempField : int = TempFieldArg
        race:
            block:
                AwaitEvent.Await()
                set TempField += 1
                if(TempField = Field):
                    GameEvent.Call()
                AwaitFactoryEvent(Field, AwaitEvent, ?TempFieldArg := TempField)
            block:
                OnLaunchAborted.Await()
    
    AwaitFactoryEvent(Field :? logic, AwaitEvent : event(logic))<suspends>:void=
        if(RField := Field?):
            race:
                block:
                    State := AwaitEvent.Await()
                    if(RField = State):
                        GameEvent.Call()
                    AwaitFactoryEvent(Field, AwaitEvent)
                block:
                    OnLaunchAborted.Await()


    Abort<override>():void=
        set RAwaitAnyEntries = 0
        set RAwaitAnyAccept = 0
        set RAwaitAnyReject = 0
        set RAwaitAnyRemoved = 0
        set RAwaitLightToggle = false
        (super:)Abort()
    
timed_event_trigger<public> := class(event_trigger, rollable_chance):
    @editable TimeRange<public> : vector2 = vector2{}
    @editable_slider(float):
         MinValue := option{0.0}, MaxValue := option{1.0}
    EventChance : float = 1.0

    OnLaunchAborted<override> : event() = event(){}
    
    LaunchEvent<override>():void=
        Print("TIMED TRIGGER: Launching time event")
            if(TimeRange.X <> 0.0 and TimeRange.Y <> 0.0):
                if(X := Round[TimeRange.X],
                Y := Round[TimeRange.Y],
                Time := GetRandomInt(X, Y) * 1.0,
                RollChance[EventChance]):
                    Print("TRIGGER: Spawning tracker")
                    spawn{TrackTimeEvent(Time)}

    TrackTimeEvent<private>(Time : float)<suspends>:void=
        race:
            block:
                Print("TIMED TRIGGER: Awaiting game event call")
                Sleep(Time)
                GameEvent.Call()
            block:
                OnLaunchAborted.Await()
    

