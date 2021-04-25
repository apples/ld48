using System;
using System.Text.Json;
using System.Text.Json.Serialization;
using World.Data.TransferObjects;

namespace World.Serializers
{
    public class PathTileWornDTOConverter : JsonConverter<PathTileWornDTO>
    {
        public override PathTileWornDTO Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            if (reader.TokenType != JsonTokenType.StartArray)
            {
                throw new JsonException($"{nameof(PathTileWornDTO)} JSON did not start as an array.");
            }
            reader.Read();

            var x = reader.GetUInt32();
            reader.Read();
            var y = reader.GetUInt32();
            reader.Read();
            var wornLevel = reader.GetByte();
            reader.Read();

            if (reader.TokenType != JsonTokenType.EndArray)
            {
                throw new JsonException($"{nameof(PathTileWornDTO)} JSON did not end as an array.");
            }
            reader.Read();

            return new PathTileWornDTO(
                X: x,
                Y: y,
                WornLevel: wornLevel);
        }

        public override void Write(Utf8JsonWriter writer, PathTileWornDTO value, JsonSerializerOptions options)
        {
            writer.WriteStartArray();
            writer.WriteNumberValue(value.X);
            writer.WriteNumberValue(value.Y);
            writer.WriteNumberValue(value.WornLevel);
            writer.WriteEndArray();
        }
    }
}
