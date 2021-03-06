using Microsoft.EntityFrameworkCore;
using World.Data.Models;

namespace World.Data
{
    public class WorldContext : DbContext
    {
        public WorldContext(DbContextOptions<WorldContext> options) :
            base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<PathModel>(entityBuilder =>
            {
                entityBuilder.HasKey(path => path.PathID);
                entityBuilder.HasMany(path => path.Tiles)
                    .WithOne(pathTile => pathTile.Path);
                entityBuilder.HasOne(path => path.Player)
                    .WithMany()
                    .HasForeignKey(path => path.PlayerID);
            });

            modelBuilder.Entity<PathTileModel>(entityBuilder =>
            {
                entityBuilder.HasKey(pathTile => pathTile.TileID);
                entityBuilder.HasOne(pathTile => pathTile.Path)
                    .WithMany(path => path.Tiles)
                    .HasForeignKey(pathTile => pathTile.PathID);
            });

            modelBuilder.Entity<PlayerModel>(entityBuilder =>
            {
                entityBuilder.HasKey(player => player.PlayerID);
            });
            
            modelBuilder.Entity<MatchedPlayer>(entityBuilder =>
            {
                entityBuilder.HasKey(matchedPlayer => new { matchedPlayer.PlayerID, matchedPlayer.OtherPlayerID });
            });

            modelBuilder.Entity<EventModel>(entityBuilder =>
            {
                entityBuilder.HasKey(@event => @event.EventID);
            });

            modelBuilder.Entity<EndDayModel>(entityBuilder =>
            {
                entityBuilder.HasKey(endDay => endDay.EndDayID);
                entityBuilder.HasOne(endDay => endDay.Player)
                    .WithMany()
                    .HasForeignKey(endDay => endDay.PlayerID);
            });
        }

        public DbSet<PathModel> Paths { get; set; }
        public DbSet<PathTileModel> PathTiles { get; set; }
        public DbSet<PlayerModel> Players { get; set; }
        public DbSet<MatchedPlayer> MatchedPlayers { get; set; }
        public DbSet<EventModel> Events { get; set; }
        public DbSet<EndDayModel> EndDays { get; set; }
    }
}
