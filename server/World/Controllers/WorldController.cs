﻿using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
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
        public async Task<ActionResult<uint>> AddPath([FromBody] PathPostDTO dto)
        {
            var path = new PathModel
            {
                WorldID = dto.WorldID,
                ZoneID = dto.ZoneID,
                PlayerID = dto.PlayerID,
                Day = dto.Day,
                TimeStamp = DateTimeOffset.Now,
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
        public async Task<ActionResult<PathGetPlayerDayDTO>> GetDay(Guid playerID, uint worldID, uint zoneID, uint day)
        {
            var tiles = (await WorldContext.Paths
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
                .ToListAsync())
                .OrderBy(pt => pt.TimeStamp)
                .ToList();

            var dto = new PathGetPlayerDayDTO(
                Tiles: tiles);

            return dto;
        }
    }
}
