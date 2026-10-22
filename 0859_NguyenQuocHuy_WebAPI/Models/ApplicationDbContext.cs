using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace _0859_NguyenQuocHuy_WebAPI.Models;

/// <summary>
/// DbContext quản lý kết nối CSDL và các tập thực thể
/// </summary>
public class ApplicationDbContext : IdentityDbContext<User>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) 
        : base(options) 
    { 
    }

    public DbSet<Product> Products => Set<Product>();
    public DbSet<Category> Categories => Set<Category>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Thiết lập schema riêng cho Identity
        builder.HasDefaultSchema("identity");

        // Cấu hình thuộc tính cho User mở rộng
        builder.Entity<User>(entity =>
        {
            entity.Property(u => u.Initials)
                  .HasMaxLength(5);
        });

        // Thiết lập quan hệ 1 - N giữa Category và Product
        builder.Entity<Product>(entity =>
        {
            entity.HasOne(p => p.Category)
                  .WithMany(c => c.Products)
                  .HasForeignKey(p => p.CategoryId)
                  .OnDelete(DeleteBehavior.SetNull); // Xóa danh mục thì gán CategoryId = null
        });
    }
}

