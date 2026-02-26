// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "razorpay-banking-wrapper-sdk",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "RazorpayBankingWrapper",
            targets: ["RazorpayBankWrapperShim"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/razorpay/razorpay-pod.git", from: "1.4.1"),
    ],
    targets: [
        .binaryTarget(
            name: "RazorpayBankingWrapper",
            path: "Frameworks/RazorpayBankingWrapper.xcframework"
        ),
        .target(
            name: "RazorpayBankWrapperShim",
            dependencies: [
                "RazorpayBankingWrapper",
                .product(name: "RazorpayCheckout", package: "razorpay-pod"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
