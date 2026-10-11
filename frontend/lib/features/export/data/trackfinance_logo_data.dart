import 'dart:io';

/// SVG logo resmi TrackFinance dari `/Users/heru/Downloads/trackfinance-logo.svg`
class TrackFinanceLogoData {
  static const String defaultSvg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
<defs>
<linearGradient id="tfbg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#4F8EF8"/><stop offset=".55" stop-color="#2563EB"/><stop offset="1" stop-color="#1E3A8A"/></linearGradient>
<radialGradient id="tfhl" cx=".25" cy=".18" r=".65"><stop offset="0" stop-color="#fff" stop-opacity=".38"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient>
<linearGradient id="tfw" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#D3E2FF"/></linearGradient>
<linearGradient id="tfb" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#B9CFFA"/></linearGradient>
<linearGradient id="tfg" x1="0" y1="1" x2="1" y2="0"><stop offset="0" stop-color="#22C55E"/><stop offset="1" stop-color="#86EFAC"/></linearGradient>
<clipPath id="tfwc"><rect x="212" y="450" width="600" height="380" rx="112"/></clipPath>
<filter id="tfsh" x="-30%" y="-30%" width="160%" height="170%"><feDropShadow dx="0" dy="22" stdDeviation="20" flood-color="#0B1F6B" flood-opacity=".38"/></filter>
</defs>
<rect width="1024" height="1024" rx="230" fill="url(#tfbg)"/>
<rect width="1024" height="1024" fill="url(#tfhl)"/>
<g transform="translate(0 24)">
<g filter="url(#tfsh)">
<rect x="296" y="400" width="84" height="200" rx="42" fill="url(#tfb)"/>
<rect x="430" y="340" width="84" height="260" rx="42" fill="url(#tfb)"/>
<rect x="564" y="280" width="84" height="320" rx="42" fill="url(#tfb)"/>
</g>
<g filter="url(#tfsh)" fill="none" stroke="url(#tfg)" stroke-width="40" stroke-linecap="round" stroke-linejoin="round">
<path d="M236 318L380 238L476 292L752 118"/>
<path d="M690 114H756V180"/>
</g>
<g filter="url(#tfsh)"><rect x="212" y="450" width="600" height="380" rx="112" fill="url(#tfw)"/></g>
<g clip-path="url(#tfwc)"><rect x="212" y="450" width="600" height="116" fill="#EDF1FA"/></g>
<line x1="290" y1="772" x2="590" y2="772" stroke="#B6C6E8" stroke-width="10" stroke-dasharray="30 26" stroke-linecap="round"/>
<g filter="url(#tfsh)"><rect x="636" y="568" width="236" height="188" rx="76" fill="#fff"/></g>
<circle cx="754" cy="662" r="52" fill="#2563EB"/>
<circle cx="754" cy="662" r="26" fill="#1E3A8A"/>
<circle cx="736" cy="642" r="10" fill="#fff" opacity=".9"/>
</g>
</svg>''';

  /// Membaca string SVG dari path unduhan pengguna, file lokal aset, atau fallback ke default
  static String loadSvg() {
    try {
      const userDownloadPath = '/Users/heru/Downloads/trackfinance-logo.svg';
      final file = File(userDownloadPath);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.trim().isNotEmpty) return content;
      }
    } catch (_) {}

    try {
      final assetFile = File('assets/icons/trackfinance-logo.svg');
      if (assetFile.existsSync()) {
        final content = assetFile.readAsStringSync();
        if (content.trim().isNotEmpty) return content;
      }
    } catch (_) {}

    return defaultSvg;
  }
}
