using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.Models
{
    public class EventModel
    {
        public long EventID { get; set; }
        public long PlayerID { get; set; }
        public short EventType { get; set; }
        public int EventValue { get; set; }
        public int TileX { get; set; }
        public int TileY { get; set; }
        public DateTime TimeStamp { get; set; }
    }
}
