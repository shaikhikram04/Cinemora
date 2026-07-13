// Validate BEFORE requiring the SDK: cloudinary parses CLOUDINARY_URL at import
// time and dies with a bare "TypeError: Invalid URL" that names neither the
// variable nor what's wrong with it.
const url = process.env.CLOUDINARY_URL;

const HINT =
  "Set it in backend/.env — copy the value verbatim from your Cloudinary " +
  "dashboard (Account Details → 'API environment variable'). " +
  "It looks like cloudinary://123456789012345:abcdefg_hijklmnop@my-cloud";

if (!url) {
  throw new Error(`CLOUDINARY_URL is not set — profile image uploads cannot work. ${HINT}`);
}

// Catches the placeholder being pasted through with its angle brackets intact,
// which is otherwise an unhelpful crash deep inside the SDK.
if (/[<>]/.test(url)) {
  throw new Error(
    `CLOUDINARY_URL still contains the <placeholder> brackets — replace them with your real credentials. ${HINT}`
  );
}

if (!/^cloudinary:\/\/[^:]+:[^@]+@.+$/.test(url)) {
  throw new Error(`CLOUDINARY_URL is malformed. ${HINT}`);
}

const cloudinary = require("cloudinary").v2;

/**
 * Uploads a buffer and resolves with the Cloudinary result. `public_id` is the
 * user's id, so re-uploading overwrites the previous image rather than leaving
 * an orphan behind. The returned secure_url carries a version segment, which
 * changes on every overwrite and so busts the CDN cache for us.
 */
const uploadBuffer = (buffer, options) =>
  new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { resource_type: "image", overwrite: true, invalidate: true, ...options },
      (err, result) => (err ? reject(err) : resolve(result))
    );
    stream.end(buffer);
  });

module.exports = { cloudinary, uploadBuffer };
