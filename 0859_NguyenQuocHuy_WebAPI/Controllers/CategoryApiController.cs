using _0859_NguyenQuocHuy_WebAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace _0859_NguyenQuocHuy_WebAPI.Controllers;

[Route("api/[controller]")]
[ApiController]
public class CategoryApiController : ControllerBase
{
    private readonly ApplicationDbContext _dbContext;
    private readonly ILogger<CategoryApiController> _logger;

    public CategoryApiController(
        ApplicationDbContext dbContext,
        ILogger<CategoryApiController> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    /// <summary>
    /// Lấy danh sách tất cả các danh mục cùng các sản phẩm thuộc danh mục
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetCategories()
    {
        try
        {
            var categories = await _dbContext.Categories
                .AsNoTracking()
                .Include(c => c.Products)
                .ToListAsync();

            return Ok(categories);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi xảy ra khi truy vấn danh sách danh mục");
            return StatusCode(StatusCodes.Status500InternalServerError, new { message = "Lỗi khi tải danh mục", error = ex.Message });
        }
    }

    /// <summary>
    /// Xem chi tiết một danh mục theo mã ID
    /// </summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetCategoryById(int id)
    {
        try
        {
            var targetCategory = await _dbContext.Categories
                .AsNoTracking()
                .Include(c => c.Products)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (targetCategory is null)
            {
                return NotFound(new { message = $"Không tìm thấy danh mục mang ID = {id}" });
            }

            return Ok(targetCategory);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi lấy thông tin danh mục {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new { message = "Lỗi máy chủ", error = ex.Message });
        }
    }

    /// <summary>
    /// Tạo mới một danh mục (Yêu cầu vai trò Admin)
    /// </summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> AddCategory([FromBody] Category category)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        try
        {
            await _dbContext.Categories.AddAsync(category);
            await _dbContext.SaveChangesAsync();

            return CreatedAtAction(nameof(GetCategoryById), new { id = category.Id }, category);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi thêm danh mục mới");
            return StatusCode(StatusCodes.Status500InternalServerError, new { message = "Không thể thêm danh mục", error = ex.Message });
        }
    }

    /// <summary>
    /// Chỉnh sửa danh mục hiện có (Yêu cầu vai trò Admin)
    /// </summary>
    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateCategory(int id, [FromBody] Category category)
    {
        if (id != category.Id)
        {
            return BadRequest(new { message = "ID danh mục không trùng khớp" });
        }

        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var isExist = await _dbContext.Categories.AnyAsync(c => c.Id == id);
        if (!isExist)
        {
            return NotFound(new { message = $"Danh mục mang mã {id} không tồn tại" });
        }

        _dbContext.Entry(category).State = EntityState.Modified;

        try
        {
            await _dbContext.SaveChangesAsync();
            return NoContent();
        }
        catch (DbUpdateConcurrencyException ex)
        {
            _logger.LogError(ex, "Lỗi xung đột khi cập nhật danh mục {Id}", id);
            return StatusCode(StatusCodes.Status409Conflict, new { message = "Dữ liệu đã bị thay đổi bởi phiên khác" });
        }
    }

    /// <summary>
    /// Xóa một danh mục (Yêu cầu Admin - sản phẩm thuộc danh mục sẽ chuyển sang CategoryId = null)
    /// </summary>
    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteCategory(int id)
    {
        var categoryToDelete = await _dbContext.Categories.FindAsync(id);
        if (categoryToDelete is null)
        {
            return NotFound(new { message = $"Không tìm thấy danh mục {id} để xóa" });
        }

        try
        {
            _dbContext.Categories.Remove(categoryToDelete);
            await _dbContext.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi xóa danh mục {Id}", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new { message = "Không thể xóa danh mục", error = ex.Message });
        }
    }
}

