# Android Auto Backup Setup Guide

This guide explains how to configure Auto Backup for Crossvault in your Android app.

## 📋 Table of Contents

- [What is Auto Backup?](#what-is-auto-backup)
- [Quick Setup](#quick-setup)
- [Detailed Configuration](#detailed-configuration)
- [Testing Auto Backup](#testing-auto-backup)
- [Troubleshooting](#troubleshooting)

## 🤔 What is Auto Backup?

Auto Backup is an Android feature that automatically backs up your app's data to Google Drive:

- ✅ **Automatic** - Backs up data ~every 24 hours
- ✅ **Encrypted** - Data encrypted in transit and at rest
- ✅ **Free** - Up to 25MB per app
- ✅ **Restores automatically** - When app is reinstalled
- ⚠️ **Requires Google account** - User must be signed in

## 🚀 Quick Setup

### Step 1: Enable Auto Backup in AndroidManifest.xml

Open `android/app/src/main/AndroidManifest.xml` and add these attributes to `<application>`:

```xml
<application
    android:allowBackup="true"
    android:fullBackupContent="@xml/backup_rules"
    android:dataExtractionRules="@xml/data_extraction_rules">
    <!-- Your app content -->
</application>
```

### Step 2: Create Backup Rules

Create `android/app/src/main/res/xml/backup_rules.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <!-- Include Crossvault encrypted data -->
    <include domain="sharedpref" path="crossvault_secure_storage.xml"/>
    
    <!-- Exclude master key (will be regenerated) -->
    <exclude domain="sharedpref" path="_androidx_security_master_key_"/>
    
    <!-- Exclude cache -->
    <exclude domain="file" path="cache/"/>
</full-backup-content>
```

### Step 3: Create Data Extraction Rules (Android 12+)

Create `android/app/src/main/res/xml/data_extraction_rules.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <include domain="sharedpref" path="crossvault_secure_storage.xml"/>
        <exclude domain="sharedpref" path="_androidx_security_master_key_"/>
        <exclude domain="file" path="cache/"/>
    </cloud-backup>
    
    <device-transfer>
        <include domain="sharedpref" path="crossvault_secure_storage.xml"/>
        <exclude domain="sharedpref" path="_androidx_security_master_key_"/>
        <exclude domain="file" path="cache/"/>
    </device-transfer>
</data-extraction-rules>
```

### Step 4: Done! 🎉

That's it! Auto Backup is now configured for your app.

## 📖 Detailed Configuration

### Understanding the Configuration

#### 1. `android:allowBackup="true"`

Enables Auto Backup for your app. Set to `false` if you don't want backups.

#### 2. `android:fullBackupContent="@xml/backup_rules"`

Points to the backup rules file that specifies what to back up.

#### 3. `android:dataExtractionRules="@xml/data_extraction_rules"`

Required for Android 12+ (API 31+). Configures cloud backup and device-to-device transfer.

### What Gets Backed Up?

✅ **Included:**
- `crossvault_secure_storage.xml` - Your encrypted data

❌ **Excluded:**
- `_androidx_security_master_key_` - Master encryption key (regenerated on restore)
- `cache/` - Cache files (can be regenerated)
- `code_cache/` - Code cache (can be regenerated)

### Why Exclude the Master Key?

The master key is stored in Android Keystore and **cannot be backed up**. When your app is restored:

1. A new master key is generated in Android Keystore
2. The backed-up encrypted data is decrypted with the new key
3. Everything works seamlessly!

### Custom Storage Names

If you use a custom storage name:

```dart
AndroidOptions(
  sharedPreferencesName: 'my_custom_storage',
)
```

Update your backup rules:

```xml
<include domain="sharedpref" path="my_custom_storage.xml"/>
```

## 🧪 Testing Auto Backup

### Method 1: Force Backup (Recommended)

```bash
# Enable backup for your app
adb shell bmgr enable true

# Force an immediate backup
adb shell bmgr backupnow <your.package.name>

# Example:
adb shell bmgr backupnow com.example.crossvault_example
```

### Method 2: Check Backup Status

```bash
# List available transports
adb shell bmgr list transports

# Check if backup is enabled
adb shell bmgr enabled

# View backup history
adb shell dumpsys backup
```

### Method 3: Test Restore

```bash
# Uninstall app
adb uninstall <your.package.name>

# Reinstall app
flutter run

# Data should be restored automatically!
```

### Method 4: Manual Restore

```bash
# Restore from backup
adb shell bmgr restore <your.package.name>

# Or restore specific backup set
adb shell bmgr restore <token> <your.package.name>
```

## 🐛 Troubleshooting

### Backup Not Working

**Problem**: Data not being backed up

**Solutions**:

1. **Check if backup is enabled:**
   ```bash
   adb shell bmgr enabled
   ```
   If disabled, enable it:
   ```bash
   adb shell bmgr enable true
   ```

2. **Verify Google account:**
   - Device must be signed in with Google account
   - Check Settings → Accounts → Google

3. **Check backup quota:**
   - Each app has 25MB limit
   - Check if quota exceeded

4. **Verify backup rules:**
   - Ensure XML files are in correct location
   - Check for XML syntax errors

### Data Not Restored

**Problem**: Data not restored after reinstall

**Solutions**:

1. **Same Google account:**
   - Must use same Google account as backup
   - Check account in Settings

2. **Wait for backup:**
   - Backup happens ~every 24 hours
   - Force backup before uninstalling

3. **Check backup exists:**
   ```bash
   adb shell dumpsys backup
   ```

4. **Manual restore:**
   ```bash
   adb shell bmgr restore <your.package.name>
   ```

### "Master Key Not Found" Error

**Problem**: Error accessing encrypted data after restore

**Solution**: This is normal! The master key is regenerated automatically. If you see this error:

1. The plugin will automatically recreate the storage
2. Backed-up data will be decrypted with new key
3. Everything should work normally

If problems persist, check `resetOnError` option:

```dart
AndroidOptions(
  resetOnError: true,  // Auto-reset on error
)
```

### Backup Too Large

**Problem**: Backup exceeds 25MB limit

**Solutions**:

1. **Reduce data size:**
   - Store only essential data
   - Don't store large files

2. **Exclude non-essential data:**
   ```xml
   <exclude domain="sharedpref" path="non_essential_data.xml"/>
   ```

3. **Use separate storage:**
   - Use different storage for large data
   - Only backup critical data

## 📱 Device Requirements

### Minimum Requirements

- ✅ Android 6.0+ (API 23+)
- ✅ Google Play Services installed
- ✅ Google account signed in
- ✅ Backup enabled in device settings

### Checking Device Support

```bash
# Check Android version
adb shell getprop ro.build.version.sdk

# Check if Google Play Services installed
adb shell pm list packages | grep google

# Check backup settings
adb shell bmgr enabled
```

## 🔒 Security Considerations

### What's Encrypted?

- ✅ **Data at rest** - Encrypted on device (AES256-GCM)
- ✅ **Data in transit** - Encrypted when uploading to Google Drive
- ✅ **Data in cloud** - Encrypted in Google Drive

### What's NOT Backed Up?

- ❌ **Master key** - Stored in Android Keystore (cannot be extracted)
- ❌ **Biometric keys** - Device-specific
- ❌ **Hardware-backed keys** - Cannot leave device

### Best Practices

1. **Always exclude master key:**
   ```xml
   <exclude domain="sharedpref" path="_androidx_security_master_key_"/>
   ```

2. **Don't backup sensitive files:**
   - Exclude any files with plaintext secrets
   - Only backup encrypted data

3. **Test backup/restore:**
   - Test on different devices
   - Verify data integrity after restore

4. **Handle errors gracefully:**
   ```dart
   try {
     await crossvault.setValue('key', 'value');
   } catch (e) {
     // Handle error
   }
   ```

## 📚 Additional Resources

- [Android Auto Backup Documentation](https://developer.android.com/guide/topics/data/autobackup)
- [Data Extraction Rules (Android 12+)](https://developer.android.com/about/versions/12/backup-restore)
- [Testing Backup](https://developer.android.com/guide/topics/data/testingbackup)
- [Backup Best Practices](https://developer.android.com/guide/topics/data/backup)

## 💡 Tips

### Tip 1: Force Backup Before Testing

Always force a backup before testing restore:

```bash
adb shell bmgr backupnow <your.package.name>
```

### Tip 2: Check Logs

Monitor backup logs:

```bash
adb logcat | grep -i backup
```

### Tip 3: Test on Real Device

Auto Backup works best on real devices with Google account. Emulators may have limitations.

### Tip 4: Document for Users

If your app relies on Auto Backup, inform users:

- Backup requires Google account
- Data restored automatically on reinstall
- Backup happens automatically every ~24 hours

## ❓ FAQ

### Q: Is Auto Backup enabled by default?

**A:** Yes, on Android 6.0+ (API 23+), but only if you configure it in your manifest.

### Q: Can users disable Auto Backup?

**A:** Yes, users can disable backup in device settings: Settings → System → Backup.

### Q: Does Auto Backup work on all devices?

**A:** No, requires Google Play Services. Not available on some devices (e.g., Huawei without GMS).

### Q: How often does backup happen?

**A:** Automatically ~every 24 hours when device is idle, charging, and connected to Wi-Fi.

### Q: Can I force backup more frequently?

**A:** Not for production apps. Only during development using `adb shell bmgr backupnow`.

### Q: What happens if backup fails?

**A:** Android will retry automatically. Data remains on device until successful backup.

### Q: Can I backup to other cloud services?

**A:** No, Auto Backup only supports Google Drive. For other services, implement custom backup.

---

## ✅ Checklist

Before deploying your app, verify:

- [ ] `android:allowBackup="true"` in AndroidManifest.xml
- [ ] `backup_rules.xml` created and configured
- [ ] `data_extraction_rules.xml` created (for Android 12+)
- [ ] Master key excluded from backup
- [ ] Tested backup and restore on real device
- [ ] Documented backup requirements for users
- [ ] Error handling implemented

---

**Need help?** Check the [Crossvault Android README](../../../crossvault_android/README.md) for more details.
