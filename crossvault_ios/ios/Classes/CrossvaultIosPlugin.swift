import Flutter
import UIKit
import Security

public class CrossvaultIosPlugin: NSObject, FlutterPlugin {
  private static let serviceIdentifier = "io.alexmelnyk.crossvault"
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "crossvault", binaryMessenger: registrar.messenger())
    let instance = CrossvaultIosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    
    switch call.method {
    case "existsKey":
      guard let key = args?["key"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Key is required", details: nil))
        return
      }
      let accessGroup = args?["accessGroup"] as? String
      result(existsInKeychain(key: key, accessGroup: accessGroup))
      
    case "getValue":
      guard let key = args?["key"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Key is required", details: nil))
        return
      }
      let accessGroup = args?["accessGroup"] as? String
      do {
        let value = try getFromKeychain(key: key, accessGroup: accessGroup)
        result(value)
      } catch {
        result(FlutterError(code: "KEYCHAIN_ERROR", message: error.localizedDescription, details: nil))
      }
      
    case "setValue":
      guard let key = args?["key"] as? String,
            let value = args?["value"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Key and value are required", details: nil))
        return
      }
      let accessGroup = args?["accessGroup"] as? String
      do {
        try saveToKeychain(key: key, value: value, accessGroup: accessGroup)
        result(nil)
      } catch {
        result(FlutterError(code: "KEYCHAIN_ERROR", message: error.localizedDescription, details: nil))
      }
      
    case "deleteValue":
      guard let key = args?["key"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Key is required", details: nil))
        return
      }
      let accessGroup = args?["accessGroup"] as? String
      do {
        try deleteFromKeychain(key: key, accessGroup: accessGroup)
        result(nil)
      } catch {
        result(FlutterError(code: "KEYCHAIN_ERROR", message: error.localizedDescription, details: nil))
      }
      
    case "deleteAll":
      let accessGroup = args?["accessGroup"] as? String
      do {
        try deleteAllFromKeychain(accessGroup: accessGroup)
        result(nil)
      } catch {
        result(FlutterError(code: "KEYCHAIN_ERROR", message: error.localizedDescription, details: nil))
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - Keychain Operations
  
  /// Check if a key exists in the keychain
  private func existsInKeychain(key: String, accessGroup: String?) -> Bool {
    var query = baseQuery(for: key, accessGroup: accessGroup)
    query[kSecReturnData as String] = false
    
    let status = SecItemCopyMatching(query as CFDictionary, nil)
    return status == errSecSuccess
  }
  
  /// Retrieve a value from the keychain
  private func getFromKeychain(key: String, accessGroup: String?) throws -> String? {
    var query = baseQuery(for: key, accessGroup: accessGroup)
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status != errSecItemNotFound else {
      return nil
    }
    
    guard status == errSecSuccess else {
      throw KeychainError.operationFailed(status: status)
    }
    
    guard let data = result as? Data,
          let value = String(data: data, encoding: .utf8) else {
      throw KeychainError.invalidData
    }
    
    return value
  }
  
  /// Save a value to the keychain
  private func saveToKeychain(key: String, value: String, accessGroup: String?) throws {
    guard let data = value.data(using: .utf8) else {
      throw KeychainError.invalidData
    }
    
    let query = baseQuery(for: key, accessGroup: accessGroup)
    
    // Try to update first
    let attributes: [String: Any] = [
      kSecValueData as String: data
    ]
    
    let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    
    if updateStatus == errSecItemNotFound {
      // Item doesn't exist, add it
      var addQuery = query
      addQuery[kSecValueData as String] = data
      addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
      
      let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
      
      guard addStatus == errSecSuccess else {
        throw KeychainError.operationFailed(status: addStatus)
      }
    } else if updateStatus != errSecSuccess {
      throw KeychainError.operationFailed(status: updateStatus)
    }
  }
  
  /// Delete a value from the keychain
  private func deleteFromKeychain(key: String, accessGroup: String?) throws {
    let query = baseQuery(for: key, accessGroup: accessGroup)
    
    let status = SecItemDelete(query as CFDictionary)
    
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeychainError.operationFailed(status: status)
    }
  }
  
  /// Delete all values from the keychain
  private func deleteAllFromKeychain(accessGroup: String?) throws {
    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: Self.serviceIdentifier
    ]
    
    if let accessGroup = accessGroup {
      query[kSecAttrAccessGroup as String] = accessGroup
    }
    
    let status = SecItemDelete(query as CFDictionary)
    
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeychainError.operationFailed(status: status)
    }
  }
  
  // MARK: - Helper Methods
  
  /// Create base query for keychain operations
  ///
  /// - Parameters:
  ///   - key: The key to use for the keychain item
  ///   - accessGroup: Optional access group for sharing between apps
  ///
  /// - Returns: A dictionary containing the base keychain query
  ///
  /// **Important:**
  /// - If `accessGroup` is `nil`, the item is stored privately for this app only
  /// - If `accessGroup` is provided, the item can be shared with other apps
  ///   that have the same Team ID and the same access group configured
  private func baseQuery(for key: String, accessGroup: String?) -> [String: Any] {
    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecAttrService as String: Self.serviceIdentifier
    ]
    
    // Add access group if provided (for sharing between apps)
    // When nil, data is stored privately for this app only (most secure)
    if let accessGroup = accessGroup {
      query[kSecAttrAccessGroup as String] = accessGroup
    }
    
    return query
  }
}

// MARK: - Keychain Errors

enum KeychainError: Error, LocalizedError {
  case operationFailed(status: OSStatus)
  case invalidData
  
  var errorDescription: String? {
    switch self {
    case .operationFailed(let status):
      if let message = SecCopyErrorMessageString(status, nil) as String? {
        return "Keychain operation failed: \(message) (status: \(status))"
      }
      return "Keychain operation failed with status: \(status)"
    case .invalidData:
      return "Invalid data format"
    }
  }
}
