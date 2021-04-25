using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace World.Configuration
{
    public class GameSettings
    {
        public const string Position = nameof(GameSettings);

        public TimeSpan DayLength { get; set; }
    }
}
