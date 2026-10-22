using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace _0859_NguyenQuocHuy_WebAPI.Models;

/// <summary>
/// Thực thể phân loại danh mục sản phẩm
/// </summary>
public class Category
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }

    [Required]
    [MaxLength(150)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Description { get; set; }

    // Danh sách sản phẩm thuộc danh mục (bỏ qua khi serialize json để tránh vòng lặp)
    [JsonIgnore]
    public virtual ICollection<Product> Products { get; set; } = new List<Product>();
}

