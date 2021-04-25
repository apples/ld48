using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.TransferObjects
{
    public record AddEventDTO(
        long PlayerID,
        uint EventType,
        int EventValue,
        uint TileX,
        uint TileY);
}
