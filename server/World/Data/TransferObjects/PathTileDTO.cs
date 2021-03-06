using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using World.Serializers;

namespace World.Data.TransferObjects
{
    [JsonConverter(typeof(PathTileDTOConverter))]
    public record PathTileDTO(
        int TileX,
        int TileY,
        float TimeStamp);
}
