using System.Text.Json.Serialization;

namespace _0859_NguyenQuocHuy_WebAPI.Models;

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    [JsonIgnore]
    public List<Product>? Products { get; set; }
}
