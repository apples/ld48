using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.TransferObjects
{
    public record NewPlayerDTO(
        long PlayerID,
        string Name);
}
