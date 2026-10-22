using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace _0859_NguyenQuocHuy_WebAPI.Models;

/// <summary>
/// Đại diện cho thông tin một sản phẩm trong hệ thống
/// </summary>
public class Product
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [MaxLength(250)]
    public string? Name { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal Price { get; set; }

    public string? Image { get; set; }

    public string? Description { get; set; }

    // Khóa ngoại liên kết danh mục
    public int? CategoryId { get; set; }

    [ForeignKey(nameof(CategoryId))]
    public virtual Category? Category { get; set; }
}

