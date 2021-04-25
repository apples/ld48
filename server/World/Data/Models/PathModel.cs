using System;
using System.Collections.Generic;

namespace World.Data.Models
{
    public class PathModel
    {
        public uint PathID { get; set; }
        public uint WorldID { get; set; }
        public uint ZoneID { get; set; }
        public Guid PlayerID { get; set; }
        public uint Day { get; set; }
        public DateTime TimeStamp { get; set; }
        public IList<PathTileModel> Tiles { get; set; }
    }
}
