using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/UI }
 
player_stats<public> := class<final><persistable>:
    RunnerWins : int = 0
    HunterWins : int = 0

MakePlayerStats<constructor>(Src : player_stats):=player_stats:
    RunnerWins := Src.RunnerWins
    HunterWins := Src.HunterWins

stats_device := class(creative_device):
    
    @editable HunterWins : billboard_device = billboard_device{}
    @editable RunnerWins : billboard_device = billboard_device{}
    @editable UpdateButton : button_device = button_device{}
    @editable Reference : player_reference_device = player_reference_device{}
    @editable Sound : audio_player_device = audio_player_device{}

    SetDynamicText<localizes>(value:string) : message="{value}"

    OnBegin<override>()<suspends>:void=
        UpdateButton.InteractedWithEvent.Subscribe(OnStatsUpdate)

    OnStatsUpdate(Agent : agent):void=
        if(Player := player[Agent],
        Stats := SavedPlayerData[Player].Stats):
            HunterWins.SetText(SetDynamicText("{Stats.HunterWins}"))
            RunnerWins.SetText(SetDynamicText("{Stats.RunnerWins}"))
            Reference.Register(Player)
            Sound.Play()
            Print("Audio played")

    RunnerWin(Player : player):void=
        if(PlayerData := SavedPlayerData[Player]):
            NewStats := player_stats:
                RunnerWins := PlayerData.Stats.RunnerWins + 1
                    MakePlayerStats<constructor>(PlayerData.Stats)
                    
            NewPlayerData := player_data:
                Stats := NewStats
                MakePlayerData<constructor>(PlayerData)
                
            SetPlayerData(Player, NewPlayerData)
                
    HunterWin(Player : player):void=
        if(PlayerData := SavedPlayerData[Player]):
            NewStats := player_stats:
                HunterWins := PlayerData.Stats.HunterWins + 1
                    MakePlayerStats<constructor>(PlayerData.Stats)
                    
            NewPlayerData := player_data:
                Stats := NewStats
                MakePlayerData<constructor>(PlayerData)
                
            SetPlayerData(Player, NewPlayerData)
                
