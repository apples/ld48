using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using System.Threading.Tasks;
using World.Data;

namespace World.Extensions
{
    public static class IServiceCollectionExtensions
    {
        /// <summary>
        /// Registers the WorldContext.
        /// </summary>
        /// <param name="services">Collection to add the WorldContext to.</param>
        /// <param name="connectionString">If the connection is null or empty, an InMemory database will be used.</param>
        /// <returns>The same services collection.</returns>
        public static IServiceCollection AddWorldContext(this IServiceCollection services, string connectionString)
        {
            if (string.IsNullOrEmpty(connectionString))
            {
                var optionsBuilder = new DbContextOptionsBuilder<WorldContext>()
                    //.LogTo(Console.WriteLine).EnableSensitiveDataLogging()
                    .UseSqlite(CreateInMemoryDatabase());
                var worldContext = new WorldContext(optionsBuilder.Options);
                worldContext.Database.EnsureCreated();
                return services.AddSingleton(worldContext);
            }
            else
            {
                return services.AddDbContext<WorldContext>(options =>
                {
                    options.UseSqlite(connectionString);
                });
            }
        }

        private static DbConnection CreateInMemoryDatabase()
        {
            var connection = new SqliteConnection("DataSource=:memory:");

            connection.Open();

            return connection;
        }
    }
}
