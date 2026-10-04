import axios from "axios";

const API_URL = "http://localhost:5208/api/Reviews";

const getAuthConfig = () => ({
    headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`
    }
});

export const getProductReviews = async (productId) => {
    const response = await axios.get(
        `${API_URL}/product/${productId}`,
        getAuthConfig()
    );

    return response.data;
};

export const createReview = async (review) => {
    const response = await axios.post(
        API_URL,
        review,
        getAuthConfig()
    );

    return response.data;
};

export const getAllReviews = async () => {
    const response = await axios.get(
        `${API_URL}/admin`,
        getAuthConfig()
    );

    return response.data;
};

export const moderateReview = async (id, status) => {
    const response = await axios.put(
        `${API_URL}/${id}/status`,
        status,
        {
            ...getAuthConfig(),
            headers: {
                ...getAuthConfig().headers,
                "Content-Type": "application/json"
            }
        }
    );

    return response.data;
};

export const deleteReview = async (id) => {
    await axios.delete(
        `${API_URL}/${id}`,
        getAuthConfig()
    );
};
