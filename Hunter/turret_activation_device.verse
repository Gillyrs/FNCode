
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
turret_activation_device := class(creative_device):

    @editable Turrets : []automated_turret_device = array{}
    @editable Button : button_device = button_device{}
    @editable Delay : float = 1.0

    OnBegin<override>()<suspends>:void=
        for(Turret : Turrets):
            Turret.Disable()
        Button.InteractedWithEvent.Subscribe(OnInteract)

    OnInteract(InAgent : agent):void=
        spawn:
            OnTurretProcess()
    
    OnTurretProcess()<suspends>:void=
        for(Turret : Turrets):
            Turret.Enable()
        Sleep(Delay)
        for(Turret : Turrets):
            Turret.Disable()


    