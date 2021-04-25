using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.TransferObjects
{
    public record PathGetDTO(
        uint PathID,
        uint WorldID,
        uint ZoneID,
        Guid PlayerID,
        DateTimeOffset TimeStamp,
        IList<PathTileDTO> Tiles);
}
