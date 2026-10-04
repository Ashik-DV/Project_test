using ECommerceBackend.DTOs.Review;

namespace ECommerceBackend.Services.Interfaces;

public interface IReviewService
{
    Task<List<ReviewResponseDto>> GetApprovedByProductIdAsync(int productId);

    Task<List<ReviewResponseDto>> GetAllAsync();

    Task<ReviewResponseDto> CreateAsync(int userId, CreateReviewDto dto);

    Task<bool> ModerateAsync(int id, string status);

    Task<bool> DeleteAsync(int id);
}
