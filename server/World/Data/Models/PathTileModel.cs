using System;

namespace World.Data.Models
{
    public class PathTileModel
    {
        public long PathID { get; set; }
        public long TileID { get; set; }
        public int TileX { get; set; }
        public int TileY { get; set; }
        // TimeStamp since start of day
        public float TimeStamp { get; set; }
        public PathModel Path { get; set; }
    }
}
