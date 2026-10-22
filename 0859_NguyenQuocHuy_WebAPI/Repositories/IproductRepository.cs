using _0859_NguyenQuocHuy_WebAPI.Models;

namespace _0859_NguyenQuocHuy_WebAPI.Repositories;

public interface IproductRepository
{
    Task<IEnumerable<Product>> GetProductsAsync();
    Task<Product?> GetProductByIdAsync(int id);
    Task AddProductAsync(Product product);
    Task UpdateProductAsync(Product product);
    Task DeleteProductAsync(int id);
}
