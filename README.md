# Razorpay Banking Wrapper SDK for iOS

Banking wrapper SDK that integrates with [Razorpay](https://razorpay.com). Add this package or pod only—Razorpay is pulled in automatically.

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

### Swift Package Manager

1. In Xcode: **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/razorpay/razorpay-banking-wrapper-sdk
   ```
3. Choose the version or branch you need, then add the package to your app target. Select the **RazorpayBankingWrapper** product.

**Usage:** Use only `import RazorpayBankingWrapper` in your app. You may see another module (e.g. RazorpayBankWrapperShim) in the package; that is an internal dependency—do not import it.

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'razorpay-banking-wrapper-sdk'
```

Then run:

```bash
pod install
```

Open the `.xcworkspace` and use `import RazorpayBankingWrapper` in your code.

## Usage

In your Swift code:

```swift
import RazorpayBankingWrapper

// Use the SDK APIs as needed
```

Refer to [Razorpay iOS documentation](https://razorpay.com/docs/payments/payment-gateway/ios-integration/) for integration details.

## License

See [LICENSE.md](LICENSE.md) for details.
