
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

guest<public> := class():
    @editable Name<public> : string = ""
    @editable OverridenLetInText : string = ""
    @editable GuestCharacterControllers<public> : []trigger_device = array{}
    @editable GuestIdleAnimationIndex : int = 0
    @editable GuestDialogTemplate : dialog_template = dialog_template{}
    @editable GuestBehavior : behaviour_template = behaviour_template{}

    DialogToggled<public> : event(logic) = event(logic){}