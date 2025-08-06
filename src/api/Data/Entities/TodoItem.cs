namespace WebApi.Data.Entities;

public class TodoItem
{
	public int Id { get; set; }
	public string Title { get; set; } = string.Empty;
	public bool IsCompleted { get; set; } = false;
	public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
	public int TodoListId { get; set; }
	public TodoList TodoList { get; set; } = null!;
}
