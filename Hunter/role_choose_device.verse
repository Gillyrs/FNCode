
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }

role_choose_device := class(creative_device):

    @editable PopUpRunner : popup_dialog_device = popup_dialog_device{}
    @editable PopUpHunter : popup_dialog_device = popup_dialog_device{}

    CompleteRoleChooseProcess() :? agent =
        Players := GetPlayspace().GetPlayers()
        PopUpRunner.ShownEvent.Subscribe(OnShowed)
        PlayerIndex := GetRandomInt(0, Players.Length - 1)
        if(Player := Players[PlayerIndex], PopUpRunner, PopUpHunter):
            Print("Showing")
            for(PlayerN : Players):
                PopUpRunner.Show(PlayerN)
            PopUpRunner.Hide(Player)   
            PopUpHunter.Show(Player)
            Print("Showed")
            return option{Player}

        return false
         
    OnShowed(Agent : agent):void=
        Print("RURA")