using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { Currency }
using { Persistance }

ToTruncatedString(Value:float, DecimalPlace:int):string =
    StringValue := ToString(Value)
    
    var DecimalIndex : int = -1
    for (Index := 0..StringValue.Length - 1):
        if (Char := StringValue[Index], Char = '.'):
            set DecimalIndex = Index
    
    if (DecimalIndex = -1):
        return StringValue
    
    EndIndex := DecimalIndex + DecimalPlace + 1
    if (EndIndex > StringValue.Length):
        return StringValue

    if (TruncatedString := StringValue.Slice[0, EndIndex]):
        TruncatedString
    else:
        StringValue

HasFractionalPart(Value:float)<transacts><decides>:void =
        if (IntValue := Int[Value]):
            IntValue * 1.0 <> Value

cost_and_value := class():
    @editable
    UpgradeCost : int = 0
    @editable 
    Value : float = 0.0

upgrade_ability<public> := class():
    @editable
    RowMainText : string = ""
    @editable 
    DefaultValue : float = 0.0
    @editable
    var CostAndValues : []cost_and_value = array{}

    ActivateUpgrade(Agent : agent, UpgradeIndex : int):void=
        return

upgrade_maxhealth := class(upgrade_ability):

    ActivateUpgrade<override>(Agent : agent, UpgradeIndex : int):void=
        Print("Upgrade activated, index {UpgradeIndex}")
        if(FortChar := Agent.GetFortCharacter[],
        CostAndValue := CostAndValues[UpgradeIndex]):
            FortChar.SetMaxHealth(CostAndValue.Value)
            Print("Setted max health to {CostAndValue.Value}")

upgrade_maxshield := class(upgrade_ability):

    ActivateUpgrade<override>(Agent : agent, UpgradeIndex : int):void=
        Print("Upgrade activated, index {UpgradeIndex}")
        if(FortChar := Agent.GetFortCharacter[],
        CostAndValue := CostAndValues[UpgradeIndex]):
            FortChar.SetMaxShield(CostAndValue.Value)
            Print("Setted max shield to {CostAndValue.Value}")

upgrade_damage := class(upgrade_ability):

    @editable
    DamageAmplifier : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}

    ActivateUpgrade<override>(Agent : agent, UpgradeIndex : int):void=
        Print("Upgrade activated, index {UpgradeIndex}")
        if(FortChar := Agent.GetFortCharacter[],
        CostAndValue := CostAndValues[UpgradeIndex],
        CostAndValue.Value <> 1.0):
            DamageAmplifier.SetMagnitude(CostAndValue.Value)
            DamageAmplifier.Pickup(Agent)
            Print("Setted damage multiplier to {CostAndValue.Value}")


upgrade_regen := class(upgrade_ability):

    @editable RegenDelay : float = 1.0
    var AgentMap : [agent]float = map{}
    var AgentState : [agent]logic = map{}

    DisposeEvent : event() = event(){}
    UpdateRegenEvent : event(agent) = event(agent){}

    ActivateUpgrade<override>(Agent : agent, UpgradeIndex : int):void=
        Print("Upgrade activated, index {UpgradeIndex}")
        if(CostAndValue := CostAndValues[UpgradeIndex],
        set AgentMap[Agent] = CostAndValue.Value,
        CostAndValue.Value > 0.0):
            if(IsRegenActive := AgentState[Agent]):
                if(IsRegenActive = false):
                    Print("Regen launched")
                    spawn{LaunchRegen(Agent, CostAndValue.Value)}
                else:
                    UpdateRegenEvent.Signal(Agent)
                    Print("Regen value updated")
            else:
                if(set AgentState[Agent] = true):
                    Print("Regen launched 1")
                    spawn{LaunchRegen(Agent, CostAndValue.Value)}

            

    LaunchRegen(Agent : agent, RegenValue : float)<suspends>:void=
        if(FortChar := Agent.GetFortCharacter[]):
            race:
                block:
                    loop:
                        Sleep(RegenDelay)
                        RegenAction(FortChar, RegenValue)
                block:
                    UpdatedAgent := UpdateRegenEvent.Await()
                    if(UpdatedAgent = Agent,
                    NewRegenValue := AgentMap[UpdatedAgent]):
                        Print("Launched new regen thread")
                        spawn{LaunchRegen(Agent, NewRegenValue)}
                block:
                    DisposeEvent.Await()

    RegenAction(FortChar : fort_character, RegenValue : float):void=
        ()

upgrade_healthregen := class(upgrade_regen):

    RegenAction<override>(FortChar : fort_character, RegenValue : float):void=
        FortChar.Heal(RegenValue)

upgrade_shieldregen := class(upgrade_regen):

    RegenAction<override>(FortChar : fort_character, RegenValue : float):void=
        PastShield := FortChar.GetShield()
        NewShield := PastShield + RegenValue
        FortChar.SetShield(NewShield)



upgrade_abilities_device := class(creative_device):

    @editable
    var UpgradesAbilities : []upgrade_ability = array{}
    @editable
    PersistanceDevice : persistance_device = persistance_device{}
    @editable
    CurrencyBuilder : currency_builder_device = currency_builder_device{}
    @editable
    Button : button_device = button_device{}

    var WidgetMap : [player]canvas = map{}
    
    OnRowUpgradeEvent : event(int) = event(int){}
    OnDisposeEvent : event() = event(){}

    SetDynamicText<localizes>(value:string) : message="{value}"

    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(OnBuildUI)
        PersistanceDevice.Init(CurrencyBuilder, Self)
        NewUpgradeAbilities : []upgrade_ability = array{}

        for(Ability : UpgradesAbilities):
            var NewCostAndValue : []cost_and_value = array{}
            set NewCostAndValue += array{cost_and_value{ Value := Ability.DefaultValue, UpgradeCost := 0}}
            for(CostAndValue : Ability.CostAndValues):
                set NewCostAndValue += array{CostAndValue}
            set Ability.CostAndValues = NewCostAndValue
            Print("{Ability.CostAndValues.Length}")

        for(Player : GetPlayspace().GetPlayers()):
            InitUpgrades(Player)
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)

    OnPlayerAdded(Player : player):void=
        InitUpgrades(Player)

    InitUpgrades(Agent : agent):void=
        if(Player := player[Agent],
        PlayerRows := PlayerData[Player].Rows):
            for(X -> Row : PlayerRows):
                if(Ability := UpgradesAbilities[X]):
                    Ability.ActivateUpgrade(Agent, Row)

    CreateDifText(Float1 : float, Float2 : float):string=
        var NewDifText : string = ""
        var RoundedOld : string = ""
        var RoundedNew : string = ""
        if(HasFractionalPart[Float1]):
            set RoundedOld = ToTruncatedString(Float1, 1)
        else if(Rounded := Round[Float1]):
            set RoundedOld = "{Rounded}"
            Print("Rounded {Float1}")

        if(HasFractionalPart[Float2]):  
            set RoundedNew = ToTruncatedString(Float2, 1)
        else if(Rounded := Round[Float2]):
            set RoundedNew = "{Rounded}"
            Print("Rounded {Float2}")

        set NewDifText = "{RoundedOld}->{RoundedNew}"

        return NewDifText

    CreateDifTextSingle(Float1 : float):string=
        var NewDifText : string = ""
        if(HasFractionalPart[Float1]):
            RoundedOld := ToTruncatedString(Float1, 1)

            set NewDifText = "{RoundedOld}"
            Print("Has fractional part")
        else if(RoundedOld := Round[Float1]):
            set NewDifText = "{RoundedOld}"
            Print("Has no fractional part")

        return NewDifText

    SetupStatRowsFromData(Player : player, RowsData : []int):[]canvas=
        var Rows : []canvas = array{}
        for(X -> Row : RowsData):
                        if(UpgradeData := UpgradesAbilities[X]
                        RowLevel := RowsData[X],
                        PresentValue := UpgradeData.CostAndValues[RowLevel].Value):
                            if(CostNextLevel := UpgradeData.CostAndValues[RowLevel + 1].UpgradeCost,
                            NextValue := UpgradeData.CostAndValues[RowLevel + 1].Value):
                                var NewDifText : string = ""
                                set NewDifText = CreateDifText(PresentValue, NextValue)

                                set Rows += array{CreateStatRow(Player, X, UpgradeData.RowMainText, 
                                "LVL {RowLevel}", NewDifText, "{CostNextLevel}")}
                            else:
                                var NewDifText : string = ""
                                set NewDifText = CreateDifTextSingle(PresentValue)

                                set Rows += array{CreateStatRow(Player, X, UpgradeData.RowMainText, 
                                "LVL MAX", NewDifText, "MAX")}
        return Rows

    OnBuildUI(Agent : agent):void=
        if(Player := player[Agent],
        PlayerUI := GetPlayerUI[Player]):
            if(PlayerWidget := WidgetMap[Player]):
                PlayerUI.AddWidget(PlayerWidget, player_ui_slot{InputMode := ui_input_mode.All})
                Print("Added existing widget")
            else:
                Print("NO existing widget, creating one")
                var Rows : []canvas = array{}
                if(RowsData := PlayerData[Player].Rows):
                    set Rows = SetupStatRowsFromData(Player, RowsData)
                    Print("There are existing data")
                    
                else:
                    Print("There are not existing data")
                    DefData := PersistanceDevice.MakeDefaultPlayerData(CurrencyBuilder, Self)
                    if(set PlayerData[Player] = DefData,
                    RowsData := DefData.Rows):     
                        set Rows = SetupStatRowsFromData(Player, RowsData)

                Widget := CombineRows(Player, Rows)
                Print("Combining rows")
                if(set WidgetMap[Player] = Widget):
                    PlayerUI.AddWidget(Widget, player_ui_slot{InputMode := ui_input_mode.All})

    OnRowUpdate(Player : player, RowIndex : int, NewMainText : string, NewLvltext : string, NewDifText : string, NewBuyButtonText : string):void=

        if(PlayerUI := GetPlayerUI[Player],
        PlayerWidget := WidgetMap[Player],
        RowCanvas := canvas[stack_box[PlayerWidget.Slots[0].Widget].Slots[RowIndex].Widget],
        MainText := text_block[RowCanvas.Slots[3].Widget],
        LvlText := text_block[RowCanvas.Slots[2].Widget],
        DifText := text_block[RowCanvas.Slots[1].Widget],
        BuyButton := button_loud[RowCanvas.Slots[0].Widget]):
            MainText.SetText(SetDynamicText(NewMainText))
            LvlText.SetText(SetDynamicText(NewLvltext))
            DifText.SetText(SetDynamicText(NewDifText))
            BuyButton.SetText(SetDynamicText(NewBuyButtonText))
            Print("Row visual updated")
    
    TryUpgradeRow(Player : player, RowIndex : int):void=
        Print("RowIndex {RowIndex}")

        if(PData := PlayerData[Player],
        Ability := UpgradesAbilities[RowIndex],
        CurrentMoney := PData.CurrencyMap[currency_type.Money],
        CurrentRowLevel := PData.Rows[RowIndex],
        UpgradeCostAndValue := Ability.CostAndValues[CurrentRowLevel + 1],
        CurrentMoney >= UpgradeCostAndValue.UpgradeCost):
            Print("Current money: {CurrentMoney}, CurrentRowLevel: {CurrentRowLevel} BuyingCost: {UpgradeCostAndValue.UpgradeCost}, BuyingValue: {UpgradeCostAndValue.Value}")
            Ability.ActivateUpgrade(Player, CurrentRowLevel + 1)
            PersistanceDevice.TryWithdraw(Player, currency_type.Money, UpgradeCostAndValue.UpgradeCost)
            var NewLevelText : string = ""
            var NewDifText : string = ""
            var NewBuyButtonText : string = ""
            if( NewCostAndValue := Ability.CostAndValues[CurrentRowLevel + 2]):
                set NewLevelText = "LVL {CurrentRowLevel + 1}"
                set NewDifText = CreateDifText(UpgradeCostAndValue.Value, NewCostAndValue.Value)

                set NewBuyButtonText = "{NewCostAndValue.UpgradeCost}"
            else:
                set NewLevelText = "LVL MAX"
                set NewDifText = CreateDifTextSingle(UpgradeCostAndValue.Value)
                set NewBuyButtonText = "MAX"
            Print("Row upgraded, updating row visual")
            PersistanceDevice.TryUpdateRowLevel(Player, RowIndex)
            OnRowUpdate(Player, RowIndex, Ability.RowMainText, NewLevelText, NewDifText, NewBuyButtonText)
            
    
    AwaitWidgetRemove(Player : player, AwaitEvent : listenable(widget_message), WidgetToRemove : widget)<suspends>:void=
        Print("Awaiting button close")
        race:
            block:
                loop:
                    AwaitEvent.Await()
                    Print("Clicked")
                    if(PlayerUI := GetPlayerUI[Player]):
                        PlayerUI.RemoveWidget(WidgetToRemove)
                        Print("Removed widget")
            block:
                OnDisposeEvent.Await()

    CombineRows(Player : player, Rows : []canvas):canvas=
        var MainCanvas : canvas = canvas{}
        var StackBox: stack_box = stack_box{Orientation := orientation.Vertical}
        var BG: color_block = color_block{}
        var CloseButton : button_quiet = button_quiet{}
        set BG = color_block:
            DefaultColor := color{R := 0.0, G := 0.0, B := 0.0}
            DefaultOpacity := 0.784348

        set CloseButton = button_quiet:
            DefaultText := SetDynamicText("X")

        var AddSlots : []stack_box_slot = array{}
        for(Row : Rows):
            NewStackBox := stack_box_slot:
                HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment := vertical_alignment.Fill
                        Widget := Row
                        Padding := margin:
                            Top := 40.0
            set AddSlots += array{NewStackBox}  
            Print("Added in stackbox widget")

        set StackBox = stack_box:
                Orientation := orientation.Vertical
                Slots := AddSlots

        set MainCanvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin:
                        Left := -755.315308
                        Top := -440.864868
                        Right := 1570.270264
                        Bottom := 904.864868
                    SizeToContent := false
                    Widget := StackBox
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin:
                        Left := -763.963928
                        Top := -444.444427
                        Right := 1577.477539
                        Bottom := 908.868896
                    SizeToContent := false
                    Widget := BG
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin:
                        Left := -728.960938
                        Top := -416.540527
                        Right := 85.947815
                        Bottom := 84.828827
                    SizeToContent := false
                    Widget := CloseButton
                
        spawn{AwaitWidgetRemove(Player, CloseButton.OnClick(), MainCanvas)}

        return MainCanvas

    OnButtonClicked(ButtonLoud : button_loud, Player : player, RowIndex : int)<suspends>:void=
        race:
            block:
                ButtonLoud.OnClick().Await()
                Print("Button clicked, trying to upgrade row")
                TryUpgradeRow(Player, RowIndex)       
                OnButtonClicked(ButtonLoud, Player, RowIndex)
            block:
                OnDisposeEvent.Await()

    CreateStatRow(Player : player, RowIndex : int, RowMainStr : string, RowLvlStr : string, RowDifStr : string, BuyButtonStr : string) : canvas =
        var RowCanvas : canvas = canvas{}

        var RowMainText : text_block = text_block{}
        var RowLvlText: text_block = text_block{}
        var RowDifText: text_block = text_block{}
        var BuyButton: button_loud = button_loud{}


        set RowMainText  = text_block:
            DefaultText := SetDynamicText(RowMainStr)
            DefaultTextColor := color{R := 0.994792, G := 0.02156, B := 0.0}
            DefaultTextOpacity := 1.0
            DefaultTextSize := 39.75
        set RowLvlText = text_block:
            DefaultText := SetDynamicText(RowLvlStr)
            DefaultTextColor := NamedColors.White
            DefaultTextOpacity := 1.0
            DefaultTextSize := 39.75
        set RowDifText = text_block:
            DefaultText := SetDynamicText(RowDifStr)
            DefaultTextColor := NamedColors.White
            DefaultTextOpacity := 1.0
            DefaultTextSize := 39.75
        set BuyButton = button_loud:
            DefaultText := SetDynamicText(BuyButtonStr)

        spawn{OnButtonClicked(BuyButton, Player, RowIndex)}
        set RowCanvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin:
                        Left := 408.29425
                        Top := -34.255249
                        Right := 278.978973
                        Bottom := 74.834839
                    SizeToContent := false
                    Widget := BuyButton
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin:
                        Left := 92.29425
                        Top := -38.255249
                        Right := 295.530518
                        Bottom := 65.024025
                    SizeToContent := false
                    Widget := RowDifText
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin:
                        Left := -183.70575
                        Top := -38.255249
                        Right := 168.203186
                        Bottom := 65.024025
                    SizeToContent := false
                    Widget := RowLvlText
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.5}
                        Maximum := vector2{X := 0.5, Y := 0.5}
                    Offsets := margin:
                        Left := -651.70575
                        Top := -30.255249
                        Right := 315.550537
                        Bottom := 65.024025
                    SizeToContent := false
                    Widget := RowMainText
        return RowCanvas

        