/// Where Help & Support actually sends people.
///
/// Kept here rather than inline so there is one place to change when the real
/// inbox and store listings exist.
class SupportContact {
  const SupportContact._();

  /// TODO: replace with the real support inbox before release. Every action on
  /// the Help & Support screen opens a mail composer addressed to this.
  static const email = 'support@cinemora.app';

  /// Apple's numeric App Store id, available once the app has a listing.
  /// Empty means "no iOS listing yet" and the Rate App action says so rather
  /// than opening a broken link.
  static const appStoreId = '';

  /// The Play Store link is built from the running package id at runtime, so
  /// it can't drift from the installed build.
  static String playStoreUrl(String packageName) =>
      'https://play.google.com/store/apps/details?id=$packageName';

  static String appStoreUrl() =>
      'https://apps.apple.com/app/id$appStoreId';
}
