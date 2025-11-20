
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }

spawn_device := class(creative_device):

    @editable HealthApplier : health_powerup_device = health_powerup_device{}
    @editable SpectatorDevice : spectator_device = spectator_device{}

    @editable Team1SpawnPads : []player_spawner_device = array{}
    @editable Team3SpawnPads : []player_spawner_device = array{}
    @editable HunterAppearPosition : creative_prop = creative_prop{}
    

    var FreeSpawnPadsTeam1 : []player_spawner_device = array{}
    var FreeSpawnPadsTeam3 : []player_spawner_device = array{}

    OnBegin<override>()<suspends>:void=
        set  FreeSpawnPadsTeam1 = Team1SpawnPads
        set  FreeSpawnPadsTeam3 = Team3SpawnPads

    TeleportAllRoundStart(?Heal : logic = false):void=
        var TempArr : []player_spawner_device = array{}
        set TempArr = TempArr + Team1SpawnPads

        SpectatorDevice.RemoveAllAffilations()
        Players := GetPlayspace().GetParticipants()
        for(i -> Spawner : TempArr):
            Transform := Spawner.GetTransform()
            if(Player := Players[i],
            FortChar := Player.GetFortCharacter[],
                    FortChar.TeleportTo[Transform.Translation + vector3{X:=0.0, Y:=0.0, Z:=200.0}, Transform.Rotation]):
                        if(Heal = true):
                            HealthApplier.Pickup(Player)
    
    TeleportAllLobby(?Heal : logic = false):void=
        var TempArr : []player_spawner_device = array{}
        set TempArr = TempArr + Team3SpawnPads

        SpectatorDevice.RemoveAllAffilations()
        Players := GetPlayspace().GetParticipants()
        for(i -> Spawner : TempArr):
            Transform := Spawner.GetTransform()
            if(Player := Players[i],
                FortChar := Player.GetFortCharacter[],
                    FortChar.TeleportTo[Transform.Translation + vector3{X:=0.0, Y:=0.0, Z:=200.0}, Transform.Rotation]):
                        Print("Teleporting all loby2")
                        if(Heal = true):
                            HealthApplier.Pickup(Player)
                
    TeleportToHunter(Player : agent, ?Heal : logic = false):void=
        if(FortChar := Player.GetFortCharacter[],
        Transform := HunterAppearPosition.GetTransform(),
        FortChar.TeleportTo[Transform.Translation, Transform.Rotation]):
            if(Heal = true):
                HealthApplier.Pickup(Player)

    TeleportToRunners(Player : agent, ?Heal : logic = false):void=
            if(FortChar := Player.GetFortCharacter[],
            Transform := Team1SpawnPads[GetRandomInt(0, Team1SpawnPads.Length - 1)].GetTransform(),
            FortChar.TeleportTo[Transform.Translation, Transform.Rotation]):
                SpectatorDevice.RemoveSpectatorAffilation(Player)
                if(Heal = true):
                    HealthApplier.Pickup(Player)
                return
        

    TeleportToLobby(Player : agent, ?Heal : logic = false):void=
        for(Index -> SpawnPad : FreeSpawnPadsTeam3):
            if(FortChar := Player.GetFortCharacter[],
            Transform := FreeSpawnPadsTeam3[Index].GetTransform(),
            FortChar.TeleportTo[Transform.Translation, Transform.Rotation],
            NewArray := FreeSpawnPadsTeam3.RemoveElement[Index]):
                set FreeSpawnPadsTeam3 = NewArray
                SpectatorDevice.RemoveSpectatorAffilation(Player)
                if(Heal = true):
                    HealthApplier.Pickup(Player)
                return
            
            

        

        
