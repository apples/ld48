using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.TransferObjects
{
    public record EndDayDTO(
        uint WorldID,
        uint ZoneID,
        Guid PlayerID,
        uint Day);
}
