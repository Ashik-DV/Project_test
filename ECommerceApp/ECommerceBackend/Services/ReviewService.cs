using ECommerceBackend.DTOs.Review;
using ECommerceBackend.Models;
using ECommerceBackend.Repositories.Interfaces;
using ECommerceBackend.Services.Interfaces;

namespace ECommerceBackend.Services;

public class ReviewService : IReviewService
{
    private readonly IReviewRepository _reviewRepository;
    private readonly IProductRepository _productRepository;

    public ReviewService(
        IReviewRepository reviewRepository,
        IProductRepository productRepository)
    {
        _reviewRepository = reviewRepository;
        _productRepository = productRepository;
    }

    public async Task<List<ReviewResponseDto>> GetApprovedByProductIdAsync(
        int productId)
    {
        return (await _reviewRepository.GetApprovedByProductIdAsync(productId))
            .Select(Map)
            .ToList();
    }

    public async Task<List<ReviewResponseDto>> GetAllAsync()
    {
        return (await _reviewRepository.GetAllAsync())
            .Select(Map)
            .ToList();
    }

    public async Task<ReviewResponseDto> CreateAsync(
        int userId,
        CreateReviewDto dto)
    {
        if (dto.Rating < 1 || dto.Rating > 5)
        {
            throw new ArgumentException("Rating must be between 1 and 5.");
        }

        if (string.IsNullOrWhiteSpace(dto.Comment) ||
            dto.Comment.Trim().Length < 3)
        {
            throw new ArgumentException(
                "Review comment must be at least 3 characters.");
        }

        if (dto.Comment.Trim().Length > 1000)
        {
            throw new ArgumentException(
                "Review comment cannot exceed 1000 characters.");
        }

        var product = await _productRepository.GetByIdAsync(dto.ProductId);

        if (product == null)
        {
            throw new ArgumentException("Product not found.");
        }

        if (await _reviewRepository.HasUserReviewedProductAsync(
                userId,
                dto.ProductId))
        {
            throw new ArgumentException(
                "You have already submitted a review for this product.");
        }

        var review = await _reviewRepository.CreateAsync(
            new Review
            {
                UserId = userId,
                ProductId = dto.ProductId,
                Rating = dto.Rating,
                Comment = dto.Comment.Trim(),
                Status = "Pending",
                CreatedAt = DateTime.UtcNow
            });

        review.User = new User
        {
            Id = userId,
            Name = "You"
        };
        review.Product = product;

        return Map(review);
    }

    public async Task<bool> ModerateAsync(int id, string status)
    {
        if (status is not ("Approved" or "Rejected"))
        {
            throw new ArgumentException(
                "Review status must be Approved or Rejected.");
        }

        var review = await _reviewRepository.GetByIdAsync(id);

        if (review == null)
        {
            return false;
        }

        review.Status = status;
        await _reviewRepository.UpdateAsync(review);
        return true;
    }

    public Task<bool> DeleteAsync(int id)
    {
        return _reviewRepository.DeleteAsync(id);
    }

    private static ReviewResponseDto Map(Review review)
    {
        return new ReviewResponseDto
        {
            Id = review.Id,
            ProductId = review.ProductId,
            ProductName = review.Product?.Name ?? string.Empty,
            UserId = review.UserId,
            UserName = review.User?.Name ?? "User",
            Rating = review.Rating,
            Comment = review.Comment,
            Status = review.Status,
            CreatedAt = review.CreatedAt
        };
    }
}
