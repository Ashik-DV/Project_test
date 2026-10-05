import axios from "axios";

const API_URL = "http://api.ashik.test/api/Order";

const getAuthConfig = () =>
{
    return {
        headers: {
            Authorization:
                "Bearer " + localStorage.getItem("token")
        }
    };
};

export const getMyOrders = async () =>
{
    const response = await axios.get(
        API_URL,
        getAuthConfig()
    );

    return response.data;
};

export const getMyOrderById = async (id) =>
{
    const response = await axios.get(
        `${API_URL}/${id}`,
        getAuthConfig()
    );

    return response.data;
};