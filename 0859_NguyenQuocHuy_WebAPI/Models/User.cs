using Microsoft.AspNetCore.Identity;

namespace _0859_NguyenQuocHuy_WebAPI.Models;

public class User : IdentityUser
{
    public string? Initials { get; set; }
}
