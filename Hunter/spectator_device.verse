
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }

spectator_device := class(creative_device):

    @editable TeleportSpectatePosition : creative_prop = creative_prop{}
    @editable TeleportLobbyPosition : creative_prop = creative_prop{}
    @editable SpectateButton : button_device = button_device{}
    @editable ItemGranter : item_granter_device = item_granter_device{}
    @editable ItemRemover : item_remover_device = item_remover_device{}
    @editable SignalRemoteManager : signal_remote_manager_device = signal_remote_manager_device{}
    @editable SpectateClass : class_and_team_selector_device = class_and_team_selector_device{}
    @editable LevelBuilder :? Levels.level_builder = false

    var Spectators : []player := array{}

    var ButtonSub :? cancelable = false

    Enable():void=
        set ButtonSub = option{SpectateButton.InteractedWithEvent.Subscribe(OnSpectatorsModeJoined)}

    Disable():void=
        if(RSub := ButtonSub?):
            RSub.Cancel()
            set ButtonSub = false

    OnBegin<override>()<suspends>:void=
        Enable()
        SignalRemoteManager.PrimarySignalEvent.Subscribe(OnSignalCaught)
        SignalRemoteManager.SecondarySignalEvent.Subscribe(OnSignalCaught)

    OnSpectatorsModeJoined(Agent : agent):void=
        if(Player := player[Agent],
        FortChar := Player.GetFortCharacter[]):
            FortChar.Hide()
            Transform := TeleportSpectatePosition.GetTransform()
            if(FortChar.TeleportTo[Transform.Translation, Transform.Rotation]){}
            set Spectators += array{Player}
            SpectateClass.ChangeClass(Player)

    OnSignalCaught(Agent : agent):void=
        if(Player := player[Agent],
        FortChar := Player.GetFortCharacter[],
        Transform := TeleportLobbyPosition.GetTransform(),
        FortChar.TeleportTo[Transform.Translation, Transform.Rotation]):
            RemoveSpectatorAffilation(Agent)

    RemoveAllAffilations():void=
        for(Spectator : Spectators):
            RemoveSpectatorAffilation(Spectator)

    RemoveSpectatorAffilation(Agent : agent):void=
        IsContains := Contains(Agent)
        if(Player := player[Agent],
        IsContains = true
        FortChar := Player.GetFortCharacter[],
        RBuilder := LevelBuilder?
        ClassSelector := RBuilder.ClassSelectors[SavedPlayerData[Player].ClassNumber - 1]):
            FortChar.Show()
            ClassSelector.ChangeClass(Player)
            for(X := 0..Spectators.Length):
                if(Player = Spectators[X]):
                    if(NewSpectators := Spectators.RemoveElement[X]):
                        set Spectators = NewSpectators
                        ItemRemover.Remove(Player)

    Contains(Agent : agent):logic=
        if(Player := player[Agent]):
            for(Spectator : Spectators):
                if(Spectator = Player):
                    return true

        return false

