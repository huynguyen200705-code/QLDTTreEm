using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace _0859_NguyenQuocHuy_WebAPI.Models;

/// <summary>
/// Người dùng hệ thống kế thừa IdentityUser chuẩn ASP.NET Core
/// </summary>
public class User : IdentityUser
{
    [MaxLength(5)]
    public string? Initials { get; set; }
}

