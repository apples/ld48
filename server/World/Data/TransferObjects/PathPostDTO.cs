using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.TransferObjects
{
    public record PathPostDTO(
        uint WorldID,
        uint ZoneID,
        Guid PlayerID,
        IList<PathTilePostDTO> Tiles);
}
