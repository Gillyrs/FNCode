using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

player_data := class<final><persistable>:
    Coins : int = 0
    Complexity : int = 0
    ProvidedBundles : []int = array{}
    QueueIndex : int = -1
    FirstTimeHunter : logic = true
    ClassNumber : int = 7
    Stats : player_stats = player_stats{}

MakePlayerData<constructor>(CoinsArg : int, ComplexityArg : int, ProvidedBundlesArg : []int, QueueIndexArg : int,
FirstTimeHunterArg : logic, ClassNumberArg : int, StatsArg : player_stats) := player_data:
    Coins := CoinsArg
    Complexity := ComplexityArg
    ProvidedBundles := ProvidedBundlesArg
    QueueIndex := QueueIndexArg
    FirstTimeHunter := FirstTimeHunterArg
    ClassNumber := ClassNumberArg
    Stats := StatsArg

MakePlayerData<constructor>(Src : player_data) := player_data:
    Coins := Src.Coins
    Complexity := Src.Complexity
    ProvidedBundles := Src.ProvidedBundles
    QueueIndex := Src.QueueIndex
    FirstTimeHunter := Src.FirstTimeHunter
    ClassNumber := Src.ClassNumber
    Stats := Src.Stats