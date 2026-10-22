using _0859_NguyenQuocHuy_WebAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace _0859_NguyenQuocHuy_WebAPI.Repositories;

/// <summary>
/// Triển khai các phương thức truy vấn và cập nhật dữ liệu Sản phẩm
/// </summary>
public class ProductRepository : IproductRepository
{
    private readonly ApplicationDbContext _dbContext;

    public ProductRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IEnumerable<Product>> GetProductsAsync()
    {
        return await _dbContext.Products
            .AsNoTracking()
            .Include(item => item.Category)
            .ToListAsync();
    }

    public async Task<Product?> GetProductByIdAsync(int id)
    {
        return await _dbContext.Products
            .AsNoTracking()
            .Include(item => item.Category)
            .SingleOrDefaultAsync(item => item.Id == id);
    }

    public async Task AddProductAsync(Product product)
    {
        ArgumentNullException.ThrowIfNull(product);
        await _dbContext.Products.AddAsync(product);
        await _dbContext.SaveChangesAsync();
    }

    public async Task UpdateProductAsync(Product product)
    {
        ArgumentNullException.ThrowIfNull(product);
        _dbContext.Products.Update(product);
        await _dbContext.SaveChangesAsync();
    }

    public async Task DeleteProductAsync(int id)
    {
        var targetProduct = await _dbContext.Products.FindAsync(id);
        if (targetProduct is not null)
        {
            _dbContext.Products.Remove(targetProduct);
            await _dbContext.SaveChangesAsync();
        }
    }
}

