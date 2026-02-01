# 🚀 CryptoFlow - Ek Özellikler Prompt Seti

## 📋 Mevcut Duruma Eklenen Özellikler

| Özellik | Değer | Süre |
|---------|-------|------|
| Push Notifications | 🔴 Yüksek | Promptun var, uygula |
| Biometric Auth | 🔴 Yüksek | 3-4 saat |
| Home Screen Widget | 🔴 Yüksek | 1-2 gün |
| Deep Linking | 🟡 Orta | 3-4 saat |
| App Lock Screen | 🟡 Orta | 2-3 saat |
| Fear & Greed Index | 🟢 Nice | 2-3 saat |
| Onboarding Flow | 🟢 Nice | 3-4 saat |

---

# 🔐 BÖLÜM 1: Biometric Authentication

## PROMPT B1: Biometric Service Setup

```
CryptoFlow'a Biometric Authentication ekle.

Paket: local_auth: ^2.1.8

1. packages/auth/lib/domain/services/biometric_service.dart:

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Cihaz biometric destekliyor mu?
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      return false;
    }
  }

  /// Hangi biometric türleri var?
  Future<List<BiometricType>> getAvailableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate
  Future<BiometricResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final success = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
        ),
      );
      return success ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') return BiometricResult.notAvailable;
      if (e.code == 'NotEnrolled') return BiometricResult.notEnrolled;
      if (e.code == 'LockedOut') return BiometricResult.lockedOut;
      if (e.code == 'PermanentlyLockedOut') return BiometricResult.permanentlyLocked;
      return BiometricResult.error;
    }
  }

  /// Biometric türüne göre ikon
  IconData getIcon(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) return Icons.face;
    if (types.contains(BiometricType.fingerprint)) return Icons.fingerprint;
    return Icons.lock;
  }

  /// Biometric türüne göre label
  String getLabel(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Touch ID';
    return 'Biometric';
  }
}

enum BiometricResult {
  success,
  failed,
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLocked,
  error,
}

2. DI'a ekle:
getIt.registerLazySingleton<BiometricService>(() => BiometricService());
```

---

## PROMPT B2: iOS & Android Native Setup

```
Biometric için native setup:

1. iOS - ios/Runner/Info.plist:
<key>NSFaceIDUsageDescription</key>
<string>CryptoFlow hesabınıza güvenli erişim için Face ID kullanılacak</string>

2. iOS - ios/Podfile:
platform :ios, '11.0'

3. Android - android/app/src/main/AndroidManifest.xml:
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>

4. Android - MainActivity.kt:
// FlutterActivity yerine FlutterFragmentActivity kullan
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
}
```

---

## PROMPT B3: Biometric BLoC

```
packages/auth/lib/presentation/bloc/biometric/

1. biometric_state.dart:
abstract class BiometricState extends Equatable {}

class BiometricInitial extends BiometricState {}
class BiometricChecking extends BiometricState {}
class BiometricAvailable extends BiometricState {
  final List<BiometricType> types;
  final bool isEnabled; // User preference
}
class BiometricNotAvailable extends BiometricState {}
class BiometricAuthenticated extends BiometricState {}
class BiometricFailed extends BiometricState {
  final String message;
}
class BiometricLockedOut extends BiometricState {
  final bool permanent;
}

2. biometric_event.dart:
abstract class BiometricEvent extends Equatable {}

class CheckBiometricAvailability extends BiometricEvent {}
class AuthenticateWithBiometric extends BiometricEvent {
  final String reason;
}
class EnableBiometric extends BiometricEvent {}
class DisableBiometric extends BiometricEvent {}

3. biometric_bloc.dart:
class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  final BiometricService _biometricService;
  final SettingsRepository _settingsRepository;

  BiometricBloc(this._biometricService, this._settingsRepository)
      : super(BiometricInitial()) {
    on<CheckBiometricAvailability>(_onCheck);
    on<AuthenticateWithBiometric>(_onAuthenticate);
    on<EnableBiometric>(_onEnable);
    on<DisableBiometric>(_onDisable);
  }

  Future<void> _onCheck(CheckBiometricAvailability event, Emitter emit) async {
    emit(BiometricChecking());
    
    final isAvailable = await _biometricService.isAvailable();
    if (!isAvailable) {
      emit(BiometricNotAvailable());
      return;
    }
    
    final types = await _biometricService.getAvailableTypes();
    final isEnabled = await _settingsRepository.isBiometricEnabled();
    emit(BiometricAvailable(types: types, isEnabled: isEnabled));
  }

  Future<void> _onAuthenticate(AuthenticateWithBiometric event, Emitter emit) async {
    final result = await _biometricService.authenticate(reason: event.reason);
    
    switch (result) {
      case BiometricResult.success:
        emit(BiometricAuthenticated());
        break;
      case BiometricResult.lockedOut:
        emit(BiometricLockedOut(permanent: false));
        break;
      case BiometricResult.permanentlyLocked:
        emit(BiometricLockedOut(permanent: true));
        break;
      default:
        emit(BiometricFailed(message: 'Doğrulama başarısız'));
    }
  }

  Future<void> _onEnable(EnableBiometric event, Emitter emit) async {
    // Önce doğrula
    final result = await _biometricService.authenticate(
      reason: 'Biometric login\'i aktifleştirmek için doğrulayın',
    );
    
    if (result == BiometricResult.success) {
      await _settingsRepository.setBiometricEnabled(true);
      add(CheckBiometricAvailability());
    }
  }

  Future<void> _onDisable(DisableBiometric event, Emitter emit) async {
    await _settingsRepository.setBiometricEnabled(false);
    add(CheckBiometricAvailability());
  }
}
```

---

## PROMPT B4: App Lock Screen

```
packages/auth/lib/presentation/pages/lock_screen.dart:

class LockScreen extends StatelessWidget {
  final VoidCallback onUnlocked;
  
  const LockScreen({required this.onUnlocked});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BiometricBloc, BiometricState>(
      listener: (context, state) {
        if (state is BiometricAuthenticated) {
          onUnlocked();
        }
        if (state is BiometricFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is BiometricLockedOut) {
          _showLockedDialog(context, state.permanent);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.primaryBackground,
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Icon(
                    Icons.currency_bitcoin,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'CryptoFlow',
                    style: AppTypography.h1,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Devam etmek için kimliğinizi doğrulayın',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 48),
                  
                  // Biometric Button
                  _BiometricButton(
                    onPressed: () {
                      context.read<BiometricBloc>().add(
                        AuthenticateWithBiometric(
                          reason: 'CryptoFlow\'a erişmek için doğrulayın',
                        ),
                      );
                    },
                    isLoading: state is BiometricChecking,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Alternative: PIN/Password
                  TextButton(
                    onPressed: () => _showPinDialog(context),
                    child: Text('PIN ile giriş yap'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLockedDialog(BuildContext context, bool permanent) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('Biometric Kilitlendi'),
        content: Text(
          permanent
              ? 'Çok fazla başarısız deneme. Lütfen cihaz ayarlarından kilidini açın.'
              : 'Çok fazla başarısız deneme. Lütfen biraz bekleyin.',
        ),
        actions: [
          if (permanent)
            TextButton(
              onPressed: () => openAppSettings(),
              child: Text('Ayarları Aç'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

class _BiometricButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiometricBloc, BiometricState>(
      builder: (context, state) {
        IconData icon = Icons.fingerprint;
        String label = 'Doğrula';
        
        if (state is BiometricAvailable) {
          final service = getIt<BiometricService>();
          icon = service.getIcon(state.types);
          label = service.getLabel(state.types);
        }
        
        return ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 28),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
```

---

## PROMPT B5: Settings Entegrasyonu

```
packages/settings/lib/presentation/widgets/biometric_setting_tile.dart:

class BiometricSettingTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiometricBloc, BiometricState>(
      builder: (context, state) {
        if (state is BiometricNotAvailable) {
          return ListTile(
            leading: Icon(Icons.fingerprint, color: AppColors.disabled),
            title: Text('Biometric Login'),
            subtitle: Text('Bu cihazda kullanılamıyor'),
            enabled: false,
          );
        }
        
        if (state is BiometricAvailable) {
          final service = getIt<BiometricService>();
          return SwitchListTile(
            secondary: Icon(service.getIcon(state.types)),
            title: Text('Biometric Login'),
            subtitle: Text('${service.getLabel(state.types)} ile hızlı giriş'),
            value: state.isEnabled,
            onChanged: (value) {
              if (value) {
                context.read<BiometricBloc>().add(EnableBiometric());
              } else {
                context.read<BiometricBloc>().add(DisableBiometric());
              }
            },
          );
        }
        
        return ListTile(
          leading: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('Biometric Login'),
          subtitle: Text('Kontrol ediliyor...'),
        );
      },
    );
  }
}
```

---

## PROMPT B6: App Wrapper Entegrasyonu

```
lib/app.dart - Biometric wrapper ekle:

class CryptoFlowApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [...],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp.router(
            // ... mevcut config
            builder: (context, child) {
              // Biometric guard ekle
              return BiometricGuard(child: child!);
            },
          );
        },
      ),
    );
  }
}

// lib/presentation/widgets/biometric_guard.dart:
class BiometricGuard extends StatefulWidget {
  final Widget child;
  const BiometricGuard({required this.child});

  @override
  State<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends State<BiometricGuard> with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
    }
    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      _checkLockOnResume();
    }
  }

  Future<void> _checkInitialLock() async {
    final settings = getIt<SettingsRepository>();
    final biometricEnabled = await settings.isBiometricEnabled();
    
    if (biometricEnabled) {
      setState(() => _isLocked = true);
    } else {
      setState(() => _isLocked = false);
    }
  }

  Future<void> _checkLockOnResume() async {
    final settings = getIt<SettingsRepository>();
    final biometricEnabled = await settings.isBiometricEnabled();
    final lockOnBackground = await settings.getLockOnBackground();
    
    if (biometricEnabled && lockOnBackground) {
      setState(() => _isLocked = true);
    }
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return LockScreen(onUnlocked: _onUnlocked);
    }
    return widget.child;
  }
}
```

---

# 📱 BÖLÜM 2: Home Screen Widget

## PROMPT W1: Widget Setup (Android)

```
CryptoFlow için Android Home Screen Widget ekle.

Paket: home_widget: ^0.4.1

1. android/app/src/main/res/layout/crypto_widget.xml:
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp"
    android:background="@drawable/widget_background">

    <TextView
        android:id="@+id/widget_title"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="CryptoFlow"
        android:textSize="14sp"
        android:textColor="#888888" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:layout_marginTop="8dp">

        <ImageView
            android:id="@+id/coin_icon"
            android:layout_width="32dp"
            android:layout_height="32dp"
            android:src="@drawable/ic_bitcoin" />

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:layout_marginStart="12dp">

            <TextView
                android:id="@+id/coin_symbol"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="BTC"
                android:textSize="18sp"
                android:textStyle="bold"
                android:textColor="#FFFFFF" />

            <TextView
                android:id="@+id/coin_price"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="$43,250.00"
                android:textSize="16sp"
                android:textColor="#FFFFFF" />
        </LinearLayout>

        <TextView
            android:id="@+id/price_change"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="+2.5%"
            android:textSize="14sp"
            android:textColor="#4CAF50"
            android:background="@drawable/change_badge_background"
            android:paddingHorizontal="8dp"
            android:paddingVertical="4dp" />
    </LinearLayout>

    <TextView
        android:id="@+id/last_updated"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:text="Updated 2 min ago"
        android:textSize="10sp"
        android:textColor="#666666" />

</LinearLayout>

2. android/app/src/main/res/xml/crypto_widget_info.xml:
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:initialLayout="@layout/crypto_widget"
    android:minWidth="180dp"
    android:minHeight="80dp"
    android:resizeMode="horizontal|vertical"
    android:updatePeriodMillis="1800000"
    android:widgetCategory="home_screen" />

3. android/app/src/main/res/drawable/widget_background.xml:
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="#1E1E1E" />
    <corners android:radius="16dp" />
</shape>
```

---

## PROMPT W2: Widget Provider (Android)

```
android/app/src/main/kotlin/.../CryptoWidgetProvider.kt:

package com.tunckankilic.cryptoflow

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class CryptoWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.crypto_widget)
            
            // SharedPreferences'tan veri al
            val prefs = context.getSharedPreferences("home_widget", Context.MODE_PRIVATE)
            
            val symbol = prefs.getString("symbol", "BTC") ?: "BTC"
            val price = prefs.getString("price", "$0.00") ?: "$0.00"
            val change = prefs.getString("change", "0%") ?: "0%"
            val changePositive = prefs.getBoolean("change_positive", true)
            val lastUpdated = prefs.getString("last_updated", "Never") ?: "Never"
            
            views.setTextViewText(R.id.coin_symbol, symbol)
            views.setTextViewText(R.id.coin_price, price)
            views.setTextViewText(R.id.price_change, change)
            views.setTextViewText(R.id.last_updated, "Updated $lastUpdated")
            
            // Change color based on positive/negative
            val changeColor = if (changePositive) 0xFF4CAF50.toInt() else 0xFFF44336.toInt()
            views.setTextColor(R.id.price_change, changeColor)
            
            // Click listener - open app
            val pendingIntent = HomeWidgetPlugin.buildPendingIntent(context, "open_app")
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

AndroidManifest.xml'e ekle:
<receiver android:name=".CryptoWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/crypto_widget_info" />
</receiver>
```

---

## PROMPT W3: Widget Service (Flutter)

```
packages/core/lib/services/widget_service.dart:

import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String appGroupId = 'group.com.tunckankilic.cryptoflow';
  static const String androidWidgetName = 'CryptoWidgetProvider';
  static const String iOSWidgetName = 'CryptoWidget';

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  /// Widget verilerini güncelle
  Future<void> updateWidget({
    required String symbol,
    required double price,
    required double changePercent,
  }) async {
    final isPositive = changePercent >= 0;
    final changeStr = '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
    final priceStr = '\$${_formatPrice(price)}';
    final now = DateTime.now();
    final timeStr = _formatTime(now);

    await HomeWidget.saveWidgetData('symbol', symbol);
    await HomeWidget.saveWidgetData('price', priceStr);
    await HomeWidget.saveWidgetData('change', changeStr);
    await HomeWidget.saveWidgetData('change_positive', isPositive);
    await HomeWidget.saveWidgetData('last_updated', timeStr);

    // Widget'ı güncelle
    await HomeWidget.updateWidget(
      androidName: androidWidgetName,
      iOSName: iOSWidgetName,
    );
  }

  /// Background'da widget güncelleme
  Future<void> registerBackgroundUpdate() async {
    await HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return price.toStringAsFixed(price < 1 ? 6 : 2);
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours}h ago';
  }
}

/// Top-level callback for background updates
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  // Binance'den fiyat çek ve widget güncelle
  if (uri?.host == 'update_widget') {
    final prefs = await SharedPreferences.getInstance();
    final symbol = prefs.getString('widget_symbol') ?? 'BTCUSDT';
    
    // API call
    final client = BinanceApiClient();
    final ticker = await client.getTicker(symbol);
    
    if (ticker != null) {
      await HomeWidget.saveWidgetData('price', '\$${ticker.price}');
      await HomeWidget.saveWidgetData('change', '${ticker.changePercent}%');
      await HomeWidget.saveWidgetData('change_positive', ticker.changePercent >= 0);
      await HomeWidget.saveWidgetData('last_updated', 'just now');
      
      await HomeWidget.updateWidget(
        androidName: 'CryptoWidgetProvider',
        iOSName: 'CryptoWidget',
      );
    }
  }
}
```

---

## PROMPT W4: iOS Widget (WidgetKit)

```
iOS Widget için WidgetKit kullan.

1. Xcode'da yeni Widget Extension ekle:
   File > New > Target > Widget Extension
   Name: CryptoWidget
   Include Configuration Intent: No

2. ios/CryptoWidget/CryptoWidget.swift:

import WidgetKit
import SwiftUI

struct CryptoEntry: TimelineEntry {
    let date: Date
    let symbol: String
    let price: String
    let change: String
    let isPositive: Bool
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CryptoEntry {
        CryptoEntry(date: Date(), symbol: "BTC", price: "$43,250", change: "+2.5%", isPositive: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (CryptoEntry) -> ()) {
        let entry = loadData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CryptoEntry>) -> ()) {
        let entry = loadData()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadData() -> CryptoEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.tunckankilic.cryptoflow")
        
        let symbol = userDefaults?.string(forKey: "symbol") ?? "BTC"
        let price = userDefaults?.string(forKey: "price") ?? "$0.00"
        let change = userDefaults?.string(forKey: "change") ?? "0%"
        let isPositive = userDefaults?.bool(forKey: "change_positive") ?? true
        
        return CryptoEntry(
            date: Date(),
            symbol: symbol,
            price: price,
            change: change,
            isPositive: isPositive
        )
    }
}

struct CryptoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CryptoFlow")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(entry.price)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text(entry.change)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(entry.isPositive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(entry.isPositive ? .green : .red)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

@main
struct CryptoWidget: Widget {
    let kind: String = "CryptoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CryptoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Crypto Price")
        .description("Track your favorite cryptocurrency price.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

3. App Groups ekle (Xcode):
   - Runner target > Signing & Capabilities > + App Groups
   - group.com.tunckankilic.cryptoflow ekle
   - Widget target'a da aynısını ekle
```

---

# 🔗 BÖLÜM 3: Deep Linking

## PROMPT D1: Deep Link Setup

```
CryptoFlow için Deep Linking ekle.

1. go_router'a deep link handling ekle:

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [...],
  
  // Deep link redirect
  redirect: (context, state) {
    final uri = state.uri;
    
    // cryptoflow://coin/BTCUSDT
    if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'coin') {
      final symbol = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      if (symbol != null) {
        return '/coin/$symbol';
      }
    }
    
    // cryptoflow://alert/123
    if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'alert') {
      final alertId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      if (alertId != null) {
        return '/alerts/$alertId';
      }
    }
    
    return null;
  },
);

2. iOS - ios/Runner/Info.plist:
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.tunckankilic.cryptoflow</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>cryptoflow</string>
        </array>
    </dict>
</array>

<!-- Universal Links -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:cryptoflow.app</string>
</array>

3. Android - AndroidManifest.xml:
<activity ...>
    <!-- Deep Links -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="cryptoflow" />
    </intent-filter>
    
    <!-- App Links -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https" android:host="cryptoflow.app" />
    </intent-filter>
</activity>
```

---

## PROMPT D2: Share Service

```
packages/core/lib/services/share_service.dart:

import 'package:share_plus/share_plus.dart';

class ShareService {
  static const String baseUrl = 'https://cryptoflow.app';
  static const String scheme = 'cryptoflow';

  /// Coin paylaş
  Future<void> shareCoin({
    required String symbol,
    required double price,
    double? changePercent,
  }) async {
    final change = changePercent != null
        ? ' (${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%)'
        : '';
    
    final text = '''
🚀 $symbol: \$${price.toStringAsFixed(2)}$change

Track crypto prices with CryptoFlow!
$baseUrl/coin/$symbol
''';

    await Share.share(text, subject: '$symbol Price');
  }

  /// Alert paylaş
  Future<void> shareAlert({
    required String symbol,
    required double targetPrice,
    required String condition,
  }) async {
    final text = '''
📈 Price Alert: $symbol ${condition == 'above' ? '>' : '<'} \$${targetPrice.toStringAsFixed(2)}

Set your own alerts with CryptoFlow!
$baseUrl
''';

    await Share.share(text, subject: '$symbol Alert');
  }

  /// Portfolio paylaş
  Future<void> sharePortfolio({
    required double totalValue,
    required double totalPnL,
    required double pnlPercent,
  }) async {
    final isPositive = totalPnL >= 0;
    final text = '''
💰 My Crypto Portfolio

Total Value: \$${totalValue.toStringAsFixed(2)}
P&L: ${isPositive ? '+' : ''}\$${totalPnL.toStringAsFixed(2)} (${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)

Track your portfolio with CryptoFlow!
$baseUrl
''';

    await Share.share(text, subject: 'My Crypto Portfolio');
  }

  /// Deep link oluştur
  String createDeepLink(String path) {
    return '$scheme://$path';
  }

  /// Web link oluştur
  String createWebLink(String path) {
    return '$baseUrl/$path';
  }
}
```

---

# 😱 BÖLÜM 4: Fear & Greed Index

## PROMPT F1: Fear & Greed Widget

```
Fear & Greed Index ekle.

1. packages/market/lib/data/datasources/fear_greed_datasource.dart:

class FearGreedDatasource {
  final Dio _dio;
  
  FearGreedDatasource(this._dio);

  Future<FearGreedIndex> getFearGreedIndex() async {
    try {
      final response = await _dio.get(
        'https://api.alternative.me/fng/',
        queryParameters: {'limit': 1},
      );
      
      final data = response.data['data'][0];
      return FearGreedIndex(
        value: int.parse(data['value']),
        classification: data['value_classification'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          int.parse(data['timestamp']) * 1000,
        ),
      );
    } catch (e) {
      throw ServerException('Failed to fetch Fear & Greed Index');
    }
  }
}

2. packages/market/lib/domain/entities/fear_greed_index.dart:

class FearGreedIndex extends Equatable {
  final int value; // 0-100
  final String classification; // Extreme Fear, Fear, Neutral, Greed, Extreme Greed
  final DateTime timestamp;

  const FearGreedIndex({
    required this.value,
    required this.classification,
    required this.timestamp,
  });

  Color get color {
    if (value <= 25) return Colors.red;
    if (value <= 45) return Colors.orange;
    if (value <= 55) return Colors.yellow;
    if (value <= 75) return Colors.lightGreen;
    return Colors.green;
  }

  String get emoji {
    if (value <= 25) return '😱';
    if (value <= 45) return '😰';
    if (value <= 55) return '😐';
    if (value <= 75) return '😊';
    return '🤑';
  }

  @override
  List<Object?> get props => [value, classification, timestamp];
}

3. packages/design_system/lib/organisms/fear_greed_gauge.dart:

class FearGreedGauge extends StatelessWidget {
  final FearGreedIndex index;

  const FearGreedGauge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Fear & Greed Index',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16),
          
          // Gauge
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _GaugePainter(value: index.value),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      index.emoji,
                      style: TextStyle(fontSize: 32),
                    ),
                    Text(
                      '${index.value}',
                      style: AppTypography.h1.copyWith(
                        color: index.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(height: 8),
          Text(
            index.classification,
            style: AppTypography.bodyLarge.copyWith(
              color: index.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 4),
          Text(
            'Updated ${_formatTime(index.timestamp)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _GaugePainter extends CustomPainter {
  final int value;
  
  _GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;
    
    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );
    
    // Gradient arc
    final gradient = SweepGradient(
      startAngle: pi,
      endAngle: 2 * pi,
      colors: [Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.green],
    );
    
    final valuePaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = (value / 100) * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      sweepAngle,
      false,
      valuePaint,
    );
    
    // Indicator
    final indicatorAngle = pi + sweepAngle;
    final indicatorPos = Offset(
      center.dx + radius * cos(indicatorAngle),
      center.dy + radius * sin(indicatorAngle),
    );
    
    canvas.drawCircle(indicatorPos, 8, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

---

# 🎬 BÖLÜM 5: Onboarding Flow

## PROMPT O1: Onboarding Screens

```
CryptoFlow için Onboarding ekle.

packages/onboarding/lib/presentation/pages/onboarding_page.dart:

class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Real-Time Prices',
      subtitle: 'Track cryptocurrency prices with live WebSocket updates from Binance',
      icon: Icons.show_chart,
      gradient: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
    ),
    OnboardingData(
      title: 'Smart Alerts',
      subtitle: 'Set price alerts and get notified instantly when targets are reached',
      icon: Icons.notifications_active,
      gradient: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
    ),
    OnboardingData(
      title: 'Portfolio Tracking',
      subtitle: 'Monitor your investments with detailed analytics and P&L tracking',
      icon: Icons.account_balance_wallet,
      gradient: [Color(0xFF4ECDC4), Color(0xFF556270)],
    ),
    OnboardingData(
      title: 'Secure & Private',
      subtitle: 'Your data is encrypted and protected with biometric authentication',
      icon: Icons.security,
      gradient: [Color(0xFFA8E6CF), Color(0xFF88D8B0)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _OnboardingPageContent(data: _pages[index]);
            },
          ),
          
          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text('Skip'),
            ),
          ),
          
          // Bottom section
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _currentPage == _pages.length - 1
                        ? _completeOnboarding
                        : _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _controller.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    
    if (mounted) {
      context.go('/');
    }
  }
}

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPageContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 48),
              
              // Title
              Text(
                data.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16),
              
              // Subtitle
              Text(
                data.subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}
```

---

# ✅ Uygulama Sırası & Checklist

## Önerilen Sıra

| # | Özellik | Süre | Öncelik |
|---|---------|------|---------|
| 1 | Push Notifications | 1-2 gün | 🔴 (promptun var) |
| 2 | Biometric Auth | 3-4 saat | 🔴 |
| 3 | Home Screen Widget | 1-2 gün | 🔴 |
| 4 | Deep Linking | 3-4 saat | 🟡 |
| 5 | Fear & Greed Index | 2-3 saat | 🟡 |
| 6 | Onboarding | 3-4 saat | 🟢 |

## Checklist

### Biometric Auth
- [ ] PROMPT B1: BiometricService
- [ ] PROMPT B2: iOS & Android Setup
- [ ] PROMPT B3: Biometric BLoC
- [ ] PROMPT B4: Lock Screen
- [ ] PROMPT B5: Settings Tile
- [ ] PROMPT B6: App Wrapper

### Home Screen Widget
- [ ] PROMPT W1: Android Layout
- [ ] PROMPT W2: Android Provider
- [ ] PROMPT W3: Flutter Service
- [ ] PROMPT W4: iOS WidgetKit

### Deep Linking
- [ ] PROMPT D1: Setup & Routes
- [ ] PROMPT D2: Share Service

### Fear & Greed
- [ ] PROMPT F1: Datasource, Entity, Widget

### Onboarding
- [ ] PROMPT O1: Onboarding Screens

---

# 🔄 Transfer Prompt

```
# CryptoFlow Ek Özellikler Context

## 🎯 Özet
CryptoFlow ana crypto uygulamasına ek özellikler ekleniyor.

## 🏗️ Mevcut Mimari
- State: flutter_bloc 8.1.0
- DI: GetIt 9.2.0
- Navigation: GoRouter 14.8.1
- Storage: Hive Flutter

## 📦 Eklenen Özellikler
1. Biometric Auth (Face ID / Touch ID)
2. Home Screen Widget (iOS & Android)
3. Deep Linking
4. Fear & Greed Index
5. Onboarding Flow
6. Push Notifications (ayrı prompt dosyası var)

## ⏳ Mevcut Durum
[Kaldığın yer]

## 🎯 Sonraki Adım
[Yapılacak iş]

---
[MEVCUT DURUM] aşamasındayım, [SONRAKİ ADIM] ile devam edelim.
```

---

*CryptoFlow Ek Özellikler - Ocak 2026*
*İsmail Tunç Kankılıç*
