using Microsoft.AspNetCore.Mvc;
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

        // GET api/<ValuesController>/5
        [HttpGet("{id}")]
        public async Task<ActionResult<PathGetDTO>> Get(uint id)
        {
            var path = await WorldContext.Paths.FindAsync(id);

            if (path == null)
            {
                return NotFound();
            }

            var dto = new PathGetDTO(
                PathID: path.PathID,
                WorldID: path.WorldID,
                ZoneID: path.ZoneID,
                PlayerID: path.PlayerID,
                TimeStamp: path.TimeStamp,
                Tiles: path.Tiles.Select(pt =>
                    new PathTileDTO(
                        TileX: pt.TileX,
                        TileY: pt.TileY,
                        TimeStamp: pt.TimeStamp
                    )).ToList());

            return dto;
        }

        // POST api/<ValuesController>
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
    }
}
