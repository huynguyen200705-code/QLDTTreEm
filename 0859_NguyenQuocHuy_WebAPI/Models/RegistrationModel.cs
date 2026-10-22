using System.ComponentModel.DataAnnotations;

namespace _0859_NguyenQuocHuy_WebAPI.Models;

/// <summary>
/// Dữ liệu đầu vào yêu cầu tạo tài khoản mới
/// </summary>
public class RegistrationModel
{
    [Required(ErrorMessage = "Tên đăng nhập là bắt buộc")]
    [StringLength(50, MinimumLength = 3, ErrorMessage = "Tên đăng nhập phải từ 3 đến 50 ký tự")]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email là bắt buộc")]
    [EmailAddress(ErrorMessage = "Định dạng email không hợp lệ")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Mật khẩu là bắt buộc")]
    [MinLength(6, ErrorMessage = "Mật khẩu phải chứa ít nhất 6 ký tự")]
    [DataType(DataType.Password)]
    public string Password { get; set; } = string.Empty;

    [MaxLength(5, ErrorMessage = "Chữ cái viết tắt tối đa 5 ký tự")]
    public string? Initials { get; set; }

    /// <summary>
    /// Vai trò người dùng (mặc định là 'User' nếu để trống)
    /// </summary>
    public string? Role { get; set; }
}

