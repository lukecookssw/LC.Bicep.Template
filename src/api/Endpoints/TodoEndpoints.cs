using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.EntityFrameworkCore;
using WebApi.Data;
using WebApi.Data.Entities;

namespace WebApi.Endpoints;

public static class TodoEndpoints
{
	public static void MapTodoEndpoints(this WebApplication app)
	{

		app.MapGet("/todos", async (AppDbContext dbContext, CancellationToken ct) =>
		{
			var results = await dbContext.TodoItems.ToListAsync(ct);
			return TypedResults.Ok(results);
		})
			.WithName("GetAllTodos")
			.Produces<List<TodoItem>>(StatusCodes.Status200OK);
	}
}