using System;

namespace World.Data.Models
{
    public class PathTileModel
    {
        public uint PathID { get; set; }
        public uint TileID { get; set; }
        public uint TileX { get; set; }
        public uint TileY { get; set; }
        // TimeStamp since start of day
        public float TimeStamp { get; set; }
        public PathModel Path { get; set; }
    }
}
