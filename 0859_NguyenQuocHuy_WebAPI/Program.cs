using _0859_NguyenQuocHuy_WebAPI.Models;
using _0859_NguyenQuocHuy_WebAPI.Repositories;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// 1. Đăng ký CSDL SQL Server với DbContext
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? throw new InvalidOperationException("Chuỗi kết nối 'DefaultConnection' chưa được cấu hình.");

builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    options.UseSqlServer(connectionString);
});

// 2. Cấu hình Identity quản lý tài khoản và phân quyền
builder.Services.AddIdentity<User, IdentityRole>(cfg =>
{
    cfg.Password.RequireDigit = false;
    cfg.Password.RequiredLength = 6;
    cfg.Password.RequireNonAlphanumeric = false;
    cfg.Password.RequireUppercase = false;
    cfg.Password.RequireLowercase = false;
    cfg.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// 3. Đăng ký Controllers & Repositories
builder.Services.AddControllers();
builder.Services.AddScoped<IproductRepository, ProductRepository>();
builder.Services.AddEndpointsApiExplorer();

// 4. Cấu hình Swagger UI hỗ trợ thử nghiệm JWT Bearer
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo 
    { 
        Title = "Hệ Thống API Quản Lý Thiết Bị Trẻ Em", 
        Version = "v1",
        Description = "ASP.NET Core Web API cung cấp các dịch vụ xác thực và dữ liệu"
    });

    var jwtSecurityScheme = new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Description = "Nhập mã Token theo định dạng: Bearer {token}",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        Reference = new OpenApiReference
        {
            Type = ReferenceType.SecurityScheme,
            Id = JwtBearerDefaults.AuthenticationScheme
        }
    };

    c.AddSecurityDefinition(JwtBearerDefaults.AuthenticationScheme, jwtSecurityScheme);
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        { jwtSecurityScheme, Array.Empty<string>() }
    });
});

// 5. Cấu hình CORS mở quyền truy cập cho frontend
const string AppCorsPolicy = "MyAllowOrigins";
builder.Services.AddCors(corsOptions =>
{
    corsOptions.AddPolicy(AppCorsPolicy, policyBuilder =>
    {
        policyBuilder.AllowAnyOrigin()
                     .AllowAnyHeader()
                     .AllowAnyMethod();
    });
});

// 6. Cấu hình JWT Authentication & Authorization
var jwtSection = builder.Configuration.GetSection("JWTKey");
var jwtSecretKey = jwtSection["Secret"] ?? "AReallyLongSecretKeyForYourJWTTokenSigning123456!";
var signingKeyBytes = Encoding.UTF8.GetBytes(jwtSecretKey);

builder.Services.AddAuthentication(authOpts =>
{
    authOpts.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    authOpts.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, bearerOpts =>
{
    bearerOpts.RequireHttpsMetadata = false;
    bearerOpts.SaveToken = true;
    bearerOpts.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSection["ValidIssuer"] ?? "YourIssuer",
        ValidAudience = jwtSection["ValidAudience"] ?? "YourAudience",
        IssuerSigningKey = new SymmetricSecurityKey(signingKeyBytes),
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

var app = builder.Build();

// 7. Tự động khởi tạo dữ liệu vai trò hệ thống (Admin, User)
await InitializeSystemRolesAsync(app);

// 8. Cấu hình Pipeline xử lý HTTP Requests
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "QLDTTreEm API v1");
    });
}
else
{
    app.UseExceptionHandler("/error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseCors(AppCorsPolicy);

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();

// Hàm hỗ trợ khởi tạo các vai trò ban đầu
static async Task InitializeSystemRolesAsync(WebApplication application)
{
    using var scope = application.Services.CreateScope();
    var roleMgr = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
    
    var defaultRoles = new[] { "Admin", "User" };
    foreach (var roleName in defaultRoles)
    {
        if (!await roleMgr.RoleExistsAsync(roleName))
        {
            await roleMgr.CreateAsync(new IdentityRole(roleName));
        }
    }
}

