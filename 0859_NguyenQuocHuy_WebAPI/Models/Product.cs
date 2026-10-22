namespace _0859_NguyenQuocHuy_WebAPI.Models;

public class Product
{
    public int Id { get; set; }
    public string? Name { get; set; }
    public decimal Price { get; set; }
    public string? Image { get; set; }
    public string? Description { get; set; }

    // Danh mục sản phẩm
    public int? CategoryId { get; set; }
    public Category? Category { get; set; }
}
