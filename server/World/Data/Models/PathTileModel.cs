using System;

namespace World.Data.Models
{
    public class PathTileModel
    {
        public uint PathID { get; set; }
        public uint TileID { get; set; }
        public int TileX { get; set; }
        public int TileY { get; set; }
        public DateTimeOffset TimeStamp { get; set; }
        public PathModel Path { get; set; }
    }
}
