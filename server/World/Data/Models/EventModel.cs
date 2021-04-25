using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.Models
{
    public class EventModel
    {
        public uint EventID { get; set; }
        public long PlayerID { get; set; }
        public uint EventType { get; set; }
        public int EventValue { get; set; }
        public uint TileX { get; set; }
        public uint TileY { get; set; }
        public DateTime TimeStamp { get; set; }
    }
}
