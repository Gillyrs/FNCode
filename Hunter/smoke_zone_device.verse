using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Fortnite.com/UI }

smoke_zone_device := class(creative_device):

    @editable SmokeZones : []smoke_zone = array{}
    @editable Timer : timer_device = timer_device{}
    @editable ParallelVFXQuantity : int = 1
    @editable GasLeakAudio : audio_player_device = audio_player_device{}

    DeviceActivationDelay<private> : float = 1.0

    var ActualSmokeZone :? smoke_zone = false
    var ActualSmokeZoneIndex : int = 0

    var PlayerUIMap : [player]?canvas = map{}
    var IsUIShown : logic = false

    SetDynamicText<localizes>(value:string) : message="{value}"

    OnBegin<override>()<suspends>:void=
        spawn{UpdatePlayerHUD()}
        Timer.SuccessEvent.Subscribe(IterateSmokeCycleFinished)

    ShowHUD(Players : []player):void=
        set IsUIShown = true
        Print("Show hud ")

        

        for (Player : Players):
            Print("Player iterated")
            if (PlayerUI := GetPlayerUI[Player]):
                GasCanvas := MakeGasCanvas()
                PlayerUI.AddWidget(GasCanvas)
                if (set PlayerUIMap[Player] = option{GasCanvas}) {}

        ResetHUDBar()
    
    MakeGasCanvas():canvas= 
        GasCanvas : canvas = canvas:
            Slots := array{
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 1.0}, Maximum := vector2{X := 0.5, Y := 1.0}},
                    Alignment := vector2{X := 0.5, Y := 1.0},
                    Offsets := margin{Bottom := 50.0},
                    Widget := overlay:
                        Slots := array{
                            overlay_slot:
                                Widget := color_block{
                                    DefaultDesiredSize := vector2{X := 614.0, Y := 30.0},
                                    DefaultColor := color{R := 0.0, G := 0.0, B := 0.0}
                                }
                            overlay_slot:
                                Widget := texture_block{
                                    DefaultImage := UI.SmokeUILimited,
                                    DefaultDesiredSize := vector2{X := 666.0, Y := 63.5}
                                }
                            overlay_slot:
                                Widget := color_block{
                                    DefaultDesiredSize := vector2{X := 0.0, Y := 30.0},
                                    DefaultColor := MakeColorFromSRGBValues(Red := 120, Green := 148, Blue := 118)
                                }
                            overlay_slot:
                                Widget := texture_block{
                                    DefaultImage := UI.Cloud2
                                    DefaultDesiredSize := vector2{X := 50.0, Y := 30.0}
                                    DefaultTint := MakeColorFromSRGBValues(Red := 102, Green := 126, Blue := 100)
                                }
                        }
            }
        return GasCanvas
        
    CreateGasCanvasForPlayer(Player : player):void=
        if (PlayerUI := GetPlayerUI[Player]):
                GasCanvas := MakeGasCanvas()
                PlayerUI.AddWidget(GasCanvas)
                if (set PlayerUIMap[Player] = option{GasCanvas}) {}

    RemoveHUD():void=
        set IsUIShown = false
        Print("Remove hud")
        for (Player : GetPlayspace().GetPlayers()):
            if (PlayerUI := GetPlayerUI[Player], RemoveUI := PlayerUIMap[Player]?):
                PlayerUI.RemoveWidget(RemoveUI)

    ResetHUDBar():void=
        if (IsUIShown = true):
            Print("Reset bar")
            FGBlockIndex := 2
            for (Player : GetPlayspace().GetPlayers()):
                if (GasCanvas := PlayerUIMap[Player]?,
                    Overlay := overlay[GasCanvas.Slots[0].Widget],
                    FGBlock := color_block[Overlay.Slots[FGBlockIndex].Widget]):
                        FGBlock.SetDesiredSize(vector2{X := 0.0, Y := FGBlock.GetDesiredSize().Y})

    UpdatePlayerHUD()<suspends>:void=
        FGBlockIndex := 2
        BGBlockIndex := 0

        var BarFillDuration : float = 5.0
        var LastTime : float = GetSimulationElapsedTime()

        loop:
            if (RZone := ActualSmokeZone?):
                set BarFillDuration = RZone.CreateAfterTime

            CurrentTime := GetSimulationElapsedTime()
            DeltaTime := CurrentTime - LastTime
            set LastTime = CurrentTime

            Sleep(0.0)

            if (IsUIShown = true):
                for (Player : GetPlayspace().GetPlayers()):
                    if (GasCanvas := PlayerUIMap[Player]?,
                        Overlay := overlay[GasCanvas.Slots[0].Widget],
                        FGBlock := color_block[Overlay.Slots[FGBlockIndex].Widget],
                        BGBlock := color_block[Overlay.Slots[BGBlockIndex].Widget]):

                            FGBlockSize := FGBlock.GetDesiredSize()
                            BGBlockSize := BGBlock.GetDesiredSize()

                            TargetRatio := Clamp(Timer.GetActiveDuration() / BarFillDuration, 0.0, 1.0)
                            CurrentRatio := FGBlockSize.X / BGBlockSize.X

                            InterpSpeed := 2.0
                            InterpFactor := Clamp(DeltaTime * InterpSpeed, 0.0, 1.0)
                            NewRatio := CurrentRatio + (TargetRatio - CurrentRatio) * InterpFactor

                            FGBlock.SetDesiredSize(vector2{
                                Y := FGBlockSize.Y,
                                X := BGBlockSize.X * Clamp(NewRatio, 0.0, 1.0)
                            })

    BeginSmokeCycle():void=
        Print("Smoke cycle begun")
        Timer.Enable()
        set ActualSmokeZoneIndex = 0
        IterateSmokeCycle(ActualSmokeZoneIndex)

    RecoverInitiateState():void=
        Print("Recover state begun")
        Timer.Reset()
        Timer.Disable()

        set ActualSmokeZone = false
        set ActualSmokeZoneIndex = 0

        for (SmokeZone : SmokeZones):
            for (Spawner : SmokeZone.VFXSpawners):
                Spawner.Disable()
                Print("Spawner Disabled")
            for (Zone : SmokeZone.DamageZones):
                Zone.Disable()

    IterateSmokeCycle<private>(SmokeZoneIndex : int):void=
        if (SmokeZone := SmokeZones[SmokeZoneIndex]):
            set ActualSmokeZone = option{SmokeZone}
            ResetHUDBar()
            StartTimer(SmokeZone.CreateAfterTime)
            Print("Waiting new smoke zone...")

    IterateSmokeCycleFinished<private>(Agent :? agent):void=
        Print("Smoke zone activating")
        if (RSmokeZone := ActualSmokeZone?):
            for (Spawner : RSmokeZone.VFXSpawners):
                Spawner.Enable()
                Print("Spawner Enabled")
                Spawner.Restart()
            for (Zone : RSmokeZone.DamageZones):
                Zone.Enable()

            if (DisposeVFXSmokeZone := SmokeZones[ActualSmokeZoneIndex - ParallelVFXQuantity]):
                for (Spawner : DisposeVFXSmokeZone.VFXSpawners):
                    Print("Spawner Disabled")
                    Spawner.Disable()

            set ActualSmokeZoneIndex += 1
            GasLeakAudio.Play()
            if (NextSmokeZone := SmokeZones[ActualSmokeZoneIndex]):
                IterateSmokeCycle(ActualSmokeZoneIndex)

    StartTimer<private>(Duration : float):void=
        spawn{StartTimerAwait(Duration)}

    StartTimerAwait<private>(Duration : float)<suspends>:void=
        Print("SmokeTimer started")
        Timer.Reset()
        Sleep(DeviceActivationDelay)
        Timer.SetMaxDuration(Duration - DeviceActivationDelay)
        Timer.SetActiveDuration(Duration - DeviceActivationDelay)
        Timer.Start()