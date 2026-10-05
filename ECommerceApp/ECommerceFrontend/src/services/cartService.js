import axios from "axios";

const API_URL = "http://api.ashik.test/api/Cart";

const getAuthHeaders = () =>
{
const token =
localStorage.getItem("token");

return {
    headers: {
        Authorization: "Bearer " + token
    }
};

};

export const getCart = async () =>
{
const response =
await axios.get(
API_URL,
getAuthHeaders()
);

return response.data;

};

export const addToCart = async (
productId,
quantity = 1
) =>
{
const response =
await axios.post(
API_URL,
{
productId: productId,
quantity: quantity
},
getAuthHeaders()
);

return response.data;

};

export const updateCartItem = async (
cartItemId,
quantity
) =>
{
const response =
await axios.put(
API_URL + "/" + cartItemId,
{
quantity: quantity
},
getAuthHeaders()
);

return response.data;

};

export const removeCartItem = async (
cartItemId
) =>
{
const response =
await axios.delete(
API_URL + "/" + cartItemId,
getAuthHeaders()
);

return response.data;

};

export const clearCart = async () =>
{
const response =
await axios.delete(
API_URL,
getAuthHeaders()
);

return response.data;

};