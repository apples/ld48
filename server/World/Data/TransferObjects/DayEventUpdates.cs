using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.TransferObjects
{
    public record DayEventUpdates(
        uint TileX,
        uint TileY,
        uint EventType,
        int EventValue);
}
