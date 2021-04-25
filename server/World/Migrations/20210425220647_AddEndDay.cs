using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace World.Migrations
{
    public partial class AddEndDay : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "EndDays",
                columns: table => new
                {
                    EndDayID = table.Column<uint>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    PlayerID = table.Column<long>(type: "INTEGER", nullable: false),
                    Day = table.Column<uint>(type: "INTEGER", nullable: false),
                    TimeStamp = table.Column<DateTime>(type: "TEXT", nullable: false)
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

            migrationBuilder.CreateIndex(
                name: "IX_EndDays_PlayerID",
                table: "EndDays",
                column: "PlayerID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EndDays");
        }
    }
}
