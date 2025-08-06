namespace WebApi.Data.Entities;

public class TodoList
{
	public int Id { get; set; }
	public string Title { get; set; } = string.Empty;
	public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
	public ICollection<TodoItem> Items { get; set; } = new List<TodoItem>();
}
