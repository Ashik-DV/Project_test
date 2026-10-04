import {
    Navigate,
    useLocation
} from "react-router-dom";

function ProtectedRoute({
children,
allowedRole
})
{
const location = useLocation();

const token =
localStorage.getItem("token");

const userData =
    localStorage.getItem("user");


if (!token)
{
    return (
        <Navigate
            to="/login"
            state={{
                from: location.pathname
            }}
            replace
        />
    );
}


let user;

try
{
    user = userData
        ? JSON.parse(userData)
        : null;
}
catch
{
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    user = null;
}


if (!user)
{
    localStorage.removeItem("token");

    return (
        <Navigate
            to="/login"
            state={{
                from: location.pathname
            }}
            replace
        />
    );
}


if (
    allowedRole &&
    user.role?.toLowerCase() !==
        allowedRole.toLowerCase()
)
{
    if (
        user.role?.toLowerCase() ===
        "admin"
    )
    {
        return (
            <Navigate
                to="/admin"
                replace
            />
        );
    }


    return (
        <Navigate
            to="/user"
            replace
        />
    );
}


return children;

}

export default ProtectedRoute;