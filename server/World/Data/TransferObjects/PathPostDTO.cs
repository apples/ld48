﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.TransferObjects
{
    public record PathPostDTO(
        uint WorldID,
        uint ZoneID,
        long PlayerID,
        uint Day,
        IList<PathTileDTO> Tiles);
}
