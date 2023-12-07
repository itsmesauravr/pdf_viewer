import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/cupertino.dart';
import 'presentation/core/widgets/app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FileDownloader().configure(globalConfig: [
    (Config.requestTimeout, const Duration(seconds: 100)),
  ], androidConfig: [
    (Config.useCacheDir, Config.whenAble),
  ], iOSConfig: [
    (Config.localize, {'Cancel': 'StopIt'}),
  ]).then((result) => debugPrint('Configuration result = $result'));
  runApp(const AppWidget());
}
