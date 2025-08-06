using Microsoft.EntityFrameworkCore;
using System.Reflection;
using WebApi.Data.Entities;
using WebApi.Data.Seed;

namespace WebApi.Data;

public class AppDbContext : DbContext
{
	public DbSet<TodoList> TodoLists => Set<TodoList>();
	public DbSet<TodoItem> TodoItems => Set<TodoItem>();

	public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
	{
	}

	protected override void OnModelCreating(ModelBuilder modelBuilder)
	{
		modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
		modelBuilder.Entity<TodoList>().HasData(SeedData.TodoLists());
		modelBuilder.Entity<TodoItem>().HasData(SeedData.TodoItems());
		base.OnModelCreating(modelBuilder);
	}
}
