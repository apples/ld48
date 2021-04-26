using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace World.Migrations
{
    public partial class InitialCreate : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Events",
                columns: table => new
                {
                    EventID = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PlayerID = table.Column<long>(type: "bigint", nullable: false),
                    EventType = table.Column<short>(type: "smallint", nullable: false),
                    EventValue = table.Column<int>(type: "int", nullable: false),
                    TileX = table.Column<int>(type: "int", nullable: false),
                    TileY = table.Column<int>(type: "int", nullable: false),
                    TimeStamp = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Events", x => x.EventID);
                });

            migrationBuilder.CreateTable(
                name: "MatchedPlayers",
                columns: table => new
                {
                    PlayerID = table.Column<long>(type: "bigint", nullable: false),
                    OtherPlayerID = table.Column<long>(type: "bigint", nullable: false),
                    TimeStamp = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MatchedPlayers", x => new { x.PlayerID, x.OtherPlayerID });
                });

            migrationBuilder.CreateTable(
                name: "Players",
                columns: table => new
                {
                    PlayerID = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Players", x => x.PlayerID);
                });

            migrationBuilder.CreateTable(
                name: "EndDays",
                columns: table => new
                {
                    EndDayID = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PlayerID = table.Column<long>(type: "bigint", nullable: false),
                    Day = table.Column<short>(type: "smallint", nullable: false),
                    TimeStamp = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EndDays", x => x.EndDayID);
                    table.ForeignKey(
                        name: "FK_EndDays_Players_PlayerID",
                        column: x => x.PlayerID,
                        principalTable: "Players",
                        principalColumn: "PlayerID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Paths",
                columns: table => new
                {
                    PathID = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    WorldID = table.Column<short>(type: "smallint", nullable: false),
                    ZoneID = table.Column<short>(type: "smallint", nullable: false),
                    PlayerID = table.Column<long>(type: "bigint", nullable: false),
                    Day = table.Column<short>(type: "smallint", nullable: false),
                    TimeStamp = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Paths", x => x.PathID);
                    table.ForeignKey(
                        name: "FK_Paths_Players_PlayerID",
                        column: x => x.PlayerID,
                        principalTable: "Players",
                        principalColumn: "PlayerID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PathTiles",
                columns: table => new
                {
                    TileID = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PathID = table.Column<long>(type: "bigint", nullable: false),
                    TileX = table.Column<int>(type: "int", nullable: false),
                    TileY = table.Column<int>(type: "int", nullable: false),
                    TimeStamp = table.Column<float>(type: "real", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PathTiles", x => x.TileID);
                    table.ForeignKey(
                        name: "FK_PathTiles_Paths_PathID",
                        column: x => x.PathID,
                        principalTable: "Paths",
                        principalColumn: "PathID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_EndDays_PlayerID",
                table: "EndDays",
                column: "PlayerID");

            migrationBuilder.CreateIndex(
                name: "IX_Paths_PlayerID",
                table: "Paths",
                column: "PlayerID");

            migrationBuilder.CreateIndex(
                name: "IX_PathTiles_PathID",
                table: "PathTiles",
                column: "PathID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EndDays");

            migrationBuilder.DropTable(
                name: "Events");

            migrationBuilder.DropTable(
                name: "MatchedPlayers");

            migrationBuilder.DropTable(
                name: "PathTiles");

            migrationBuilder.DropTable(
                name: "Paths");

            migrationBuilder.DropTable(
                name: "Players");
        }
    }
}
