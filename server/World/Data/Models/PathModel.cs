using System;
using System.Collections.Generic;

namespace World.Data.Models
{
    public class PathModel
    {
        public uint PathID { get; set; }
        public uint WorldID { get; set; }
        public uint ZoneID { get; set; }
        public long PlayerID { get; set; }
        public uint Day { get; set; }
        public DateTimeOffset TimeStamp { get; set; }
        public IList<PathTileModel> Tiles { get; set; }
        public PlayerModel Player { get; set; }
    }
}
