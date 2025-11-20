using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }

coin_tag := class(tag) {}

small_coins_device := class(creative_device):

    @editable Accolade : accolades_device = accolades_device{}

    OnBegin<override>()<suspends>:void=
        for (FoundTaggedObject : FindCreativeObjectsWithTag(coin_tag{})):
            if (FoundDevice := collectible_object_device[FoundTaggedObject]):
                FoundDevice.CollectedEvent.Subscribe(OnPlayerEarnedCoin)
        spawn{RespawnCycle()}

    OnPlayerEarnedCoin(Agent : agent):void=
        Accolade.Award(Agent)

    RespawnCycle()<suspends>:void=
        Objects := FindCreativeObjectsWithTag(coin_tag{})
        loop:
            Sleep(3.0)
            for(Object : Objects):
                if (FoundDevice := collectible_object_device[Object]):
                    FoundDevice.RespawnForAll()
                    Sleep(0.1)
        

clicker_prop_device := class(creative_device):

    @editable
    PropManipulator : prop_manipulator_device = prop_manipulator_device{}

    @editable
    ClickerProp : creative_prop = creative_prop{}

    @editable
    AwardGranter : accolades_device = accolades_device{}

    var AnimationKeyFrames : []keyframe_delta = array{}

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        PropManipulator.DamagedEvent.Subscribe(OnPropDamaged)

        TargetScale : float = 0.8
        InverseTargetScale : float = 1.0/0.8
        DownScaleKeyFrame : keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := 0.0 }
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{ X := TargetScale, Y := TargetScale, Z := TargetScale }
            Time := 0.2
            Interpolation := EaseIn
        }

        UpScaleKeyFrame : keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := 0.0 }
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{ X := InverseTargetScale, Y := InverseTargetScale, Z := InverseTargetScale }
            Time := 0.2
            Interpolation := EaseIn
        }

        set AnimationKeyFrames = array{ DownScaleKeyFrame, UpScaleKeyFrame }

    OnPropDamaged(Agent : agent):void=
        AwardGranter.Award(Agent)

        if (PropAnimController := ClickerProp.GetAnimationController[]):
            AnimState := PropAnimController.GetState()
            if (AnimState = animation_controller_state.AnimationNotSet or AnimState = animation_controller_state.Stopped):
                PropAnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.OneShot)
                PropAnimController.Play()