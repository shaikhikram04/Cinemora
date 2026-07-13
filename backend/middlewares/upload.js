const multer = require("multer");
const AppError = require("../utils/AppError");

const MAX_BYTES = 5 * 1024 * 1024;
const ALLOWED = ["image/jpeg", "image/png", "image/webp"];

// Buffered in memory, never written to disk — the file goes straight on to
// Cloudinary and is discarded. Fine at a 5 MB cap.
const multerUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_BYTES, files: 1 },
  fileFilter: (req, file, cb) => {
    if (!ALLOWED.includes(file.mimetype)) {
      return cb(
        new AppError(400, "IMAGE_INVALID_TYPE", "Image must be a JPEG, PNG or WebP")
      );
    }
    cb(null, true);
  },
});

// Multer throws MulterError, which has no `status`/`code` the global handler
// understands and would otherwise surface as a generic 500.
const singleImage = (field) => (req, res, next) =>
  multerUpload.single(field)(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      return next(
        err.code === "LIMIT_FILE_SIZE"
          ? new AppError(413, "IMAGE_TOO_LARGE", "Image must be under 5 MB")
          : new AppError(400, "IMAGE_UPLOAD_FAILED", err.message)
      );
    }
    if (err) return next(err);
    if (!req.file) {
      return next(new AppError(400, "IMAGE_REQUIRED", "No image was uploaded"));
    }
    next();
  });

module.exports = { singleImage };
