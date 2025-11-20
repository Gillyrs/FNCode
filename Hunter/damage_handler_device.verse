using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Fortnite.com/UI }

damage_handler_device := class(creative_device):

    @editable DamageAudioPlayers : []audio_player_device = array{}
    @editable DamageHUDs : []hud_message_device = array{}
    @editable SpawnDevice : spawn_device = spawn_device{}
    @editable Numbers : []texture = array{}

    var Subs : []cancelable = array{}

    var PlayerUIMap : [player]?canvas = map{}

    SetDynamicText<localizes>(value:string) : message="{value}"

    BeginTrackSmokeDamageForPlayers(Players : []player):void=
        for(Player : Players):
            if:
                FortChar := Player.GetFortCharacter[]
            then:
                AddStateSub(FortChar.DamagedEvent().Subscribe(OnPlayerDamaged))
                AddStateSub(FortChar.HealedEvent().Subscribe(OnPlayerHealed))

    OnPlayerSpawned(Player : agent):void=
        if(RPlayer := player[Player]):
            UpdatePlayerHealthImage(RPlayer)
            
    MakeMainCanvas(Level : int, MoneyCounter : message):canvas=
        BackgroundImage : texture_block = texture_block{
                    DefaultImage := Bg
                    DefaultDesiredSize := vector2{X:= 359.0, Y := 258.0}
                }
        HeartImage : texture_block = texture_block{
                    DefaultImage := Heart
                    DefaultDesiredSize := vector2{X:= 100.0, Y := 100.0}  }
        StarImage : texture_block = texture_block{
                    DefaultImage := Star
                    DefaultDesiredSize := vector2{X:= 140.0, Y := 140.0} }
        var StarTextImage : texture_block = texture_block{
                DefaultImage := Star
                DefaultDesiredSize := vector2{X:= 92.810814, Y := 78.396393} 
        }
        MoneyCounterText := text_block{
                    DefaultText := MoneyCounter
                    DefaultTextColor := MakeColorFromHex("FFD800FF")
                    DefaultJustification := text_justification.Center 
                }
        if(Number := Numbers[Level]):
            StarTextImage.SetImage(Number)

        CanvasSlots:=canvas:
            Slots := array:
                canvas_slot:
                    Widget := BackgroundImage
                                Offsets := margin{Left := -182.0, Top := -127.807808}
                                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                                ZOrder := 1
                canvas_slot:
                    Widget := HeartImage
                                Offsets := margin{Left := 26.61261, Top := -43.807808}
                                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                                ZOrder := 3
                canvas_slot:
                    Widget := StarImage
                                Offsets := margin{Left := -157.38739, Top := -99.807808}
                                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                                ZOrder := 3
                canvas_slot:
                    Widget := StarTextImage
                                Offsets := margin{Left := -71.5, Top := -61.0}
                                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                                ZOrder := 3
                canvas_slot:
                    Widget := MoneyCounterText
                                Offsets := margin{Left := -55.0, Top := 23.0}
                                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                                ZOrder := 3
                                SizeToContent := false
                
        MainCanvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget := CanvasSlots
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 1.0}, Maximum := vector2{X := 0.0, Y := 1.0}}
                    Offsets := margin{Left := -12.0, Top := -244.0}

        return MainCanvas
    
    UpdateLevel(Player : player, PlayerLevel : int):void=
        if(MainCanvas := PlayerUIMap[Player]?,
        StartTextImage := texture_block[canvas[MainCanvas.Slots[0].Widget].Slots[3].Widget],
        Number := Numbers[PlayerLevel]):
            StartTextImage.SetImage(Number)

    UpdateMoneyCounter(Player : player, Text : message):void=
        if(MainCanvas := PlayerUIMap[Player]?,
        MoneyCounter := text_block[canvas[MainCanvas.Slots[0].Widget].Slots[4].Widget]):
            Print("Text set")
            MoneyCounter.SetText(Text)
    
    InitPlayersHud(LevelBuilder : Levels.level_builder):void=
        for(Player : GetPlayspace().GetPlayers()):
            CreateUIForPlayer(Player, LevelBuilder)

        for(Spawner : SpawnDevice.Team3SpawnPads):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
    
    CreateUIForPlayer(Player : player, LevelBuilder : Levels.level_builder):void=
        if(PlayerData := SavedPlayerData[Player],
        CoinsToReach := LevelBuilder.Complexities[PlayerData.Complexity].CoinToReach):
            Canvas := MakeMainCanvas(PlayerData.Complexity, SetDynamicText("{PlayerData.Coins}/{CoinsToReach}"))
            if(set PlayerUIMap[Player] = option{Canvas},
                PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(Canvas)
                    UpdatePlayerHealthImage(Player)
                    Print("Widget added")
    
    OnPlayerHealed(Result : healing_result):void=
        if:
            Target := player[fort_character[Result.Target].GetAgent[]]
        then:
            UpdatePlayerHealthImage(Target)

    OnPlayerDamaged(Result : damage_result):void=
        
        Print("Damaged")
        if:
            Target := player[fort_character[Result.Target].GetAgent[]]
            not player[Result.Instigator?]
            AudioPlayer := DamageAudioPlayers[GetRandomInt(0, DamageAudioPlayers.Length - 1)]
            HUDPlayer := DamageHUDs[GetRandomInt(0, DamageHUDs.Length - 1)]
        then:
            AudioPlayer.Play(Target)
            HUDPlayer.Show(Target)
            UpdatePlayerHealthImage(Target)
            
    UpdatePlayerHealthImage(Player : player):void=
        if(PlayerUI := PlayerUIMap[Player]?,
            Health := Player.GetFortCharacter[].GetHealth(),
            HeartImage := texture_block[canvas[PlayerUI.Slots[0].Widget].Slots[1].Widget]):
                if(Health > 70.0):
                    HeartImage.SetTint(MakeColorFromSRGBValues(Red := 133, Green := 255, Blue := 0))
                else if(Health > 40.0):
                    HeartImage.SetTint(MakeColorFromSRGBValues(Red := 255, Green := 239, Blue := 0))
                else:
                    HeartImage.SetTint(MakeColorFromSRGBValues(Red := 255, Green := 65, Blue := 0))

    AddStateSub(Sub : cancelable):void=
        set Subs = Subs + array{Sub}      
        
    CancelAllSubs():void=
        var Index : int = 0
        for(Sub : Subs):
            Sub.Cancel()

        set Subs = array{}