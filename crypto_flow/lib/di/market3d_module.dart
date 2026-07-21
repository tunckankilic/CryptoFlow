import 'package:market/market.dart';
import 'package:market_3d/market_3d.dart';

import 'injection_container.dart';

/// Register "3D Market" tab dependencies.
Future<void> registerMarket3DModule() async {
  getIt.registerFactory<Market3DBloc>(
    () => Market3DBloc(
      getCandlesUseCase: getIt<GetCandlesUseCase>(),
    ),
  );
}
