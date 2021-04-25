using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Data.Models
{
    public class MatchedPlayer
    {
        public long PlayerID { get; set; }
        public long OtherPlayerID { get; set; }
        public DateTime TimeStamp { get; set; }
    }
}
