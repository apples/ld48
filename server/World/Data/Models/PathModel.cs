using System;
using System.Collections.Generic;

namespace World.Data.Models
{
    public class PathModel
    {
        public long PathID { get; set; }
        public short WorldID { get; set; }
        public short ZoneID { get; set; }
        public long PlayerID { get; set; }
        public short Day { get; set; }
        public DateTime TimeStamp { get; set; }
        public IList<PathTileModel> Tiles { get; set; }
        public PlayerModel Player { get; set; }
    }
}
