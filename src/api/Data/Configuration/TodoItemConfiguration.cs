using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WebApi.Data.Entities;

namespace WebApi.Data.Configuration;

public class TodoItemConfiguration : IEntityTypeConfiguration<TodoItem>
{
	public void Configure(EntityTypeBuilder<TodoItem> builder)
	{
		builder.ToTable("TodoItems");
		builder.HasKey(ti => ti.Id);
		builder.Property(ti => ti.Title).IsRequired().HasMaxLength(200);
		builder.Property(ti => ti.IsCompleted).HasDefaultValue(false);
		builder.Property(ti => ti.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
		
		// Configure the relationship with TodoList
		builder.HasOne(ti => ti.TodoList)
			.WithMany(tl => tl.Items)
			.HasForeignKey(ti => ti.TodoListId)
			.OnDelete(DeleteBehavior.Cascade);
	}
}
