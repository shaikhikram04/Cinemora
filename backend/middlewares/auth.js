const jwt = require("jsonwebtoken");
const AppError = require("../utils/AppError");

const auth = (req, res, next) => {
  const header = req.headers.authorization;
  if (!header || !header.startsWith("Bearer ")) {
    return next(new AppError(401, "AUTH_NO_TOKEN", "No token provided"));
  }

  const token = header.slice(7);
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    next(new AppError(401, "AUTH_TOKEN_EXPIRED", "Invalid or expired token"));
  }
};

module.exports = auth;
