//
//  ContentView.swift
//  ExampleApp
//
//  Created by Manukant Harshmani Tyagi on 25/02/26.
//

import SwiftUI
import RazorpayBankingWrapper

// MARK: - Input Mode

enum InputMode: String, CaseIterable {
    case form = "Form"
    case rawJSON = "Raw JSON"
}

// MARK: - Config Type Option

enum ConfigTypeOption: String, CaseIterable {
    case ntrpPayment = "NTRP_PAYMENT"
    case custom = "Custom"

    var displayName: String {
        switch self {
        case .ntrpPayment: return "NTRP Payment"
        case .custom: return "Custom (Manual)"
        }
    }
}

// MARK: - Payment ViewModel

final class PaymentViewModel: ObservableObject, RazorpayPaymentDelegate {
    
    init() {
        rawJSON = """
            {
                           "config_type": "\(selectedConfigType.rawValue)",
                            "data": {
                                "Test" : "ete",
                                "merchIdVal": "\(merchantId)",
                                "encrequestparameter": "\(encryptedRequestParameter)",
                                "reqdigitalsignature": "\(encryptedRequestParameter)",
                                "authKey": "\(authKey)",
                                "bank": "\(bank)",
                                "testKey": "dsfv"
                            },
                        "extrafield": "Extra",
                          "ep": "\(selectedEnvironment)"
            }
    """
    }
    private var razorpayPayment: RazorpayPayment?

    // Input mode
    @Published var inputMode: InputMode = .form

    // Config type
    @Published var selectedConfigType: ConfigTypeOption = .ntrpPayment
    @Published var customConfigType: String = ""

    // Input fields
    @Published var merchantId: String = ""
    @Published var encryptedRequestParameter: String = ""
    @Published var digitalSignature: String = #""#
    @Published var authKey: String = ""
    @Published var bank: String = "hdfc"
    @Published var selectedEnvironment: String = "dev"

    // Raw JSON mode
    @Published var rawJSON: String = """
        
        """

    // State
    @Published var statusMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isSDKInitialized: Bool = false

    // Last SDK response (stored for "View Response" sheet)
    @Published var showResponseSheet: Bool = false
    @Published var lastResponseTitle: String = ""
    @Published var lastResponseCode: Int?
    @Published var lastResponseMessage: String?
    @Published var lastResponseData: [String: Any]?

    let environments = ["dev", "uat", "prod"]

    /// The resolved config_type string
    var configTypeValue: String {
        selectedConfigType == .custom ? customConfigType : selectedConfigType.rawValue
    }

    func initializeSDK() {
        razorpayPayment = RazorpayPayment.initialize(delegate: self)
//        razorpayPayment?.delegate = self
        isSDKInitialized = true
        statusMessage = "SDK Initialized"
    }

    func openPayment() {
        guard let payment = razorpayPayment else {
            statusMessage = "SDK not initialized"
            return
        }

        let options: [String: Any]

        if inputMode == .rawJSON {
            
            do {
                guard let data = rawJSON.data(using: .utf8),  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    statusMessage = "Error: Invalid JSON"
                    return
                }
                
                options = json
                
            } catch let error {
                statusMessage = "Error: Invalid JSON"
                return
            }
            
        } else {
            options = [
                "config_type": configTypeValue,
                "ep": selectedEnvironment,
                "data": [
                    "merchIdVal": merchantId,
                    "encrequestparameter": encryptedRequestParameter,
                    "reqdigitalsignature": digitalSignature,
                    "authKey": authKey,
                    "bank": bank
                ]
            ]
        }

        statusMessage = ""
        DispatchQueue.global(qos: .background).async {
            payment.open(options: options)
            
        }
    }

    func clearFields() {
        merchantId = ""
        encryptedRequestParameter = ""
        digitalSignature = ""
        authKey = ""
        bank = ""
        customConfigType = ""
        rawJSON = ""
        statusMessage = ""
    }

    // MARK: - RazorpayPaymentDelegate

    func onPaymentSuccess(paymentData: PaymentData) {
        DispatchQueue.main.async {
            let data = paymentData.getData()
            self.lastResponseTitle = "Payment Success"
            self.lastResponseCode = nil
            self.lastResponseMessage = nil
            self.lastResponseData = data
            self.statusMessage = "Payment Success"
        }
    }

    func onPaymentFail(code: Int, response: String?, paymentData: PaymentData?) {
        DispatchQueue.main.async {
            self.lastResponseTitle = "Payment Failed"
            self.lastResponseCode = code
            self.lastResponseMessage = response
            self.lastResponseData = paymentData?.getData()
            self.statusMessage = "Payment Failed (Code: \(code))"
        }
    }

    func showLoader() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }

    func hideLoader() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @StateObject private var viewModel = PaymentViewModel()

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Input Mode
                Section("Input Mode") {
                    Picker("Mode", selection: $viewModel.inputMode) {
                        ForEach(InputMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if viewModel.inputMode == .form {
                    formInputSections
                } else {
                    rawJSONSection
                }

                // MARK: Actions
                Section {
                    Button {
                        viewModel.openPayment()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Open Payment")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.isSDKInitialized || viewModel.isLoading)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)

                    Button("Clear Fields", role: .destructive) {
                        viewModel.clearFields()
                    }
                    .frame(maxWidth: .infinity)
                }

                // MARK: Status
                if !viewModel.statusMessage.isEmpty {
                    Section("Status") {
                        Text(viewModel.statusMessage)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(
                                viewModel.statusMessage.contains("Error") || viewModel.statusMessage.contains("Failed")
                                    ? .red
                                    : .green
                            )
                            .textSelection(.enabled)

                        if viewModel.lastResponseTitle != "" {
                            Button {
                                viewModel.showResponseSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "doc.text.magnifyingglass")
                                    Text("View Full Response")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Checkout Bank Facade")
            .navigationBarTitleDisplayMode(.inline)
            .disabled(viewModel.isLoading)
            .onAppear {
                viewModel.initializeSDK()
            }
            .sheet(isPresented: $viewModel.showResponseSheet) {
                SDKResponseView(
                    title: viewModel.lastResponseTitle,
                    code: viewModel.lastResponseCode,
                    message: viewModel.lastResponseMessage,
                    data: viewModel.lastResponseData
                )
            }
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        VStack(spacing: 12) {
                            ProgressView()
                                .controlSize(.large)
                            Text("Processing...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    // MARK: - Form Input Sections

    @ViewBuilder
    private var formInputSections: some View {
        // Config Type
        Section("Config Type") {
            Picker("Config Type", selection: $viewModel.selectedConfigType) {
                ForEach(ConfigTypeOption.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }

            if viewModel.selectedConfigType == .custom {
                InputField(title: "Custom Config Type", text: $viewModel.customConfigType)
            }
        }

        // Environment
        Section("Environment") {
            Picker("Environment", selection: $viewModel.selectedEnvironment) {
                ForEach(viewModel.environments, id: \.self) { env in
                    Text(env.uppercased()).tag(env)
                }
            }
            .pickerStyle(.segmented)
        }

        // Merchant Details
        Section("Merchant Details") {
            InputField(title: "Merchant ID", text: $viewModel.merchantId)
            InputField(title: "Bank", text: $viewModel.bank)
            InputField(title: "Auth Key", text: $viewModel.authKey)
        }

        // Payment Data
        Section("Payment Data") {
            MultiLineField(title: "Encrypted Request Parameter", text: $viewModel.encryptedRequestParameter)
            MultiLineField(title: "Digital Signature", text: $viewModel.digitalSignature)
        }
    }

    // MARK: - Raw JSON Section

    @ViewBuilder
    private var rawJSONSection: some View {
        Section("Raw JSON") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Paste the full JSON options string")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $viewModel.rawJSON)
                    .frame(minHeight: 200)
                    .font(.system(.caption, design: .monospaced))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Input Field Component

struct InputField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
    }
}

// MARK: - Multi-Line Field Component

struct MultiLineField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
//            ScrollView{
                TextEditor(text: $text)
                    .frame(minHeight: 150)
                    .font(.system(.caption, design: .monospaced))
//                    .scrollDisabled(true)
//            }
            
//            .frame(maxHeight: 150)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - SDK Response View (Sheet)

struct SDKResponseView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let code: Int?
    let message: String?
    let data: [String: Any]?

    var body: some View {
        NavigationStack {
            List {
                // Result header
                Section {
                    HStack {
                        Image(systemName: title.contains("Success") ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(title.contains("Success") ? .green : .red)
                            .font(.title2)
                        Text(title)
                            .font(.headline)
                    }
                }

                // Error details (only for failure)
                if code != nil || message != nil {
                    Section("Error Details") {
                        if let code = code {
                            row(key: "Code", value: "\(code)")
                        }
                        if let message = message {
                            row(key: "Message", value: message)
                        }
                    }
                }

                // PaymentData dictionary
                if let data = data, !data.isEmpty {
                    Section("PaymentData") {
                        ForEach(data.keys.sorted(), id: \.self) { key in
                            row(key: key, value: stringValue(data[key]))
                        }
                    }
                } else {
                    Section("PaymentData") {
                        Text("No data received")
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }
            }
            .navigationTitle("SDK Response")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func row(key: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
        }
    }

    private func stringValue(_ value: Any?) -> String {
        guard let value = value else { return "nil" }
        if let dict = value as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return "\(value)"
    }
}

#Preview {
    ContentView()
}
