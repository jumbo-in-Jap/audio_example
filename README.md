# flutter_sound_app

A new example Audio Flutter Example application.

### spec

- [x] enable to record audio, ios/android
- [x] enable to convert mp3 to zip

### memo

- need to upgrade ios minimum deployment version 9.0 to 11.0
- need to upgrade android minSdkVersion version 16 to 24(Android 7)
- need to add NSMicrophoneUsageDescription to info plist
- need to add permission to AndroidManifest.xml
- need to add permission_handler package

#### you can access file directory in your android device via adb

```
127|sargo:/ $ run-as com.example.flutter_sound_app
sargo:/data/user/0/com.example.flutter_sound_app $ ls
app_flutter  cache  code_cache  files
s cache/                                                                      <
tau_file.mp4

sargo:/data/user/0/com.example.flutter_sound_app $ ls app_flutter
audio.mp4  flutter_assets  res_timestamp-1-1632130161889
```
