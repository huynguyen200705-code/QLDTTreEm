using System.ComponentModel.DataAnnotations;

namespace _0859_NguyenQuocHuy_WebAPI.Models;

/// <summary>
/// Dữ liệu đầu vào yêu cầu đăng nhập
/// </summary>
public class LoginModel
{
    [Required(ErrorMessage = "Tên đăng nhập không được để trống")]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Mật khẩu không được để trống")]
    [DataType(DataType.Password)]
    public string Password { get; set; } = string.Empty;
}

