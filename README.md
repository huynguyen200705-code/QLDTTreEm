# QLDTTreEm - Web API Backend

Backend Web API cho hệ thống Quản lý điện thoại trẻ em (ASP.NET Core Web API).

## Cấu trúc dự án
- `0859_NguyenQuocHuy_WebAPI/`: Dự án ASP.NET Core Web API (.NET 10)
  - `Controllers/`: API Controllers (AuthenticateController, CategoryApiController, ProductApiController...)
  - `Models/`: Các Entity và DTO (User, ApplicationDbContext, Category, Product, LoginModel, RegistrationModel...)
  - `Repositories/`: Interface và Repository triển khai truy vấn dữ liệu
  - `Migrations/`: Entity Framework Core Code-First Migrations
- `0859_NguyenQuocHuy_WebAPI.slnx`: Solution file cho Visual Studio / Rider
- `lesson_content.txt`: Tài liệu hướng dẫn cấu hình Identity & JWT