# Be sure to run `pod lib lint razorpay-core-pod.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = "RazorpayBankWrapper"
  s.version          = "1.0.0"
  s.summary          = "Razorpay Banking Wrapper SDK for iOS"
  s.description      = "Banking wrapper SDK that integrates with Razorpay. Depends on Razorpay SDK; add this pod only."
  s.homepage         = "https://github.com/razorpay/razorpay-banking-wrapper-sdk"
  s.license          = { :type => "MIT" }
  s.author           = { "Razorpay" => "support@razorpay.com" }
  s.source           = { :git => "https://github.com/razorpay/razorpay-banking-wrapper-sdk.git", :tag => s.version.to_s }

  s.platform         = :ios, "15.0"
  s.requires_arc     = true

  s.vendored_frameworks = "Frameworks/RazorpayBankWrapper.xcframework"
  s.dependency "razorpay-pod", ">= 1.4.1"
end
