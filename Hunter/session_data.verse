using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

session_data := class<final><persistable>:
    ProvidedQueueIndex : int = 0
    IsRandomChoice : logic = false

MakeSessionData<constructor>(Src : session_data):=session_data:
    ProvidedQueueIndex := Src.ProvidedQueueIndex
    IsRandomChoice := Src.IsRandomChoice