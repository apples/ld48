using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using World.Data.TransferObjects;

namespace World.Serializers
{
    public class DayEventUpdateDTOConverter : JsonConverter<DayEventUpdateDTO>
    {
        public override DayEventUpdateDTO Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
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
            var type = reader.GetUInt32();
            reader.Read();
            var value = reader.GetInt32();
            reader.Read();

            if (reader.TokenType != JsonTokenType.EndArray)
            {
                throw new JsonException($"{nameof(PathTileDTO)} JSON did not end as an array.");
            }

            return new DayEventUpdateDTO(
                TileX: x,
                TileY: y,
                EventType: type,
                EventValue: value);
        }

        public override void Write(Utf8JsonWriter writer, DayEventUpdateDTO value, JsonSerializerOptions options)
        {
            writer.WriteStartArray();
            writer.WriteNumberValue(value.TileX);
            writer.WriteNumberValue(value.TileY);
            writer.WriteNumberValue(value.EventType);
            writer.WriteNumberValue(value.EventValue);
            writer.WriteEndArray();
        }
    }
}
