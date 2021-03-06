using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using World.Data;
using World.Data.Models;
using World.Data.TransferObjects;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace World.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WorldController : ControllerBase
    {
        public WorldContext WorldContext { get; }

        public WorldController(WorldContext worldContext)
        {
            WorldContext = worldContext;
        }

        // POST api/<ValuesController>/AddPath
        [Route("AddPath")]
        [HttpPost]
        public async Task<ActionResult<long>> AddPath([FromBody] PathPostDTO dto)
        {
            var path = new PathModel
            {
                WorldID = dto.WorldID,
                ZoneID = dto.ZoneID,
                PlayerID = dto.PlayerID,
                Day = dto.Day,
                TimeStamp = DateTime.UtcNow,
                Tiles = dto.Tiles.Select(pt =>
                    new PathTileModel
                    {
                        TileX = pt.TileX,
                        TileY = pt.TileY,
                        TimeStamp = pt.TimeStamp
                    }).ToList()
            };

            await WorldContext.Paths.AddAsync(path);
            await WorldContext.SaveChangesAsync();

            return path.PathID;
        }

        // GET api/<ValuesController>/GetPath
        [Route("GetPath")]
        [HttpGet]
        public async Task<ActionResult<PathGetDTO>> GetPath(uint pathID)
        {
            var path = await WorldContext.Paths.FindAsync(pathID);

            if (path == null)
            {
                return NotFound();
            }

            var dto = new PathGetDTO(
                PathID: path.PathID,
                WorldID: path.WorldID,
                ZoneID: path.ZoneID,
                PlayerID: path.PlayerID,
                Day: path.Day,
                TimeStamp: path.TimeStamp,
                Tiles: path.Tiles.Select(pt =>
                    new PathTileDTO(
                        TileX: pt.TileX,
                        TileY: pt.TileY,
                        TimeStamp: pt.TimeStamp
                    )).ToList());

            return dto;
        }

        // GET api/<ValuesController>/GetDay
        [Route("GetDay")]
        [HttpGet]
        public async Task<ActionResult<PathGetPlayerDayDTO>> GetDay(long playerID, uint worldID, uint zoneID, uint day)
        {
            var tiles = await WorldContext.Paths
                .Where(p =>
                    p.WorldID == worldID &&
                    p.ZoneID == zoneID &&
                    p.PlayerID == playerID &&
                    p.Day == day)
                .SelectMany(p => p.Tiles)
                .Select(pt => new PathTileDTO(
                    pt.TileX,
                    pt.TileY,
                    pt.TimeStamp))
                .OrderBy(pt => pt.TimeStamp)
                .ToListAsync();

            var dto = new PathGetPlayerDayDTO(
                Tiles: tiles);

            return dto;
        }

        // POST api/<ValuesController>/EndDay
        [Route("EndDay")]
        [HttpPost]
        public async Task<ActionResult<DayUpdatesDTO>> EndDay([FromBody] EndDayDTO dto)
        {
            var endDay = new EndDayModel
            {
                PlayerID = dto.PlayerID,
                Day = dto.Day,
                TimeStamp = DateTime.Now
            };

            await WorldContext.EndDays.AddAsync(endDay);
            await WorldContext.SaveChangesAsync();

            long? newFriend = null;

            var unfriendedPlayers = await WorldContext.MatchedPlayers
                .Where(op =>
                    op.OtherPlayerID == dto.PlayerID &&
                    !WorldContext.MatchedPlayers
                        .Where(mp => mp.PlayerID == dto.PlayerID)
                        .Any(mp => mp.OtherPlayerID == op.PlayerID))
                .ToListAsync();

            newFriend = unfriendedPlayers.FirstOrDefault()?.PlayerID;

            if (newFriend.HasValue == false)
            {
                var newPlayers = await WorldContext.Paths
                    .Where(p =>
                        p.PlayerID != dto.PlayerID &&
                        !WorldContext.MatchedPlayers
                            .Where(mp => mp.PlayerID == dto.PlayerID)
                            .Any(mp => mp.OtherPlayerID == p.PlayerID))
                    .GroupBy(p => p.PlayerID)
                    .Select(g => new
                    {
                        PlayerID = g.Key,
                        LatestTimeStamp = g.Max(p => p.TimeStamp)
                    })
                    .OrderByDescending(p => p.LatestTimeStamp)
                    .ToListAsync();

                newFriend = newPlayers.FirstOrDefault()?.PlayerID;
            }

            if (newFriend.HasValue == true)
            {
                WorldContext.MatchedPlayers
                    .Add(new MatchedPlayer
                    {
                        PlayerID = dto.PlayerID,
                        OtherPlayerID = newFriend.Value,
                        TimeStamp = DateTime.UtcNow
                    });
                await WorldContext.SaveChangesAsync();
            }

            var days = (dto.Day > 10) ? 10 : dto.Day;

            var otherPlayers = await WorldContext.MatchedPlayers
                .Where(mp => mp.PlayerID == dto.PlayerID)
                .Select(mp => mp.OtherPlayerID)
                .ToListAsync();

            var otherPlayerEarliestDay = (await WorldContext.EndDays
                .Where(e => otherPlayers.Contains(e.PlayerID))
                .GroupBy(e => e.PlayerID)
                .Select(g => new
                {
                    PlayerID = g.Key,
                    LatestDay = g.Max(e => e.Day)
                })
                .ToListAsync())
                .Select(e => new
                {
                    e.PlayerID,
                    EarliestDay = (e.LatestDay - days) > 0 ? e.LatestDay - days : 1
                });

            var tiles = new List<TileCount>();
            foreach (var otherPlayer in otherPlayerEarliestDay)
            {
                tiles.AddRange(await WorldContext.Paths
                    .Where(p =>
                        p.WorldID == dto.WorldID &&
                        p.ZoneID == dto.ZoneID &&
                        p.PlayerID == otherPlayer.PlayerID &&
                        p.Day >= otherPlayer.EarliestDay)
                    .SelectMany(p => p.Tiles)
                    .GroupBy(pt => new { pt.TileX, pt.TileY })
                    .Select(g => new TileCount
                    {
                        TileX = g.Key.TileX,
                        TileY = g.Key.TileY,
                        Count = g.Count()
                    })
                    .OrderByDescending(g => g.Count)
                    .ToListAsync());
            }

            // Only select top 80% of tiles by number of hits
            var tileHits = tiles.Sum(t => t.Count) * 0.8;
            int runningTotal = 0;
            var wornTilesDTO = tiles
                .TakeWhile(t => (runningTotal += t.Count) < tileHits)
                .Select(t => new PathTileWornDTO(
                    t.TileX,
                    t.TileY,
                    t.Count))
                .ToList();

            var events = new List<DayEventUpdateDTO>();
            foreach (var otherPlayer in otherPlayerEarliestDay)
            {
                var timeStamp = (await WorldContext.EndDays
                    .Where(e => e.PlayerID == otherPlayer.PlayerID &&
                        e.Day == otherPlayer.EarliestDay)
                    .SingleOrDefaultAsync())
                    ?.TimeStamp;

                if (timeStamp == null)
                {
                    continue;
                }

                events.AddRange(await WorldContext.Events
                    .Where(e =>
                        e.PlayerID == otherPlayer.PlayerID &&
                        e.TimeStamp > timeStamp)
                    .GroupBy(e => new { e.TileX, e.TileY, e.EventType })
                    .Select(g => new DayEventUpdateDTO(
                            g.Key.TileX,
                            g.Key.TileY,
                            g.Key.EventType,
                            g.Sum(e => e.EventValue)
                        ))
                    .ToListAsync());
            }

            return new DayUpdatesDTO(
                endDay.EndDayID,
                wornTilesDTO,
                events);
        }

        [Route("NewPlayer")]
        [HttpPost]
        public async Task<ActionResult<NewPlayerDTO>> NewPlayer(NewPlayerPostDTO dto) {
            Console.WriteLine("New player: '" + dto.Name + "'");
            if (dto.Name == null) return BadRequest();
            var player = new PlayerModel{ Name = dto.Name };
            await WorldContext.Players.AddAsync(player);
            await WorldContext.SaveChangesAsync();
            return new NewPlayerDTO(player.PlayerID, player.Name);
        }
        
        [Route("VerifyPlayer")]
        [HttpPost]
        public async Task<ActionResult<VerifyPlayerDTO>> VerifyPlayer(VerifyPlayerPostDTO dto) {
            if (dto.Name == null || dto.PlayerID < 0) return BadRequest();
            try {
                var player = await WorldContext.Players.SingleOrDefaultAsync(p => p.PlayerID == dto.PlayerID && p.Name == dto.Name);
                var valid = player != null;
                Console.WriteLine("Verification result: " + valid.ToString());
                return new VerifyPlayerDTO(valid);
            } catch {
                Console.WriteLine("Verification result: false");
                return new VerifyPlayerDTO(false);
            }
        }

        [Route("AddEvent")]
        [HttpPost]
        public async Task<ActionResult<long>> AddEvent([FromBody]AddEventDTO dto)
        {
            var newEvent = new EventModel
            {
                PlayerID = dto.PlayerID,
                EventType = dto.EventType,
                EventValue = dto.EventValue,
                TileX = dto.TileX,
                TileY = dto.TileY,
                TimeStamp = DateTime.UtcNow
            };

            await WorldContext.Events.AddAsync(newEvent);
            await WorldContext.SaveChangesAsync();

            return newEvent.EventID;
        }

        private class TileCount
        {
            public int TileX { get; set; }
            public int TileY { get; set; }
            public int Count { get; set; }
        }
    }
}
