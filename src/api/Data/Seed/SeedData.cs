using WebApi.Data.Entities;

namespace WebApi.Data.Seed;

public static class SeedData
{
	public static List<TodoList> TodoLists()
	{
		return new List<TodoList>
		{
			new TodoList
			{
				Id = 1,
				Title = "Personal",
				CreatedAt = new DateTime(2025, 8, 1)
				
			},
			new TodoList
			{
				Id = 2,
				Title = "Work",
				CreatedAt = new DateTime(2025, 8, 2)
			}
		};
	}
	public static List<TodoItem> TodoItems()
	{
		return new List<TodoItem>
		{
			new TodoItem
			{
				Id = 1,
				Title = "Buy groceries",
				IsCompleted = false,
				CreatedAt = new DateTime(2025, 8, 1),
				TodoListId = 1
			},
			new TodoItem
			{
				Id = 2,
				Title = "Finish project report",
				IsCompleted = false,
				CreatedAt = new DateTime(2025, 8, 1),
				TodoListId = 2
			},
			new TodoItem
			{
				Id = 3,
				Title = "Call mom",
				IsCompleted = true,
				CreatedAt = new DateTime(2025, 8, 1),
				TodoListId = 1
			}
		};
	}
}
