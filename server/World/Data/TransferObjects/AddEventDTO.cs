using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.TransferObjects
{
    public record AddEventDTO(
        long PlayerID,
        short EventType,
        int EventValue,
        int TileX,
        int TileY);
}
