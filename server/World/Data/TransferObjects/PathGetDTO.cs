using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.TransferObjects
{
    public record PathGetDTO(
        long PathID,
        short WorldID,
        short ZoneID,
        long PlayerID,
        short Day,
        DateTime TimeStamp,
        IList<PathTileDTO> Tiles);
}
