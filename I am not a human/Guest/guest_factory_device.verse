
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

guest_factory_device<public> := class(creative_device):

    @editable GuestPull : []guest = array{}
    var GuestQueue : []guest = array{}
    var MonsterQueue : []guest = array{}

    GuestInEntryEvent<public> : event(guest) = event(guest){}
    GuestAcceptedEvent<public> : event(guest) = event(guest){}
    GuestRejectedEvent<public> : event(guest) = event(guest){}
    GuestRemovedEvent<public> : event(guest) = event(guest){}
    LightToggledEvent<public> : event(logic) = event(logic){}

    ProcessDisposed<public> : event() = event(){}

    OnBegin<override>()<suspends>:void=
        for(RGuest : GuestPull):
            if(MonsterGuest := monster_behaviour[RGuest.GuestBehavior]):
                set MonsterQueue += array{RGuest}
                Print("GUEST_FACTORY: GuestQueue added {RGuest.Name}")
            else if(RealGuest := guest_behaviour[RGuest.GuestBehavior]):
                set GuestQueue += array{RGuest}
                Print("GUEST_FACTORY: GuestQueue added {RGuest.Name}")

        spawn{AwaitGuestEntryEvent()}
        spawn{AwaitGuestFateEvent()}
        spawn{AwaitGuestRemovedEvent()}

    AwaitGuestEntryEvent<private>()<suspends>:void=
        race:
            block:
                AwaitedGuest := GuestInEntryEvent.Await()
                if(MonsterGuest := monster_behaviour[AwaitedGuest.GuestBehavior]):
                    PeekAndQueueMonster(AwaitedGuest)

                else if(RealGuest := guest_behaviour[AwaitedGuest.GuestBehavior]):
                    PeekAndQueueGuest(AwaitedGuest)
                    
                AwaitGuestEntryEvent()
            block:
                ProcessDisposed.Await()

    AwaitGuestFateEvent<private>()<suspends>:void=
        race:
            block:
                GuestAcceptedEvent.Await()   
                AwaitGuestFateEvent()
            block:
                GuestRejectedEvent.Await()
                AwaitGuestFateEvent()
            block:
                ProcessDisposed.Await()
        

    AwaitGuestRemovedEvent<private>()<suspends>:void=
        race:
            block:
                GuestRemovedEvent.Await() 
                AwaitGuestRemovedEvent()
            block:
                ProcessDisposed.Await()
        

    GetNewGuest<public>():guest=
        if(NewGuest := GuestQueue[0]):
            return NewGuest
        return guest{}
    
    GetNewMonster<public>():guest=
        if(NewGuest := MonsterQueue[0]):
            return NewGuest
        return guest{}

    PeekAndQueueGuest(TGuest : guest):void=
        var NewArray : []guest = array{}
            for(X := 1..GuestQueue.Length - 1):
                if(RGuest := GuestQueue[X]):
                    set NewArray += array{RGuest}
            set NewArray += array{TGuest}
            set GuestQueue = NewArray
        Print("GUEST_FACTORY: Guest peeked")
    
    PeekAndQueueMonster(TGuest : guest):void=
        var NewArray : []guest = array{}
            for(X := 1..MonsterQueue.Length - 1):
                if(RGuest := MonsterQueue[X]):
                    set NewArray += array{RGuest}
            set NewArray += array{TGuest}
            set MonsterQueue = NewArray
        Print("GUEST_FACTORY: Monster peeked")
        