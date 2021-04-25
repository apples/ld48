using System;
using System.Text.Json;
using System.Text.Json.Serialization;
using World.Data.TransferObjects;

namespace World.Serializers
{
    public class PathTileDTOConverter : JsonConverter<PathTileDTO>
    {
        public override PathTileDTO Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            if (reader.TokenType != JsonTokenType.StartArray)
            {
                throw new JsonException($"{nameof(PathTileDTO)} JSON did not start as an array.");
            }
            reader.Read();

            var x = reader.GetUInt32();
            reader.Read();
            var y = reader.GetUInt32();
            reader.Read();
            var timeStamp = (float)reader.GetDouble();
            reader.Read();

            if (reader.TokenType != JsonTokenType.EndArray)
            {
                throw new JsonException($"{nameof(PathTileDTO)} JSON did not end as an array.");
            }

            return new PathTileDTO(
                TileX: x,
                TileY: y,
                TimeStamp: timeStamp);
        }

        public override void Write(Utf8JsonWriter writer, PathTileDTO value, JsonSerializerOptions options)
        {
            writer.WriteStartArray();
            writer.WriteNumberValue(value.TileX);
            writer.WriteNumberValue(value.TileY);
            writer.WriteNumberValue(value.TimeStamp);
            writer.WriteEndArray();
        }
    }
}
