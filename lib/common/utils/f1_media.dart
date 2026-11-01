class F1Media {
  const F1Media._();

  static const Map<String, String> defaultHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
  };

  static const Map<String, String> _localDriverAssets = {
    'antonelli': 'assets/images/antonnelii.png',
    'andrea_kimi_antonelli': 'assets/images/antonnelii.png',
    'russell': 'assets/images/RUS.png',
    'george_russell': 'assets/images/RUS.png',
    'hamilton': 'assets/images/HAM.png',
    'lewis_hamilton': 'assets/images/HAM.png',
    'verstappen': 'assets/images/VER.png',
    'norris': 'assets/images/NOR.png',
    'leclerc': 'assets/images/LEC.png',
    'piastri': 'assets/images/PIA.png',
    'lawson': 'assets/images/LAW.png',
    'hadjar': 'assets/images/HAD.png',
    'lindblad': 'assets/images/LIN.png',
    'colapinto': 'assets/images/COL.png',
    'gasly': 'assets/images/GAS.png',
    'bearman': 'assets/images/BEA.png',
    'hulkenberg': 'assets/images/HUL.png',
    'bortoleto': 'assets/images/BOR.png',
    'ocon': 'assets/images/OCO.png',
    'alonso': 'assets/images/ALO.png',
    'sainz': 'assets/images/SAI.png',
    'albon': 'assets/images/ALB.png',
    'tsunoda': 'assets/images/TSU.png',
    'stroll': 'assets/images/STR.png',
    'bottas': 'assets/images/BOT.png',
    'perez': 'assets/images/PER.png',
    'hirakawa': 'assets/images/HIR.png',
  };

  static String? getLocalAssetPath(String driverId) {
    final key = driverId.toLowerCase().replaceAll('-', '_');
    if (_localDriverAssets.containsKey(key)) {
      return _localDriverAssets[key];
    }
    final short = key.contains('_') ? key.split('_').last : key;
    return _localDriverAssets[short];
  }

  static String getDriverImageUrl(String driverId) {
    final key = driverId.toLowerCase().replaceAll('-', '_');
    final short = key.contains('_') ? key.split('_').last : key;
    return 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/2025Drivers/$short.png';
  }
}