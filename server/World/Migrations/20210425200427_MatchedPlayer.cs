using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace World.Migrations
{
    public partial class MatchedPlayer : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<float>(
                name: "TimeStamp",
                table: "PathTiles",
                type: "REAL",
                nullable: false,
                oldClrType: typeof(DateTimeOffset),
                oldType: "TEXT");

            migrationBuilder.CreateTable(
                name: "MatchedPlayers",
                columns: table => new
                {
                    PlayerID = table.Column<long>(type: "INTEGER", nullable: false),
                    OtherPlayerID = table.Column<long>(type: "INTEGER", nullable: false),
                    TimeStamp = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MatchedPlayers", x => new { x.PlayerID, x.OtherPlayerID });
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MatchedPlayers");

            migrationBuilder.AlterColumn<DateTimeOffset>(
                name: "TimeStamp",
                table: "PathTiles",
                type: "TEXT",
                nullable: false,
                oldClrType: typeof(float),
                oldType: "REAL");
        }
    }
}
