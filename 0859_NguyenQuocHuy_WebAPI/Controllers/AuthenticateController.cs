using _0859_NguyenQuocHuy_WebAPI.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace _0859_NguyenQuocHuy_WebAPI.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthenticateController : ControllerBase
{
    private readonly UserManager<User> _userManager;
    private readonly RoleManager<IdentityRole> _roleManager;
    private readonly IConfiguration _config;
    private readonly ILogger<AuthenticateController> _logger;

    public AuthenticateController(
        UserManager<User> userManager,
        RoleManager<IdentityRole> roleManager,
        IConfiguration config,
        ILogger<AuthenticateController> logger)
    {
        _userManager = userManager;
        _roleManager = roleManager;
        _config = config;
        _logger = logger;
    }

    /// <summary>
    /// Đăng ký tài khoản người dùng mới kèm vai trò
    /// </summary>
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegistrationModel request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Kiểm tra xem tên đăng nhập hoặc email đã tồn tại hay chưa
        var accountByUsername = await _userManager.FindByNameAsync(request.Username);
        if (accountByUsername is not null)
        {
            return StatusCode(StatusCodes.Status400BadRequest, new 
            { 
                status = false, 
                message = "Tên đăng nhập đã tồn tại trong hệ thống." 
            });
        }

        var accountByEmail = await _userManager.FindByEmailAsync(request.Email);
        if (accountByEmail is not null)
        {
            return StatusCode(StatusCodes.Status400BadRequest, new 
            { 
                status = false, 
                message = "Địa chỉ email đã được sử dụng." 
            });
        }

        // Khởi tạo thực thể người dùng mới
        var newUser = new User
        {
            UserName = request.Username.Trim(),
            Email = request.Email.Trim(),
            Initials = request.Initials?.Trim()
        };

        var creationResult = await _userManager.CreateAsync(newUser, request.Password);
        if (!creationResult.Succeeded)
        {
            var errorDetails = string.Join("; ", creationResult.Errors.Select(err => err.Description));
            _logger.LogWarning("Tạo tài khoản thất bại cho {Username}: {Errors}", request.Username, errorDetails);

            return StatusCode(StatusCodes.Status500InternalServerError, new 
            { 
                status = false, 
                message = $"Đăng ký tài khoản không thành công: {errorDetails}" 
            });
        }

        // Gán Role cho tài khoản (mặc định là 'User')
        var targetRole = string.IsNullOrWhiteSpace(request.Role) ? "User" : request.Role.Trim();
        if (!await _roleManager.RoleExistsAsync(targetRole))
        {
            await _roleManager.CreateAsync(new IdentityRole(targetRole));
        }

        await _userManager.AddToRoleAsync(newUser, targetRole);

        _logger.LogInformation("Người dùng {Username} đăng ký thành công với quyền {Role}", newUser.UserName, targetRole);
        return Ok(new 
        { 
            status = true, 
            message = "Tạo tài khoản người dùng thành công." 
        });
    }

    /// <summary>
    /// Xác thực thông tin đăng nhập và cấp phát JWT Bearer Token
    /// </summary>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginModel request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Tìm người dùng theo username
        var appUser = await _userManager.FindByNameAsync(request.Username);
        if (appUser is null || !await _userManager.CheckPasswordAsync(appUser, request.Password))
        {
            return Unauthorized(new 
            { 
                status = false, 
                message = "Tài khoản hoặc mật khẩu không chính xác." 
            });
        }

        // Lấy danh sách các vai trò đã được cấp
        var rolesList = await _userManager.GetRolesAsync(appUser);

        // Khởi tạo các Claims định danh cho Token
        var tokenClaims = new List<Claim>
        {
            new(ClaimTypes.Name, appUser.UserName ?? string.Empty),
            new(ClaimTypes.NameIdentifier, appUser.Id),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        if (!string.IsNullOrEmpty(appUser.Email))
        {
            tokenClaims.Add(new Claim(ClaimTypes.Email, appUser.Email));
        }

        foreach (var roleName in rolesList)
        {
            tokenClaims.Add(new Claim(ClaimTypes.Role, roleName));
        }

        var jwtToken = CreateJwtToken(tokenClaims);
        var primaryRole = rolesList.FirstOrDefault() ?? "User";

        _logger.LogInformation("Người dùng {Username} đăng nhập thành công", appUser.UserName);

        return Ok(new
        {
            status = true,
            message = "Đăng nhập thành công",
            token = jwtToken,
            role = primaryRole,
            username = appUser.UserName
        });
    }

    /// <summary>
    /// Trợ hàm ký và tạo chuỗi JWT Token
    /// </summary>
    private string CreateJwtToken(IEnumerable<Claim> claims)
    {
        var jwtConfig = _config.GetSection("JWTKey");
        var secretKey = jwtConfig["Secret"] ?? "AReallyLongSecretKeyForYourJWTTokenSigning123456!";
        var symmetricKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));

        var expiryHours = double.TryParse(jwtConfig["TokenExpiryTimeInHour"], out var parsedHours) 
            ? parsedHours 
            : 24.0;

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.AddHours(expiryHours),
            Issuer = jwtConfig["ValidIssuer"] ?? "YourIssuer",
            Audience = jwtConfig["ValidAudience"] ?? "YourAudience",
            SigningCredentials = new SigningCredentials(symmetricKey, SecurityAlgorithms.HmacSha256Signature)
        };

        var handler = new JwtSecurityTokenHandler();
        var securityToken = handler.CreateToken(tokenDescriptor);
        return handler.WriteToken(securityToken);
    }
}

