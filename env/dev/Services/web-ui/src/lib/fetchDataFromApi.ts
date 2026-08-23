import axios from "axios";

// In microservice mode, all API calls go through the API gateway (nginx / AWS API Gateway)
const baseURL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';

// Add request interceptor to include token
export const axiosInstance = axios.create({
  baseURL,
  headers: {
    "Content-Type": "application/json",
  },
  withCredentials: true, // Important for sending cookies
});

// Add request interceptor to include token from cookie
const readToken = () => {
  if (typeof document === "undefined") return null;
  const tokenCookie = document.cookie
    .split(";")
    .find((cookie) => cookie.trim().startsWith("token="));
  return tokenCookie ? decodeURIComponent(tokenCookie.split("=")[1].trim()) : null;
};

axiosInstance.interceptors.request.use(
  async (config) => {
    const token = readToken();

    // If token exists, add it to headers
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }

    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export const getApiUrl = (path: string) => `${baseURL}${path}`;

const fetchData = {
  get: async (url: string, params = {}) => {
    try {
      const token = readToken();

      const config = {
        params,
        headers: token ? { 'Authorization': `Bearer ${token}` } : {}
      };

      console.log('Making GET request with config:', { url, config });
      const response = await axiosInstance.get(url, config);
      return response;
    } catch (error) {
      console.error("Error fetching data:", error);
      throw error;
    }
  },
  post: async (url: string, data = {}) => {
    try {
      const token = readToken();

      const config = {
        headers: token ? { 'Authorization': `Bearer ${token}` } : {}
      };

      console.log('Making POST request with config:', { url, data, config });
      const response = await axiosInstance.post(url, data, config);
      return response;
    } catch (error) {
      console.error("Error posting data:", error);
      throw error;
    }
  },
};

export default fetchData;
