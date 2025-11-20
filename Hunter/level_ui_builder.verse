using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }

level_ui_builder := class<concrete>:

    var MaybeMyUIPerPlayer : [player]?canvas = map{}

    var Subs : []cancelable = array{}
    var Buttons : []button_loud = array{}

    var LevelBuilder :? level_builder = false

    SetDynamicText<localizes>(value:string) : message="{value}"

    BuildUI(Bundles : []level_bundle, Player : player):void=

        #EXAMPLE HOW SPAGETTI-CODE DRAWS UI
        if(PlayerUI := GetPlayerUI[Player]):

            ButtonText : message = SetDynamicText("Accept")

            Button1 := button_loud{DefaultText := ButtonText}
            Button2 := button_loud{DefaultText := ButtonText}

            set Buttons = array{ Button1, Button2}
            
            #You should use add sub when you subscribe on button events.
            #These subs will be automatically canceled after OnButtonPressed will be called
            AddSub(Button1.OnClick().Subscribe(OnButtonPressed))
            AddSub(Button2.OnClick().Subscribe(OnButtonPressed))


            var MainOverlay : canvas = canvas{}
            
            var Bundle1 : level_bundle = level_bundle{}
            var Bundle2 : level_bundle = level_bundle{}

            if(UnpackedBandle1 := Bundles[0], UnpackedBandle2 := Bundles[1],
            set Bundle1 = UnpackedBandle1, set Bundle2 = UnpackedBandle2){}

            var Bundle1Widget : canvas = canvas{}
            var Bundle2Widget : canvas = canvas{}

            
            #Edit this bundle, test and apply changes to others
            if(Texture1 := Bundle1.Texture?):
                Image :texture_block = texture_block{
                    DefaultImage := Texture1
                    DefaultDesiredSize := vector2{X:= 200.0, Y := 200.0}  
                }
                Background := color_block{
                    DefaultColor := color{R := 0.0, G := 0.0, B := 0.0}
                    DefaultOpacity := 0.5
                    DefaultDesiredSize := vector2{X:= 490.0, Y := 675.0}  
                }
                MainText := text_block{
                    DefaultText := SetDynamicText("{Bundle1.MainText}")
                    DefaultTextColor := Bundle1.MainTextColor.MakeColorFromDefinition()
                    DefaultShadowOffset := option{vector2{X:= 3.0, Y := 3.0}}
                    DefaultShadowOpacity := 1.0
                    DefaultShadowColor := color{R := 0.0, G := 0.0, B := 0.0}
                    DefaultJustification := text_justification.Center 
                }
                DescriptionText := text_block{
                    DefaultText := SetDynamicText("{Bundle1.DescriptionText}")
                    DefaultTextColor := Bundle1.DescriptionTextColor.MakeColorFromDefinition()
                    DefaultJustification := text_justification.Center
                }
                CanvasSlots:=array:
                        canvas_slot:
                            Widget := Button1
                            Offsets := margin{Left := -129.0, Top := 182.5}
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 2
                        canvas_slot:
                            Widget := Image
                            Offsets := margin{Left := -105.0, Top := -237.5}
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 2
                        canvas_slot:
                            Widget := Background
                            Offsets := margin{Left := -245.0, Top := -337.5}
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 1
                        canvas_slot:
                            Widget := MainText
                            Offsets := margin{Left := -5.0, Top := -297.5}      
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 2
                            SizeToContent := false
                        canvas_slot:
                            Widget := DescriptionText
                            Offsets := margin{Left := -1.0, Top := -33.5}    
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 2
                            SizeToContent := false
                set Bundle1Widget = canvas:
                    Slots := CanvasSlots

                if(Quantity := Bundle1.ItemsQuantity?):
                    QuantityText := text_block{
                        DefaultText := SetDynamicText("x{Quantity}")
                        DefaultTextColor := MakeColorFromHex("#FFFFFF")
                    }
                    NewSlots := CanvasSlots + array{
                        canvas_slot:
                            Widget := QuantityText
                            Offsets := margin{Left := 29.0, Top := -85.5}    
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 3
                    }
                    set Bundle1Widget = canvas:
                        Slots := NewSlots
            if(Texture2 := Bundle2.Texture?):
                Image :texture_block = texture_block{
                    DefaultImage := Texture2
                    DefaultDesiredSize := vector2{X:= 200.0, Y := 200.0}  
                }
                Background := color_block{
                    DefaultColor := color{R := 0.0, G := 0.0, B := 0.0}
                    DefaultOpacity := 0.5
                    DefaultDesiredSize := vector2{X:= 490.0, Y := 675.0}  
                }
                MainText := text_block{
                    DefaultText := SetDynamicText("{Bundle2.MainText}")
                    DefaultTextColor := Bundle2.MainTextColor.MakeColorFromDefinition()
                    DefaultShadowOffset := option{vector2{X:= 3.0, Y := 3.0}}
                    DefaultShadowOpacity := 1.0
                    DefaultShadowColor := color{R := 0.0, G := 0.0, B := 0.0}
                    DefaultJustification := text_justification.Center 
                }
                DescriptionText := text_block{
                    DefaultText := SetDynamicText("{Bundle2.DescriptionText}")
                    DefaultTextColor := Bundle2.DescriptionTextColor.MakeColorFromDefinition()
                    DefaultJustification := text_justification.Center
                }
                CanvasSlots:=array:
                        canvas_slot:
                            Widget := Button2
                            Offsets := margin{Left := -129.0, Top := 182.5}
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 2
                        canvas_slot:
                            Widget := Image
                            Offsets := margin{Left := -105.0, Top := -237.5}
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 2
                        canvas_slot:
                            Widget := Background
                            Offsets := margin{Left := -245.0, Top := -337.5}
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 1
                        canvas_slot:
                            Widget := MainText
                            Offsets := margin{Left := -5.0, Top := -297.5}    
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 2
                            SizeToContent := false
                        canvas_slot:
                            Widget := DescriptionText
                            Offsets := margin{Left := -1.0, Top := -33.5}    
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 2
                            SizeToContent := false
                set Bundle2Widget = canvas:
                    Slots := CanvasSlots

                if(Quantity := Bundle2.ItemsQuantity?):
                    QuantityText := text_block{
                        DefaultText := SetDynamicText("x{Quantity}")
                        DefaultTextColor := MakeColorFromHex("#FFFFFF")
                    }
                    NewSlots := CanvasSlots + array{
                        canvas_slot:
                            Widget := QuantityText
                            Offsets := margin{Left := 29.0, Top := -85.5}    
                            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                            ZOrder := 3
                    }
                    set Bundle2Widget = canvas:
                        Slots := NewSlots
            
            #Main overlay, where you add your bundle widgets and place it where you need
            CloseButton := button_quiet: 
                DefaultText := SetDynamicText("CLOSE")

            AddSub(CloseButton.OnClick().Subscribe(OnCloseButtonPressed))

            set MainOverlay = canvas:
                Slots:=array:
                    canvas_slot:
                        Widget := Bundle1Widget
                        Offsets := margin{Left := -525.0, Top := -365.0}
                        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    canvas_slot:
                        Widget := Bundle2Widget
                        Offsets := margin{Left := 45.0, Top := -365.0}
                        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    canvas_slot:
                        Widget := CloseButton
                        Offsets := margin{Left := 92.0, Top := 72.0}
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}

            
            #DO NOT DELETE, but modify if needed. Always put all UI in Main overlay and add it through AddWidget
            PlayerUI.AddWidget(MainOverlay, player_ui_slot{InputMode := ui_input_mode.All})
            if(set MaybeMyUIPerPlayer[Player] = option{MainOverlay}){Print("LevelUI Built")}
        return

    CloseUI(Player : player):void=
       if(PlayerUI := GetPlayerUI[Player], MyUI := MaybeMyUIPerPlayer[Player]?):
            PlayerUI.RemoveWidget(MyUI)
            DisposeSubs()
            if(set MaybeMyUIPerPlayer[Player] = false){}
        return

    OnCloseButtonPressed(Message : widget_message):void=
        if(PlayerUI := GetPlayerUI[Message.Player], MyUI := MaybeMyUIPerPlayer[Message.Player]?):
            PlayerUI.RemoveWidget(MyUI)
            DisposeSubs()
            if(set MaybeMyUIPerPlayer[Message.Player] = false){}
        return

    OnButtonPressed(Message : widget_message):void=
        if(PlayerUI := GetPlayerUI[Message.Player], MyUI := MaybeMyUIPerPlayer[Message.Player]?):
            PlayerUI.RemoveWidget(MyUI)
            DisposeSubs()
            if(RLBuilder := LevelBuilder?):
                for(X := 0..Buttons.Length - 1):
                    if(Buttons[X] = Message.Source):
                        RLBuilder.HandleButtonPressed(X, Message.Player)
            if(set MaybeMyUIPerPlayer[Message.Player] = false){}
        return

    AddSub(Sub : cancelable):void=
        set Subs += array{Sub}

    DisposeSubs():void=
        for(Sub : Subs):
            Sub.Cancel()