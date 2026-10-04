using ECommerceBackend.Models;

namespace ECommerceBackend.Repositories.Interfaces;

public interface IReviewRepository
{
    Task<List<Review>> GetApprovedByProductIdAsync(int productId);

    Task<List<Review>> GetAllAsync();

    Task<Review?> GetByIdAsync(int id);

    Task<bool> HasUserReviewedProductAsync(int userId, int productId);

    Task<Review> CreateAsync(Review review);

    Task<Review> UpdateAsync(Review review);

    Task<bool> DeleteAsync(int id);
}
