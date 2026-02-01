library;

// Domain - Entities
export 'domain/entities/app_user.dart';

// Domain - Repositories
export 'domain/repositories/auth_repository.dart';

// Domain - Use Cases
export 'domain/usecases/sign_in_with_google.dart';
export 'domain/usecases/sign_in_with_apple.dart';
export 'domain/usecases/sign_in_anonymously.dart';
export 'domain/usecases/sign_out.dart';
export 'domain/usecases/get_current_user.dart';
export 'domain/usecases/watch_auth_state.dart';
export 'domain/usecases/delete_account.dart';

// Data - Models
export 'data/models/app_user_model.dart';

// Data - Datasources
export 'data/datasources/firebase_auth_datasource.dart';

// Data - Repositories
export 'data/repositories/auth_repository_impl.dart';

// Data - Services
export 'data/services/export_service.dart';

// Presentation - BLoC
export 'presentation/bloc/auth_bloc.dart';
export 'presentation/bloc/auth_event.dart';
export 'presentation/bloc/auth_state.dart';

// Presentation - Pages
export 'presentation/pages/login_page.dart';
export 'presentation/pages/profile_page.dart';

// Presentation - Widgets
export 'presentation/widgets/social_login_button.dart';
export 'presentation/widgets/user_avatar.dart';
export 'presentation/widgets/profile_header.dart';
export 'presentation/widgets/biometric_setting_tile.dart';

// Domain - Services
export 'domain/services/biometric_service.dart';

// Presentation - Biometric BLoC
export 'presentation/bloc/biometric/biometric_bloc.dart';
export 'presentation/bloc/biometric/biometric_event.dart';
export 'presentation/bloc/biometric/biometric_state.dart';

// Presentation - Pages
export 'presentation/pages/lock_screen.dart';
export 'presentation/pages/onboarding_page.dart';

// Presentation - Widgets
export 'presentation/widgets/onboarding_content.dart';
export 'presentation/widgets/page_indicator.dart';
