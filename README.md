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
3. Choose the version or branch you need, then add the package to your app target.

**Usage:** Use only `import RazorpayBankWrapper` in your app. You may see another module (e.g. RazorpayBankWrapperShim) in the package; that is an internal dependency—do not import it.

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'RazorpayBankWrapper'
```

Then run:

```bash
pod install
```

Open the `.xcworkspace` and use `import RazorpayBankWrapper` in your code.

## Usage

In your Swift code:

```swift
import RazorpayBankWrapper

// Use the SDK APIs as needed

## License

See [LICENSE.md](LICENSE.md) for details.
