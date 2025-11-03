package io.alexmelnyk.crossvault_android

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException
import java.security.GeneralSecurityException

/** CrossvaultAndroidPlugin */
class CrossvaultAndroidPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var encryptedPreferences: SharedPreferences? = null

    companion object {
        private const val DEFAULT_PREFS_NAME = "crossvault_secure_storage"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "crossvault")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "existsKey" -> {
                    val key = call.argument<String>("key")
                    if (key == null) {
                        result.error("INVALID_ARGUMENT", "Key is required", null)
                        return
                    }
                    val prefsName = call.argument<String>("sharedPreferencesName") ?: DEFAULT_PREFS_NAME
                    val prefs = getEncryptedPreferences(prefsName, call.argument("resetOnError") ?: true)
                    result.success(prefs?.contains(key) ?: false)
                }
                "getValue" -> {
                    val key = call.argument<String>("key")
                    if (key == null) {
                        result.error("INVALID_ARGUMENT", "Key is required", null)
                        return
                    }
                    val prefsName = call.argument<String>("sharedPreferencesName") ?: DEFAULT_PREFS_NAME
                    val prefs = getEncryptedPreferences(prefsName, call.argument("resetOnError") ?: true)
                    val value = prefs?.getString(key, null)
                    result.success(value)
                }
                "setValue" -> {
                    val key = call.argument<String>("key")
                    val value = call.argument<String>("value")
                    if (key == null || value == null) {
                        result.error("INVALID_ARGUMENT", "Key and value are required", null)
                        return
                    }
                    val prefsName = call.argument<String>("sharedPreferencesName") ?: DEFAULT_PREFS_NAME
                    val prefs = getEncryptedPreferences(prefsName, call.argument("resetOnError") ?: true)
                    prefs?.edit()?.putString(key, value)?.apply()
                    result.success(null)
                }
                "deleteValue" -> {
                    val key = call.argument<String>("key")
                    if (key == null) {
                        result.error("INVALID_ARGUMENT", "Key is required", null)
                        return
                    }
                    val prefsName = call.argument<String>("sharedPreferencesName") ?: DEFAULT_PREFS_NAME
                    val prefs = getEncryptedPreferences(prefsName, call.argument("resetOnError") ?: true)
                    prefs?.edit()?.remove(key)?.apply()
                    result.success(null)
                }
                "deleteAll" -> {
                    val prefsName = call.argument<String>("sharedPreferencesName") ?: DEFAULT_PREFS_NAME
                    val prefs = getEncryptedPreferences(prefsName, call.argument("resetOnError") ?: true)
                    prefs?.edit()?.clear()?.apply()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            result.error("STORAGE_ERROR", e.message, e.toString())
        }
    }

    /**
     * Gets or creates EncryptedSharedPreferences instance.
     *
     * Uses Android Keystore for key management and AES256-GCM for encryption.
     * Keys are stored in Android Keystore, which provides hardware-backed security on supported devices.
     *
     * @param prefsName The name of the SharedPreferences file
     * @param resetOnError Whether to reset storage if decryption fails (e.g., after device security changes)
     * @return EncryptedSharedPreferences instance or null if creation fails
     */
    private fun getEncryptedPreferences(prefsName: String, resetOnError: Boolean): SharedPreferences? {
        try {
            if (encryptedPreferences == null) {
                // Create or retrieve the Master Key for encryption
                // This key is stored in Android Keystore
                val masterKey = MasterKey.Builder(context)
                    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                    .build()

                // Create EncryptedSharedPreferences
                encryptedPreferences = EncryptedSharedPreferences.create(
                    context,
                    prefsName,
                    masterKey,
                    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
                )
            }
            return encryptedPreferences
        } catch (e: GeneralSecurityException) {
            // Security exception - possibly key was invalidated
            if (resetOnError) {
                return resetAndRecreate(prefsName)
            }
            throw e
        } catch (e: IOException) {
            // IO exception - possibly corrupted data
            if (resetOnError) {
                return resetAndRecreate(prefsName)
            }
            throw e
        }
    }

    /**
     * Resets the encrypted storage and recreates it.
     *
     * This is called when decryption fails, which can happen when:
     * - Device security settings changed (lock screen removed/added)
     * - App data was corrupted
     * - Key was invalidated by the system
     */
    private fun resetAndRecreate(prefsName: String): SharedPreferences? {
        try {
            // Delete the old encrypted file
            context.deleteSharedPreferences(prefsName)
            encryptedPreferences = null

            // Recreate
            val masterKey = MasterKey.Builder(context)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .build()

            encryptedPreferences = EncryptedSharedPreferences.create(
                context,
                prefsName,
                masterKey,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            )

            return encryptedPreferences
        } catch (e: Exception) {
            // If recreation also fails, return null
            return null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        encryptedPreferences = null
    }
}
