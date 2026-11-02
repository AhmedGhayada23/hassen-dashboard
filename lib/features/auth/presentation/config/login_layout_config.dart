/// Login layout, in fixed logical pixels as the original screen: unlike the
/// desktop dashboard pages it must stay readable on phones, where ScreenUtil's
/// 1440-wide design scale would shrink it to a fraction.
class LoginLayoutConfig {
  LoginLayoutConfig._();

  /// The brand panel shows from this window width up.
  static const brandPanelMinWidth = 960.0;
  static const formMaxWidth = 400.0;
  static const formPadding = 32.0;
  static const brandPanelFlex = 5;
  static const formFlex = 4;
}
