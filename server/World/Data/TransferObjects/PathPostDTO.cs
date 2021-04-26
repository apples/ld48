using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.TransferObjects
{
    public record PathPostDTO(
        short WorldID,
        short ZoneID,
        long PlayerID,
        short Day,
        IList<PathTileDTO> Tiles);
}
