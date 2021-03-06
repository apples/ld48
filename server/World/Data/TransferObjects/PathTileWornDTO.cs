using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Text.Json.Serialization;
using World.Serializers;

namespace World.Data.TransferObjects
{
    [JsonConverter(typeof(PathTileWornDTOConverter))]
    public record PathTileWornDTO(
        int X,
        int Y,
        int WornLevel);
}
