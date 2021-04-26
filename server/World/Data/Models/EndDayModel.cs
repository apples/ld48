using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.Models
{
    public class EndDayModel
    {
        public long EndDayID { get; set; }
        public long PlayerID { get; set; }
        public short Day { get; set; }
        public DateTime TimeStamp { get; set; }
        public PlayerModel Player { get; set; }
    }
}
