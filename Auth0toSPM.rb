# This script is intended to perform the necessary steps of converting Auth0.swift to a Swift Package
# Modifications make should be clearly marked using `comment` below
# This is written in Ruby not because I like it but because the Podspec is in Ruby :(
# I suspect these changes don't support watchOS, but.. tough luck
# Also, iOS tests compile and run but *a few* do not pass (most do) - fails are probably because we don't have a solution for the .m tests files yet 

# CONFIGURE THESE VARIABLES
$spm_repo_location = "/Users/maxc/Desktop/xcode/Auth0SPM"
$auth0_repo_location = "/Users/maxc/Desktop/xcode/Auth0.swift"
$comment = " // Added by Auth0toSPM"

######################## PASTE PODSPEC FILE DEFINITIONS BELOW ########################

web_auth_files = [
  'Auth0/A0ChallengeGenerator.h',
  'Auth0/A0ChallengeGenerator.m',
  'Auth0/A0RSA.h',
  'Auth0/A0RSA.m',
  'Auth0/A0SHA.h',
  'Auth0/A0SHA.m',
  'Auth0/A0SimpleKeychain+RSAPublicKey.swift',
  'Auth0/Array+Encode.swift',
  'Auth0/AuthCancelable.swift',
  'Auth0/AuthProvider.swift',
  'Auth0/AuthSession.swift',
  'Auth0/AuthTransaction.swift',
  'Auth0/AuthenticationServicesSession.swift',
  'Auth0/AuthenticationServicesSessionCallback.swift',
  'Auth0/BaseAuthTransaction.swift',
  'Auth0/BaseWebAuth.swift',
  'Auth0/BioAuthentication.swift',
  'Auth0/ClaimValidators.swift',
  'Auth0/IDTokenSignatureValidator.swift',
  'Auth0/IDTokenValidator.swift',
  'Auth0/IDTokenValidatorContext.swift',
  'Auth0/JWK+RSA.swift',
  'Auth0/JWT+Header.swift',
  'Auth0/JWTAlgorithm.swift',
  'Auth0/NativeAuth.swift',
  'Auth0/NSURLComponents+OAuth2.swift',
  'Auth0/OAuth2Grant.swift',
  'Auth0/ResponseType.swift',
  'Auth0/SessionCallbackTransaction.swift',
  'Auth0/SessionTransaction.swift',
  'Auth0/TransactionStore.swift',
  'Auth0/WebAuthenticatable.swift',
  'Auth0/WebAuthError.swift',
  'Auth0/_ObjectiveWebAuth.swift'
]

ios_files = [
  'Auth0/ControllerModalPresenter.swift',
  'Auth0/MobileWebAuth.swift',
  'Auth0/SafariSession.swift',
  'Auth0/SilentSafariViewController.swift',
  'Auth0/UIApplication+Shared.swift'
]

macos_files = [
  'Auth0/DesktopWebAuth.swift',
  'Auth0/NSApplication+Shared.swift'
]

watchos_exclude_files = [
  *web_auth_files,
  *ios_files,
  *macos_files,
  'Auth0/CredentialsManager.swift',
  'Auth0/CredentialsManagerError.swift'
]

tvos_exclude_files = [
  *web_auth_files,
  *ios_files,
  *macos_files
]

######################## END PODSPEC FILE DEFINITIONS ########################

require 'json'
require 'fileutils'

Dir.chdir($auth0_repo_location)

all_swift_files = Dir.entries("Auth0")
  .reject { | p | p.end_with?(".swift") == false }
  .map { | p | "Auth0/" + p }

objc_files = Dir.entries("Auth0")
  .reject { | p | p.end_with?(".m", ".h") == false }
  .map { | p | "Auth0/" + p }

$configuration = {
  :tvOS => all_swift_files.reject { | p | tvos_exclude_files.include?(p) },
  :iOS => all_swift_files.reject { | p | macos_files.include?(p) },
  :macOS => all_swift_files.reject { | p | ios_files.include?(p) },
  :watchOS => all_swift_files.reject { | p | watchos_exclude_files.include?(p) },

  :objc_classes => objc_files.map { |p| p.sub(".m", "").sub(".h", "") }.uniq,

  :substitutions => {
    # Rather than using a macro, this 'if os' relates to what the macro relates to in the Podspec
    "#if WEB_AUTH_PLATFORM" => "#if os(iOS) || os(macOS) " + $comment,

    # ObjC compatibility changes
    "#import <A0RSA.h>" => "#import \"A0RSA.h\"" + $comment,
    "#import <A0SHA.h>" => "#import \"A0SHA.h\"" + $comment,
    "#import <A0ChallengeGenerator.h>" => "#import \"A0ChallengeGenerator.h\"" + $comment,

    # Test changes - tests currently compile and run but fail (I think maybe because I haven't figured out the best way to get those two .m test files in)
    "import OHHTTPStubs" => "import OHHTTPStubs\nimport OHHTTPStubsSwift" + $comment,
    #'func plistValues(bundle: Bundle) -> (clientId: String, domain: String)? {' => 'func plistValues(bundle: Bundle) -> (clientId: String, domain: String)? { return (clientId: "CLIENT_ID", domain: "samples.auth0.com");' + $comment
  },
}

puts JSON.pretty_generate($configuration)

def perform_substitutions(text) 
  # Make some changes that are required for SPM compatibility
  $configuration[:substitutions].each do | key, val |
    text = text.gsub(key, val + "(original value '" + key + "')" )
  end
  return text
end

def perform_mutations(text)
  text = perform_substitutions(text)

  # If the files mentions an ObjC class, import the ObjC module
  $configuration[:objc_classes].each do | classname |
    # Assume classes will have a space in front of their names when mentioned
    if text.include?(" " + classname) == false
      text = "import Auth0ObjC" + $comment + "\n" + text
      break
    end
  end
  
  # Some files are missing an `import Foundation` - add it if required
  if text.include?("import Foundation") == false
    text = "import Foundation" + $comment + "\n" + text
  end

  return text
end

all_swift_files.each do | p |

  platforms = []

  if $configuration[:tvOS].include?(p)
    platforms << "os(tvOS)"
  end

  if $configuration[:iOS].include?(p)
    platforms << "os(iOS)"
  end

  if $configuration[:macOS].include?(p)
    platforms << "os(macOS)"
  end

  if $configuration[:watchOS].include?(p)
    platforms << "os(watchOS)"
  end

  new_location = p.sub("Auth0/", $spm_repo_location + "/Sources/Auth0/")
  text = File.read(p)

  text = perform_mutations(text)

  # Wrap files with '#if os(a) || os(b) ...' based on podspec rules
  if platforms.any?
    text = "#if " + platforms.join(" || ") + $comment + "\n" + text + "\n#endif" + $comment + "\n"
  end

  File.write(new_location, text)
end

# Copy ObjC files
objc_files.each do | p |

  if p.end_with?("/Auth0.h")
    # Don't copy this file
    next
  end

  new_location = p.gsub("Auth0/", $spm_repo_location + "/Sources/Auth0ObjC/")
  text = File.read(p)

  # Make some changes that are required for SPM compatibility
  text = perform_substitutions(text)

  File.write(new_location, text)
end

# Copy all tests (.swift only, .m is TODO)
all_swift_tests = Dir.entries("Auth0Tests")
  .reject { | p | p.end_with?(".swift") == false }
  .map { | p | "Auth0Tests/" + p }
  
all_swift_tests.each do | p |
  new_location = p.gsub("Auth0Tests/", $spm_repo_location + "/Tests/Auth0Tests/")
  text = File.read(p)

  # Some files are missing an `import UIKit` - add it if required
  if text.include?(" UIView") == true
    text = "import UIKit" + $comment + "\n" + text
  end

  text = perform_mutations(text)

  File.write(new_location, text)
end


# Copy the licence across too
FileUtils.cp($auth0_repo_location + "/LICENSE", $spm_repo_location + "/LICENSE")

loc_a = "/tmp/auth0_diff_original"
loc_b = "/tmp/auth0_diff_spm"

# Create a patch so we can see what's changed
FileUtils.mkdir_p(loc_a)
FileUtils.mkdir_p(loc_b)

FileUtils.rm_rf(loc_a + "/.")
FileUtils.rm_rf(loc_b + "/.")

a = all_swift_files + objc_files + all_swift_tests
a.each do | p |
  FileUtils.cp(p, loc_a)
end

FileUtils.cp_r($spm_repo_location + "/Sources/Auth0/.", loc_b)
FileUtils.cp_r($spm_repo_location + "/Sources/Auth0ObjC/.", loc_b)
FileUtils.cp_r($spm_repo_location + "/Tests/Auth0Tests/.", loc_b)

`git diff #{loc_a} #{loc_b} > #{$spm_repo_location + "/changes.diff"}`
