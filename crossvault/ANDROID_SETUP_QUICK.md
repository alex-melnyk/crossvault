# Android Auto Backup - Quick Setup

Quick reference for setting up Auto Backup in your Android app.

## ⚡ 3-Step Setup

### 1. Update AndroidManifest.xml

```xml
<application
    android:allowBackup="true"
    android:fullBackupContent="@xml/backup_rules"
    android:dataExtractionRules="@xml/data_extraction_rules">
</application>
```

### 2. Create backup_rules.xml

File: `android/app/src/main/res/xml/backup_rules.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <include domain="sharedpref" path="crossvault_secure_storage.xml"/>
    <exclude domain="sharedpref" path="_androidx_security_master_key_"/>
    <exclude domain="file" path="cache/"/>
</full-backup-content>
```

### 3. Create data_extraction_rules.xml (Android 12+)

File: `android/app/src/main/res/xml/data_extraction_rules.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <include domain="sharedpref" path="crossvault_secure_storage.xml"/>
        <exclude domain="sharedpref" path="_androidx_security_master_key_"/>
    </cloud-backup>
</data-extraction-rules>
```

## ✅ Done!

Your app now has Auto Backup configured. Data will be:
- ✅ Backed up automatically to Google Drive
- ✅ Restored when app is reinstalled
- ✅ Encrypted in transit and at rest

## 🧪 Test It

```bash
# Force backup
adb shell bmgr backupnow <your.package.name>

# Uninstall and reinstall to test restore
adb uninstall <your.package.name>
flutter run
```

## 📚 Full Documentation

- [Detailed Setup Guide](example/android/SETUP_AUTO_BACKUP.md)
- [Android Plugin README](../crossvault_android/README.md)

## 🔧 Custom Storage Name?

If you use custom storage name:

```dart
AndroidOptions(
  sharedPreferencesName: 'my_custom_storage',
)
```

Update backup rules:

```xml
<include domain="sharedpref" path="my_custom_storage.xml"/>
```

## ⚠️ Important

- Master key is **NOT** backed up (it's regenerated)
- Requires Google account on device
- Backup happens ~every 24 hours
- 25MB limit per app
