import 'package:flutter/widgets.dart';

enum ScreenSize { mobile, tablet, desktop }

/// Breakpoint terpusat. Ubah angka di sini, seluruh app ikut berubah.
abstract final class Breakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;

  /// Lebar area konten (bukan layar) di bawah ini -> tabel jadi List of Cards.
  static const double tableToCards = 720;

  static ScreenSize of(double width) {
    if (width >= desktop) return ScreenSize.desktop;
    if (width >= tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }
}

extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => Breakpoints.of(MediaQuery.sizeOf(this).width);
  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isDesktop => screenSize == ScreenSize.desktop;

  /// Padding halaman: 16 (mobile) / 24 (tablet) / 32 (desktop).
  double get pagePadding => switch (screenSize) {
        ScreenSize.mobile => 16,
        ScreenSize.tablet => 24,
        ScreenSize.desktop => 32,
      };
}
