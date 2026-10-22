using _0859_NguyenQuocHuy_WebAPI.Models;

namespace _0859_NguyenQuocHuy_WebAPI.Repositories;

/// <summary>
/// Giao diện định nghĩa các thao tác dữ liệu cho thực thể Sản phẩm
/// </summary>
public interface IproductRepository
{
    /// <summary>Lấy danh sách tất cả sản phẩm kèm danh mục tương ứng</summary>
    Task<IEnumerable<Product>> GetProductsAsync();

    /// <summary>Lấy thông tin chi tiết một sản phẩm theo định danh</summary>
    Task<Product?> GetProductByIdAsync(int id);

    /// <summary>Thêm một sản phẩm mới vào cơ sở dữ liệu</summary>
    Task AddProductAsync(Product product);

    /// <summary>Cập nhật thông tin sản phẩm hiện có</summary>
    Task UpdateProductAsync(Product product);

    /// <summary>Xóa sản phẩm theo mã định danh</summary>
    Task DeleteProductAsync(int id);
}

