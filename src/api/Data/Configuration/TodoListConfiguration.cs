using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using WebApi.Data.Entities;

namespace WebApi.Data.Configuration;

public class TodoListConfiguration : IEntityTypeConfiguration<TodoList>
{
	public void Configure(EntityTypeBuilder<TodoList> builder)
	{
		builder.ToTable("TodoLists");
		builder.HasKey(tl => tl.Id);
		builder.Property(tl => tl.Title).IsRequired().HasMaxLength(100);
		builder.Property(tl => tl.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
		builder.HasMany(tl => tl.Items)
			.WithOne(ti => ti.TodoList)
			.HasForeignKey(ti => ti.TodoListId)
			.OnDelete(DeleteBehavior.Cascade);
	}
}
