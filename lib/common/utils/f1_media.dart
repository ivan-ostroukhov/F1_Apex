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

  static String _normalizeCircuitKey(String circuitId) {
    var key = circuitId.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_').trim();

    key = key
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ü', 'u');

    if (key.contains('madring') || key.contains('madrid')) return 'madrid';
    if (key.contains('vegas') || key.contains('las_vegas')) return 'las_vegas';
    if (key.contains('spain') || key.contains('catalunya')) return 'catalunya';
    if (key.contains('sepang') || key.contains('malaysia')) return 'bahrain';
    if (key.contains('americas') || key.contains('cota') || key.contains('austin') || key.contains('usa')) return 'americas';
    if (key.contains('sao_paulo') || key.contains('paulo') || key.contains('brazil') || key.contains('interlagos') || key.contains('pace')) return 'interlagos';
    if (key.contains('albert') || key.contains('australia') || key.contains('melbourne')) return 'albert_park';
    if (key.contains('imola') || key.contains('emilia')) return 'imola';
    if (key.contains('suzuka') || key.contains('japan')) return 'suzuka';
    if (key.contains('shanghai') || key.contains('china')) return 'shanghai';
    if (key.contains('canada') || key.contains('montreal') || key.contains('villeneuve')) return 'villeneuve';
    if (key.contains('mexico') || key.contains('rodriguez') || key.contains('hermanos')) return 'rodriguez';
    if (key.contains('hungaroring') || key.contains('hungary') || key.contains('budapest')) return 'hungaroring';
    if (key.contains('spa') || key.contains('belgium')) return 'spa';
    if (key.contains('zandvoort') || key.contains('dutch')) return 'zandvoort';
    if (key.contains('monza') || key.contains('italy')) return 'monza';
    if (key.contains('baku') || key.contains('azerbaijan')) return 'baku';
    if (key.contains('singapore') || key.contains('marina_bay')) return 'marina_bay';
    if (key.contains('losail') || key.contains('qatar') || key.contains('lusail')) return 'losail';
    if (key.contains('yas_marina') || key.contains('abu_dhabi')) return 'yas_marina';
    if (key.contains('jeddah') || key.contains('saudi')) return 'jeddah';
    if (key.contains('silverstone') || key.contains('britain') || key.contains('uk')) return 'silverstone';
    if (key.contains('monaco') || key.contains('monte_carlo')) return 'monaco';
    if (key.contains('miami')) return 'miami';
    if (key.contains('bahrain') || key.contains('sakhir')) return 'bahrain';

    return key;
  }

  static String getTrackAssetPath(String circuitId) {
    final key = _normalizeCircuitKey(circuitId);
    return 'assets/images/tracks/$key.png';
  }

  static String get2DTrackAssetPath(String circuitId) {
    final key = _normalizeCircuitKey(circuitId);
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
    if (key.contains('sauber') || key.contains('kick') || key.contains('stake')) return 'assets/images/cars/cadillac.png';
    return 'assets/images/cars/$key.png';
  }
}