const AppError = require("../utils/AppError");

/**
 * Route-param guards for the endpoints that interpolate a param into an
 * upstream URL (TMDB, Jikan, the recommender).
 *
 * This is not cosmetic validation. Express decodes %2F inside a path segment,
 * so `/api/tmdb/movie/..%2F..%2Faccount` yields `req.params.id === "../../account"`.
 * Axios builds its request URL by concatenating baseURL + path, and Node's URL
 * parser then normalises the `..` segments away — so the call that was meant
 * for `/3/movie/:id` lands on `https://api.themoviedb.org/account`, still
 * carrying our api_key. Same shape reaches Jikan, and for the recommender it
 * would reach arbitrary /internal/* routes with the internal secret attached.
 *
 * Constraining the param to the characters it is actually allowed to contain
 * closes that off at the routing layer, before any handler can build a URL.
 */

/** Registered via `router.param(name, numericParam)`. */
const numericParam = (req, res, next, value, name) => {
  if (!/^\d+$/.test(value)) {
    return next(
      new AppError(400, "PARAM_INVALID", `${name} must be a positive integer`),
    );
  }
  next();
};

/** Builds a `router.param` handler restricting a param to a fixed set. */
const enumParam = (allowed) => {
  const permitted = new Set(allowed);
  return (req, res, next, value, name) => {
    if (!permitted.has(value)) {
      return next(
        new AppError(
          400,
          "PARAM_INVALID",
          `${name} must be one of: ${allowed.join(", ")}`,
        ),
      );
    }
    next();
  };
};

module.exports = { numericParam, enumParam };
