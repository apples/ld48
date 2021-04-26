using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace World.Migrations
{
    public partial class AddEvent : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Events",
                columns: table => new
                {
                    EventID = table.Column<uint>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    PlayerID = table.Column<long>(type: "INTEGER", nullable: false),
                    EventType = table.Column<uint>(type: "INTEGER", nullable: false),
                    EventValue = table.Column<int>(type: "INTEGER", nullable: false),
                    TileX = table.Column<uint>(type: "INTEGER", nullable: false),
                    TileY = table.Column<uint>(type: "INTEGER", nullable: false),
                    TimeStamp = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Events", x => x.EventID);
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Events");
        }
    }
}
