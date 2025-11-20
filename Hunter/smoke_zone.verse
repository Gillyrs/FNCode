
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

smoke_zone := class<concrete>:
    @editable VFXSpawners : []vfx_spawner_device = array{}
    @editable DamageZones : []damage_volume_device = array{}
    @editable CreateAfterTime : float = 0.0