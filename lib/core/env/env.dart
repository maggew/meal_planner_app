import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _Env.supabaseAnonKey;

  @EnviedField(varName: 'GOOGLE_LOGIN_SERVER_CLIENT_ID')
  static final String googleLoginServerClientId = _Env.googleLoginServerClientId;

  @EnviedField(varName: 'BOOTSTRAP_USER_URL')
  static final String bootstrapUserUrl = _Env.bootstrapUserUrl;
}
