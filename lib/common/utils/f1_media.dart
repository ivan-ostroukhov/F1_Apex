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

  static String getTrackAssetPath(String circuitId) {
    final key = circuitId.toLowerCase().replaceAll('-', '_');
    return 'assets/images/tracks/$key.png';
  }

  static String get2DTrackAssetPath(String circuitId) {
    final key = circuitId.toLowerCase().replaceAll('-', '_');
    return 'assets/images/2d_track/$key.png';
  }

  static String getCarAssetPath(String constructorId) {
    final key = constructorId.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_').trim();
    if (key.contains('red_bull') || key.contains('redbull')) return 'assets/images/cars/red_bull.png';
    if (key.contains('ferrari')) return 'assets/images/cars/ferrari.png';
    if (key.contains('mercedes')) return 'assets/images/cars/mercedes.png';
    if (key.contains('mclaren')) return 'assets/images/cars/mclaren.png';
    if (key.contains('aston')) return 'assets/images/cars/aston_martin.png';
    if (key.contains('alpine')) return 'assets/images/cars/alpine.png';
    if (key.contains('williams')) return 'assets/images/cars/williams.png';
    if (key.contains('haas')) return 'assets/images/cars/haas.png';
    if (key.contains('rb') || key.contains('racing_bulls') || key.contains('vcarb')) return 'assets/images/cars/racing_bulls.png';
    if (key.contains('sauber') || key.contains('kick') || key.contains('stake')) return 'assets/images/cars/sauber.png';
    return 'assets/images/cars/$key.png';
  }
}