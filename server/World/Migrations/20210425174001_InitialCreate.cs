using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace World.Migrations
{
    public partial class InitialCreate : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Players",
                columns: table => new
                {
                    PlayerID = table.Column<long>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Name = table.Column<string>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Players", x => x.PlayerID);
                });

            migrationBuilder.CreateTable(
                name: "Paths",
                columns: table => new
                {
                    PathID = table.Column<uint>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    WorldID = table.Column<uint>(type: "INTEGER", nullable: false),
                    ZoneID = table.Column<uint>(type: "INTEGER", nullable: false),
                    PlayerID = table.Column<long>(type: "INTEGER", nullable: false),
                    Day = table.Column<uint>(type: "INTEGER", nullable: false),
                    TimeStamp = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
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
                    TileID = table.Column<uint>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    PathID = table.Column<uint>(type: "INTEGER", nullable: false),
                    TileX = table.Column<uint>(type: "INTEGER", nullable: false),
                    TileY = table.Column<uint>(type: "INTEGER", nullable: false),
                    TimeStamp = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
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
                name: "PathTiles");

            migrationBuilder.DropTable(
                name: "Paths");

            migrationBuilder.DropTable(
                name: "Players");
        }
    }
}
