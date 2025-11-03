
import 'crossvault_platform_interface.dart';

class Crossvault {
  Future<String?> getPlatformVersion() {
    return CrossvaultPlatform.instance.getPlatformVersion();
  }
}
