/**
 * Creates an IP-based sliding-window rate limiter middleware.
 * @param {number} maxRequests - Max requests allowed per window.
 * @param {number} windowMs   - Window duration in milliseconds.
 */
const rateLimiter = (maxRequests, windowMs) => {
  const store = new Map(); // ip → { count, windowStart }

  // Sweep stale entries once per window to prevent unbounded growth.
  setInterval(() => {
    const cutoff = Date.now() - windowMs;
    for (const [ip, entry] of store) {
      if (entry.windowStart < cutoff) store.delete(ip);
    }
  }, windowMs).unref();

  return (req, res, next) => {
    const ip = req.ip ?? req.socket?.remoteAddress ?? 'unknown';
    const now = Date.now();
    const entry = store.get(ip);

    if (!entry || now - entry.windowStart > windowMs) {
      store.set(ip, { count: 1, windowStart: now });
      return next();
    }

    if (entry.count >= maxRequests) {
      return res.status(429).json({
        error: {
          code: 'RATE_LIMIT_EXCEEDED',
          message: 'Too many requests — please slow down.',
        },
      });
    }

    entry.count++;
    return next();
  };
};

module.exports = rateLimiter;
