using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using World.Serializers;

namespace World.Data.TransferObjects
{
    [JsonConverter(typeof(DayEventUpdateDTOConverter))]
    public record DayEventUpdateDTO(
        int TileX,
        int TileY,
        short EventType,
        int EventValue);
}
