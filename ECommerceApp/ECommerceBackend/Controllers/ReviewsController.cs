using System.Security.Claims;
using ECommerceBackend.DTOs.Review;
using ECommerceBackend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ECommerceBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ReviewsController : ControllerBase
{
    private readonly IReviewService _reviewService;

    public ReviewsController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    [HttpGet("product/{productId:int}")]
    public async Task<IActionResult> GetApprovedByProduct(int productId)
    {
        return Ok(await _reviewService.GetApprovedByProductIdAsync(productId));
    }

    [HttpGet("admin")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAll()
    {
        return Ok(await _reviewService.GetAllAsync());
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateReviewDto dto)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized(new { message = "Invalid user identity." });
        }

        try
        {
            var review = await _reviewService.CreateAsync(userId, dto);
            return CreatedAtAction(
                nameof(GetApprovedByProduct),
                new { productId = review.ProductId },
                review);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}/status")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Moderate(
        int id,
        [FromBody] string status)
    {
        try
        {
            return await _reviewService.ModerateAsync(id, status)
                ? Ok(new { message = $"Review {status.ToLowerInvariant()}." })
                : NotFound(new { message = "Review not found." });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(int id)
    {
        return await _reviewService.DeleteAsync(id)
            ? NoContent()
            : NotFound(new { message = "Review not found." });
    }
}
