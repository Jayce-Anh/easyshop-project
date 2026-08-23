const TOKEN_MAX_AGE = 30 * 24 * 60 * 60;

export function createCookies(token: string) {
  document.cookie = `token=${encodeURIComponent(token)}; path=/; max-age=${TOKEN_MAX_AGE}; samesite=lax`;
}

export function removeCookies() {
  document.cookie = "token=; path=/; max-age=0";
}

export function getCookies(name: string) {
  const prefix = `${name}=`;
  const match = document.cookie
    .split(";")
    .map((part) => part.trim())
    .find((part) => part.startsWith(prefix));
  return match ? decodeURIComponent(match.slice(prefix.length)) : null;
}

export function authenticated() {
  return !!getCookies("token");
}
