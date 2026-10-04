import { useEffect, useState } from "react";
import { ThemeContext } from "./theme-context";

export function ThemeProvider({ children }) {
const [isDark, setIsDark] = useState(() => {
const saved = localStorage.getItem("theme");

if (saved) {
  return saved === "dark";
}

return window.matchMedia("(prefers-color-scheme: dark)").matches;

});

useEffect(() => {
document.documentElement.setAttribute(
"data-theme",
isDark ? "dark" : "light"
);

localStorage.setItem("theme", isDark ? "dark" : "light");

}, [isDark]);

const toggleTheme = () => {
setIsDark((prev) => !prev);
};

return (
<ThemeContext.Provider value={{ isDark, toggleTheme }}>
{children}
</ThemeContext.Provider>
);
}