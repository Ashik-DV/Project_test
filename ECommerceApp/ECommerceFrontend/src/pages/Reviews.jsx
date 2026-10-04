import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { toast } from "react-hot-toast";
import {
    deleteReview,
    getAllReviews,
    moderateReview
} from "../services/reviewService";

function Reviews()
{
    const navigate = useNavigate();
    const [reviews, setReviews] = useState([]);
    const [loading, setLoading] = useState(true);

    const loadReviews = async () =>
    {
        try
        {
            setLoading(true);
            setReviews(await getAllReviews());
        }
        catch (error)
        {
            console.error("Unable to load reviews", error);
            toast.error("Unable to load reviews.");
        }
        finally
        {
            setLoading(false);
        }
    };

    useEffect(() =>
    {
        const timer = setTimeout(() =>
        {
            loadReviews();
        }, 0);

        return () => clearTimeout(timer);
    }, []);

    const handleModerate = async (review, status) =>
    {
        try
        {
            await moderateReview(review.id, status);
            toast.success(`Review ${status.toLowerCase()}.`);
            await loadReviews();
        }
        catch (error)
        {
            console.error("Unable to moderate review", error);
            toast.error("Unable to update review.");
        }
    };

    const handleDelete = async (review) =>
    {
        if (!window.confirm("Delete this review permanently?"))
        {
            return;
        }

        try
        {
            await deleteReview(review.id);
            setReviews(previous =>
                previous.filter(item => item.id !== review.id)
            );
            toast.success("Review deleted.");
        }
        catch (error)
        {
            console.error("Unable to delete review", error);
            toast.error("Unable to delete review.");
        }
    };

    return (
        <div className="dashboard">
            <header className="dashboard-header">
                <div>
                    <h1>Review Management</h1>
                    <p>Approve or reject customer reviews.</p>
                </div>

                <button
                    type="button"
                    className="secondary-button"
                    onClick={() => navigate("/admin")}
                >
                    Back to Dashboard
                </button>
            </header>

            <main className="dashboard-main reviews-admin-page">
                {loading ? (
                    <div className="loading">Loading reviews...</div>
                ) : reviews.length === 0 ? (
                    <div className="empty-state">
                        No reviews have been submitted yet.
                    </div>
                ) : (
                    <div className="admin-review-list">
                        {reviews.map(review => (
                            <article
                                className="admin-review-card"
                                key={review.id}
                            >
                                <div className="admin-review-heading">
                                    <div>
                                        <h2>{review.productName}</h2>
                                        <span>
                                            By {review.userName} •{" "}
                                            {new Date(review.createdAt)
                                                .toLocaleDateString()}
                                        </span>
                                    </div>
                                    <strong
                                        className={`review-status ${review.status.toLowerCase()}`}
                                    >
                                        {review.status}
                                    </strong>
                                </div>

                                <div className="review-stars">
                                    {"★".repeat(review.rating)}
                                    {"☆".repeat(5 - review.rating)}
                                </div>

                                <p>{review.comment}</p>

                                <div className="review-admin-actions">
                                    {review.status !== "Approved" && (
                                        <button
                                            type="button"
                                            className="primary-button"
                                            onClick={() =>
                                                handleModerate(
                                                    review,
                                                    "Approved"
                                                )
                                            }
                                        >
                                            Approve
                                        </button>
                                    )}

                                    {review.status !== "Rejected" && (
                                        <button
                                            type="button"
                                            className="secondary-button"
                                            onClick={() =>
                                                handleModerate(
                                                    review,
                                                    "Rejected"
                                                )
                                            }
                                        >
                                            Reject
                                        </button>
                                    )}

                                    <button
                                        type="button"
                                        className="delete-button"
                                        onClick={() => handleDelete(review)}
                                    >
                                        Delete
                                    </button>
                                </div>
                            </article>
                        ))}
                    </div>
                )}
            </main>
        </div>
    );
}

export default Reviews;
