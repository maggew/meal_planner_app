import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static const String supabaseAnonKey = _Env.supabaseAnonKey;

  @EnviedField(varName: 'GOOGLE_LOGIN_SERVER_CLIENT_ID')
  static const String googleLoginServerClientId = _Env.googleLoginServerClientId;

  @EnviedField(varName: 'BOOTSTRAP_USER_URL')
  static const String bootstrapUserUrl = _Env.bootstrapUserUrl;
}
