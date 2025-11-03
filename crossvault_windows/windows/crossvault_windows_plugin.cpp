#include "crossvault_windows_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <wincred.h>
#include <ncrypt.h>
#include <bcrypt.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>
#include <codecvt>
#include <locale>
#include <vector>

#pragma comment(lib, "Advapi32.lib")
#pragma comment(lib, "Ncrypt.lib")
#pragma comment(lib, "Bcrypt.lib")

namespace crossvault_windows {

// Helper function to convert UTF-8 to wide string
std::wstring Utf8ToWide(const std::string& utf8) {
  if (utf8.empty()) return std::wstring();
  
  int size_needed = MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), 
                                        static_cast<int>(utf8.length()), 
                                        nullptr, 0);
  std::wstring wide_string(size_needed, 0);
  MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), 
                     static_cast<int>(utf8.length()), 
                     &wide_string[0], size_needed);
  return wide_string;
}

// Helper function to convert wide string to UTF-8
std::string WideToUtf8(const std::wstring& wide) {
  if (wide.empty()) return std::string();
  
  int size_needed = WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), 
                                        static_cast<int>(wide.length()), 
                                        nullptr, 0, nullptr, nullptr);
  std::string utf8_string(size_needed, 0);
  WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), 
                     static_cast<int>(wide.length()), 
                     &utf8_string[0], size_needed, nullptr, nullptr);
  return utf8_string;
}

// TPM Helper Functions

// Check if TPM is available on the system
bool IsTPMAvailable() {
  NCRYPT_PROV_HANDLE hProvider = 0;
  
  SECURITY_STATUS status = NCryptOpenStorageProvider(
    &hProvider,
    MS_PLATFORM_CRYPTO_PROVIDER,
    0
  );
  
  if (status == ERROR_SUCCESS && hProvider != 0) {
    NCryptFreeObject(hProvider);
    return true;
  }
  
  return false;
}

// Encrypt data using TPM
bool EncryptWithTPM(const std::string& data, std::vector<BYTE>& encrypted) {
  NCRYPT_PROV_HANDLE hProvider = 0;
  NCRYPT_KEY_HANDLE hKey = 0;
  DWORD cbResult = 0;
  
  // Open TPM provider
  SECURITY_STATUS status = NCryptOpenStorageProvider(
    &hProvider,
    MS_PLATFORM_CRYPTO_PROVIDER,
    0
  );
  
  if (status != ERROR_SUCCESS) {
    return false;
  }
  
  // Create or open a persistent key
  status = NCryptCreatePersistedKey(
    hProvider,
    &hKey,
    BCRYPT_RSA_ALGORITHM,
    L"CrossvaultTPMKey",
    0,
    0
  );
  
  if (status != ERROR_SUCCESS) {
    // Try to open existing key
    status = NCryptOpenKey(
      hProvider,
      &hKey,
      L"CrossvaultTPMKey",
      0,
      0
    );
  }
  
  if (status != ERROR_SUCCESS) {
    NCryptFreeObject(hProvider);
    return false;
  }
  
  // Finalize the key
  NCryptFinalizeKey(hKey, 0);
  
  // Get required buffer size
  status = NCryptEncrypt(
    hKey,
    (PBYTE)data.c_str(),
    static_cast<DWORD>(data.length()),
    nullptr,
    nullptr,
    0,
    &cbResult,
    NCRYPT_PAD_PKCS1_FLAG
  );
  
  if (status != ERROR_SUCCESS) {
    NCryptFreeObject(hKey);
    NCryptFreeObject(hProvider);
    return false;
  }
  
  // Allocate buffer and encrypt
  encrypted.resize(cbResult);
  status = NCryptEncrypt(
    hKey,
    (PBYTE)data.c_str(),
    static_cast<DWORD>(data.length()),
    nullptr,
    encrypted.data(),
    cbResult,
    &cbResult,
    NCRYPT_PAD_PKCS1_FLAG
  );
  
  NCryptFreeObject(hKey);
  NCryptFreeObject(hProvider);
  
  return status == ERROR_SUCCESS;
}

// Decrypt data using TPM
bool DecryptWithTPM(const std::vector<BYTE>& encrypted, std::string& decrypted) {
  NCRYPT_PROV_HANDLE hProvider = 0;
  NCRYPT_KEY_HANDLE hKey = 0;
  DWORD cbResult = 0;
  
  // Open TPM provider
  SECURITY_STATUS status = NCryptOpenStorageProvider(
    &hProvider,
    MS_PLATFORM_CRYPTO_PROVIDER,
    0
  );
  
  if (status != ERROR_SUCCESS) {
    return false;
  }
  
  // Open the key
  status = NCryptOpenKey(
    hProvider,
    &hKey,
    L"CrossvaultTPMKey",
    0,
    0
  );
  
  if (status != ERROR_SUCCESS) {
    NCryptFreeObject(hProvider);
    return false;
  }
  
  // Get required buffer size
  status = NCryptDecrypt(
    hKey,
    const_cast<PBYTE>(encrypted.data()),
    static_cast<DWORD>(encrypted.size()),
    nullptr,
    nullptr,
    0,
    &cbResult,
    NCRYPT_PAD_PKCS1_FLAG
  );
  
  if (status != ERROR_SUCCESS) {
    NCryptFreeObject(hKey);
    NCryptFreeObject(hProvider);
    return false;
  }
  
  // Allocate buffer and decrypt
  std::vector<BYTE> buffer(cbResult);
  status = NCryptDecrypt(
    hKey,
    const_cast<PBYTE>(encrypted.data()),
    static_cast<DWORD>(encrypted.size()),
    nullptr,
    buffer.data(),
    cbResult,
    &cbResult,
    NCRYPT_PAD_PKCS1_FLAG
  );
  
  NCryptFreeObject(hKey);
  NCryptFreeObject(hProvider);
  
  if (status == ERROR_SUCCESS) {
    decrypted = std::string(buffer.begin(), buffer.begin() + cbResult);
    return true;
  }
  
  return false;
}

// static
void CrossvaultWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "crossvault",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<CrossvaultWindowsPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

CrossvaultWindowsPlugin::CrossvaultWindowsPlugin() {}

CrossvaultWindowsPlugin::~CrossvaultWindowsPlugin() {}

// Build target name with prefix
std::wstring CrossvaultWindowsPlugin::BuildTargetName(
    const std::string& key, 
    const std::string& prefix) {
  std::string target = prefix.empty() 
    ? "io.alexmelnyk.crossvault:" + key 
    : prefix + ":" + key;
  return Utf8ToWide(target);
}

// Get persist type from string
DWORD CrossvaultWindowsPlugin::GetPersistType(const std::string& persist) {
  if (persist == "session") {
    return CRED_PERSIST_SESSION;
  } else if (persist == "enterprise") {
    return CRED_PERSIST_ENTERPRISE;
  }
  return CRED_PERSIST_LOCAL_MACHINE; // default
}

// Check if key exists in Credential Manager
bool CrossvaultWindowsPlugin::ExistsKey(
    const std::string& key,
    const std::string& prefix) {
  std::wstring target_name = BuildTargetName(key, prefix);
  PCREDENTIALW credential = nullptr;
  
  BOOL result = CredReadW(
    target_name.c_str(),
    CRED_TYPE_GENERIC,
    0,
    &credential
  );
  
  if (credential) {
    CredFree(credential);
  }
  
  return result == TRUE;
}

// Get value from Credential Manager
std::string CrossvaultWindowsPlugin::GetValue(
    const std::string& key,
    const std::string& prefix) {
  std::wstring target_name = BuildTargetName(key, prefix);
  PCREDENTIALW credential = nullptr;
  
  BOOL result = CredReadW(
    target_name.c_str(),
    CRED_TYPE_GENERIC,
    0,
    &credential
  );
  
  if (result != TRUE || !credential) {
    return "";
  }
  
  // Check if this is TPM-encrypted data (by UserName)
  std::wstring username = credential->UserName ? credential->UserName : L"";
  
  if (username == L"crossvault_tpm") {
    // TPM-encrypted data - decrypt with TPM
    std::vector<BYTE> encrypted(
      credential->CredentialBlob,
      credential->CredentialBlob + credential->CredentialBlobSize
    );
    
    std::string decrypted;
    if (DecryptWithTPM(encrypted, decrypted)) {
      CredFree(credential);
      return decrypted;
    }
    
    // If TPM decryption fails, return empty (data is corrupted or TPM unavailable)
    CredFree(credential);
    return "";
  }
  
  // Standard DPAPI-encrypted data
  std::wstring wide_value(
    reinterpret_cast<wchar_t*>(credential->CredentialBlob),
    credential->CredentialBlobSize / sizeof(wchar_t)
  );
  
  std::string value = WideToUtf8(wide_value);
  CredFree(credential);
  
  return value;
}

// Set value in Credential Manager
bool CrossvaultWindowsPlugin::SetValue(
    const std::string& key,
    const std::string& value,
    const std::string& prefix,
    const std::string& persist,
    bool useTPM) {
  std::wstring target_name = BuildTargetName(key, prefix);
  
  // If TPM is requested and available, encrypt with TPM
  if (useTPM && IsTPMAvailable()) {
    std::vector<BYTE> encrypted;
    if (EncryptWithTPM(value, encrypted)) {
      // Store TPM-encrypted data
      CREDENTIALW credential = {0};
      credential.Type = CRED_TYPE_GENERIC;
      credential.TargetName = const_cast<LPWSTR>(target_name.c_str());
      credential.CredentialBlobSize = static_cast<DWORD>(encrypted.size());
      credential.CredentialBlob = encrypted.data();
      credential.Persist = GetPersistType(persist);
      credential.UserName = const_cast<LPWSTR>(L"crossvault_tpm");
      credential.Comment = const_cast<LPWSTR>(L"Crossvault TPM-protected storage");
      
      return CredWriteW(&credential, 0) == TRUE;
    }
    // If TPM encryption fails, fall through to DPAPI
  }
  
  // Use standard DPAPI encryption
  std::wstring wide_value = Utf8ToWide(value);
  
  CREDENTIALW credential = {0};
  credential.Type = CRED_TYPE_GENERIC;
  credential.TargetName = const_cast<LPWSTR>(target_name.c_str());
  credential.CredentialBlobSize = static_cast<DWORD>(
    wide_value.size() * sizeof(wchar_t)
  );
  credential.CredentialBlob = reinterpret_cast<LPBYTE>(
    const_cast<wchar_t*>(wide_value.c_str())
  );
  credential.Persist = GetPersistType(persist);
  credential.UserName = const_cast<LPWSTR>(L"crossvault");
  credential.Comment = const_cast<LPWSTR>(L"Crossvault secure storage");
  
  return CredWriteW(&credential, 0) == TRUE;
}

// Delete value from Credential Manager
bool CrossvaultWindowsPlugin::DeleteValue(
    const std::string& key,
    const std::string& prefix) {
  std::wstring target_name = BuildTargetName(key, prefix);
  
  BOOL result = CredDeleteW(
    target_name.c_str(),
    CRED_TYPE_GENERIC,
    0
  );
  
  // Success if deleted or if it didn't exist
  return result == TRUE || GetLastError() == ERROR_NOT_FOUND;
}

// Delete all values with the same prefix
bool CrossvaultWindowsPlugin::DeleteAll(const std::string& prefix) {
  DWORD count = 0;
  PCREDENTIALW* credentials = nullptr;
  
  // Enumerate all credentials
  BOOL result = CredEnumerateW(
    nullptr,
    0,
    &count,
    &credentials
  );
  
  if (result != TRUE || !credentials) {
    return true; // No credentials to delete
  }
  
  std::wstring search_prefix = Utf8ToWide(
    prefix.empty() ? "io.alexmelnyk.crossvault:" : prefix + ":"
  );
  
  bool all_deleted = true;
  
  for (DWORD i = 0; i < count; i++) {
    std::wstring target_name(credentials[i]->TargetName);
    
    // Check if this credential matches our prefix
    if (target_name.find(search_prefix) == 0) {
      BOOL delete_result = CredDeleteW(
        credentials[i]->TargetName,
        CRED_TYPE_GENERIC,
        0
      );
      
      if (delete_result != TRUE) {
        all_deleted = false;
      }
    }
  }
  
  CredFree(credentials);
  return all_deleted;
}

void CrossvaultWindowsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  
  const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
  
  if (!arguments) {
    result->Error("INVALID_ARGUMENT", "Arguments must be a map");
    return;
  }
  
  // Extract common parameters
  std::string prefix = "";
  auto prefix_it = arguments->find(flutter::EncodableValue("prefix"));
  if (prefix_it != arguments->end()) {
    const auto* prefix_value = std::get_if<std::string>(&prefix_it->second);
    if (prefix_value) {
      prefix = *prefix_value;
    }
  }
  
  std::string persist = "localMachine";
  auto persist_it = arguments->find(flutter::EncodableValue("persist"));
  if (persist_it != arguments->end()) {
    const auto* persist_value = std::get_if<std::string>(&persist_it->second);
    if (persist_value) {
      persist = *persist_value;
    }
  }
  
  bool useTPM = false;
  auto useTPM_it = arguments->find(flutter::EncodableValue("useTPM"));
  if (useTPM_it != arguments->end()) {
    const auto* useTPM_value = std::get_if<bool>(&useTPM_it->second);
    if (useTPM_value) {
      useTPM = *useTPM_value;
    }
  }
  
  // Handle methods
  if (method_call.method_name() == "existsKey") {
    auto key_it = arguments->find(flutter::EncodableValue("key"));
    if (key_it == arguments->end()) {
      result->Error("INVALID_ARGUMENT", "Key is required");
      return;
    }
    
    const auto* key = std::get_if<std::string>(&key_it->second);
    if (!key) {
      result->Error("INVALID_ARGUMENT", "Key must be a string");
      return;
    }
    
    bool exists = ExistsKey(*key, prefix);
    result->Success(flutter::EncodableValue(exists));
    
  } else if (method_call.method_name() == "getValue") {
    auto key_it = arguments->find(flutter::EncodableValue("key"));
    if (key_it == arguments->end()) {
      result->Error("INVALID_ARGUMENT", "Key is required");
      return;
    }
    
    const auto* key = std::get_if<std::string>(&key_it->second);
    if (!key) {
      result->Error("INVALID_ARGUMENT", "Key must be a string");
      return;
    }
    
    std::string value = GetValue(*key, prefix);
    if (value.empty() && !ExistsKey(*key, prefix)) {
      result->Success(); // Return null if key doesn't exist
    } else {
      result->Success(flutter::EncodableValue(value));
    }
    
  } else if (method_call.method_name() == "setValue") {
    auto key_it = arguments->find(flutter::EncodableValue("key"));
    auto value_it = arguments->find(flutter::EncodableValue("value"));
    
    if (key_it == arguments->end() || value_it == arguments->end()) {
      result->Error("INVALID_ARGUMENT", "Key and value are required");
      return;
    }
    
    const auto* key = std::get_if<std::string>(&key_it->second);
    const auto* value = std::get_if<std::string>(&value_it->second);
    
    if (!key || !value) {
      result->Error("INVALID_ARGUMENT", "Key and value must be strings");
      return;
    }
    
    bool success = SetValue(*key, *value, prefix, persist, useTPM);
    if (success) {
      result->Success();
    } else {
      result->Error("CREDENTIAL_ERROR", "Failed to save credential");
    }
    
  } else if (method_call.method_name() == "deleteValue") {
    auto key_it = arguments->find(flutter::EncodableValue("key"));
    if (key_it == arguments->end()) {
      result->Error("INVALID_ARGUMENT", "Key is required");
      return;
    }
    
    const auto* key = std::get_if<std::string>(&key_it->second);
    if (!key) {
      result->Error("INVALID_ARGUMENT", "Key must be a string");
      return;
    }
    
    bool success = DeleteValue(*key, prefix);
    if (success) {
      result->Success();
    } else {
      result->Error("CREDENTIAL_ERROR", "Failed to delete credential");
    }
    
  } else if (method_call.method_name() == "deleteAll") {
    bool success = DeleteAll(prefix);
    if (success) {
      result->Success();
    } else {
      result->Error("CREDENTIAL_ERROR", "Failed to delete all credentials");
    }
    
  } else {
    result->NotImplemented();
  }
}

}  // namespace crossvault_windows
