
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }

level_bundle := class<concrete>:

    #ADD ANY DATA YOU WANT. IT WILL BE BROUGHT TO level_ui_builder.BuildUI() AND level_builder.ActivateBundle()
    @editable ItemsProvide :? item_granter_device = false
    @editable ItemsQuantity :? int = false
    @editable ClassInt :? int = false
    @editable Texture :? texture = false
    @editable MainText : string = ""
    @editable MainTextColor : color_definition = color_definition{}
    @editable DescriptionText : string = ""
    @editable DescriptionTextColor : color_definition = color_definition{}

    AreLevelBundlesEqual(A:level_bundle, B:level_bundle)<decides><transacts>:void=
        # Compare ItemsProvide (optional item_granter_device)
        if (A.ItemsProvide? and B.ItemsProvide?):
            # Both present, treat as equal
            true
        else if (not A.ItemsProvide? and not B.ItemsProvide?):
            # Both absent, treat as equal
            true
        else:
            false?
    
        # Compare ItemsQuantity (optional int)
        if (A.ItemsQuantity? and B.ItemsQuantity?):
            if (A.ItemsQuantity? <> B.ItemsQuantity?):
                false?
        else if (not A.ItemsQuantity? and not B.ItemsQuantity?):
            true
        else:
            false?
    
        # Compare ClassInt (optional int)
        if (A.ClassInt? and B.ClassInt?):
            if (A.ClassInt? <> B.ClassInt?):
                false?
        else if (not A.ClassInt? and not B.ClassInt?):
            true
        else:
            false?
    
        # Compare Texture (optional texture)
        if (A.Texture? and B.Texture?):
            # Both present, treat as equal
            true
        else if (not A.Texture? and not B.Texture?):
            true
        else:
            false?
    
        # Compare MainText (string)
        if (A.MainText <> B.MainText):
            false?
    
    
        # Compare DescriptionText (string)
        if (A.DescriptionText <> B.DescriptionText):
            false?
    
 
(Array : []level_bundle).FindLevelBundleIndex(Target:level_bundle):int =
    for (Index -> Bundle : Array):
        if (Bundle.AreLevelBundlesEqual[Bundle, Target]):
            return Index
    -1

color_definition := class<concrete>:
    @editable HEXString : string = "FFFFFFFF"

    MakeColorFromDefinition():color=
        MakeColorFromHex(HEXString)
