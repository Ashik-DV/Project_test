using ECommerceBackend.Data;
using ECommerceBackend.Models;
using ECommerceBackend.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ECommerceBackend.Repositories;

public class ReviewRepository : IReviewRepository
{
    private readonly AppDbContext _context;

    public ReviewRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<List<Review>> GetApprovedByProductIdAsync(int productId)
    {
        return _context.Reviews
            .AsNoTracking()
            .Include(review => review.User)
            .Include(review => review.Product)
            .Where(review =>
                review.ProductId == productId &&
                review.Status == "Approved")
            .OrderByDescending(review => review.CreatedAt)
            .ToListAsync();
    }

    public Task<List<Review>> GetAllAsync()
    {
        return _context.Reviews
            .AsNoTracking()
            .Include(review => review.User)
            .Include(review => review.Product)
            .OrderByDescending(review => review.CreatedAt)
            .ToListAsync();
    }

    public Task<Review?> GetByIdAsync(int id)
    {
        return _context.Reviews
            .FirstOrDefaultAsync(review => review.Id == id);
    }

    public Task<bool> HasUserReviewedProductAsync(int userId, int productId)
    {
        return _context.Reviews.AnyAsync(review =>
            review.UserId == userId &&
            review.ProductId == productId &&
            review.Status != "Rejected");
    }

    public async Task<Review> CreateAsync(Review review)
    {
        _context.Reviews.Add(review);
        await _context.SaveChangesAsync();
        return review;
    }

    public async Task<Review> UpdateAsync(Review review)
    {
        _context.Reviews.Update(review);
        await _context.SaveChangesAsync();
        return review;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var review = await _context.Reviews.FindAsync(id);

        if (review == null)
        {
            return false;
        }

        _context.Reviews.Remove(review);
        await _context.SaveChangesAsync();
        return true;
    }
}
