import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { toast } from "react-hot-toast";
import { getProductById } from "../services/productService";
import {
    createReview,
    getProductReviews
} from "../services/reviewService";
import {
    getImageUrl,
    IMAGE_FALLBACK
} from "../utils/imageUrl";

function ProductDetails()
{
    const { id } = useParams();
    const navigate = useNavigate();
    const [product, setProduct] = useState(null);
    const [reviews, setReviews] = useState([]);
    const [loading, setLoading] = useState(true);
    const [rating, setRating] = useState(5);
    const [comment, setComment] = useState("");
    const [submitting, setSubmitting] = useState(false);
    const currentUser = (() =>
    {
        try
        {
            return JSON.parse(localStorage.getItem("user") || "null");
        }
        catch
        {
            return null;
        }
    })();

    const isAdmin = currentUser?.role?.toLowerCase() === "admin";

    useEffect(() =>
    {
        const loadDetails = async () =>
        {
            try
            {
                setLoading(true);
                const [productData, reviewData] = await Promise.all([
                    getProductById(id),
                    getProductReviews(id)
                ]);
                setProduct(productData);
                setReviews(reviewData);
            }
            catch (error)
            {
                console.error("Unable to load product details", error);
                toast.error("Unable to load product details.");
            }
            finally
            {
                setLoading(false);
            }
        };

        loadDetails();
    }, [id]);

    const handleSubmit = async (event) =>
    {
        event.preventDefault();

        try
        {
            setSubmitting(true);
            await createReview({
                productId: Number(id),
                rating: Number(rating),
                comment
            });
            setComment("");
            setRating(5);
            toast.success(
                "Review submitted and is waiting for admin approval."
            );
        }
        catch (error)
        {
            toast.error(
                error.response?.data?.message ||
                "Unable to submit review."
            );
        }
        finally
        {
            setSubmitting(false);
        }
    };

    if (loading)
    {
        return <div className="product-details-page"><div className="loading">Loading product...</div></div>;
    }

    if (!product)
    {
        return (
            <div className="product-details-page">
                <div className="empty-state">
                    <h2>Product not found</h2>
                    <button
                        type="button"
                        className="primary-button"
                        onClick={() => navigate("/products")}
                    >
                        Back to Products
                    </button>
                </div>
            </div>
        );
    }

    return (
        <div className="product-details-page">
            <div className="product-details-container">
                <button
                    type="button"
                    className="back-link-button"
                    onClick={() => navigate("/products")}
                >
                    ← Back to Products
                </button>

                <section className="product-details-card">
                    <div className="product-details-image">
                        <img
                            src={getImageUrl(product.imageUrl) || IMAGE_FALLBACK}
                            alt={product.name}
                            onError={event =>
                            {
                                event.currentTarget.onerror = null;
                                event.currentTarget.src = IMAGE_FALLBACK;
                            }}
                        />
                    </div>

                    <div className="product-details-content">
                        <span className="product-details-label">
                            {product.category || "Featured Product"}
                        </span>
                        <h1>{product.name}</h1>
                        <div className="product-details-price">
                            ₹{Number(product.price).toLocaleString("en-IN")}
                        </div>
                        <p>{product.description}</p>
                        <div className="product-details-meta">
                            <span>Brand: {product.brand || "—"}</span>
                            <span>Stock: {product.stockQuantity}</span>
                        </div>
                    </div>
                </section>

                <section className="reviews-section">
                    <div className="reviews-section-heading">
                        <div>
                            <span className="product-details-label">Community</span>
                            <h2>Customer reviews</h2>
                        </div>
                        <span>{reviews.length} approved review{reviews.length === 1 ? "" : "s"}</span>
                    </div>

                    <div className="reviews-layout">
                        <div className="approved-reviews">
                            {reviews.length === 0 ? (
                                <div className="no-reviews-panel">
                                    No approved reviews yet. Be the first to share your experience.
                                </div>
                            ) : (
                                reviews.map(review => (
                                    <article className="review-detail-card" key={review.id}>
                                        <div className="review-detail-header">
                                            <div>
                                                <strong>{review.userName}</strong>
                                                <small>
                                                    {new Date(review.createdAt).toLocaleDateString()}
                                                </small>
                                            </div>
                                            <span className="review-stars">
                                                {"★".repeat(review.rating)}
                                                {"☆".repeat(5 - review.rating)}
                                            </span>
                                        </div>
                                        <p>{review.comment}</p>
                                    </article>
                                ))
                            )}
                        </div>

                        {!isAdmin && (
                            <form className="review-detail-form" onSubmit={handleSubmit}>
                                <h3>Write a review</h3>
                                <p>Your review will be visible after admin approval.</p>

                                <label htmlFor="review-rating">Your rating</label>
                                <select
                                    id="review-rating"
                                    value={rating}
                                    onChange={event => setRating(event.target.value)}
                                >
                                    <option value="5">★★★★★ 5 stars</option>
                                    <option value="4">★★★★☆ 4 stars</option>
                                    <option value="3">★★★☆☆ 3 stars</option>
                                    <option value="2">★★☆☆☆ 2 stars</option>
                                    <option value="1">★☆☆☆☆ 1 star</option>
                                </select>

                                <label htmlFor="review-comment">Your experience</label>
                                <textarea
                                    id="review-comment"
                                    value={comment}
                                    onChange={event => setComment(event.target.value)}
                                    placeholder="Tell other shoppers what you think..."
                                    minLength="3"
                                    maxLength="1000"
                                    required
                                />

                                <button
                                    type="submit"
                                    className="primary-button"
                                    disabled={submitting}
                                >
                                    {submitting ? "Submitting..." : "Submit Review"}
                                </button>
                            </form>
                        )}
                    </div>
                </section>
            </div>
        </div>
    );
}

export default ProductDetails;
