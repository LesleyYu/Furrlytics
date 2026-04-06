import SwiftUI
import CryptoKit

struct PetlibroConnectView: View {
    @Environment(PetlibroService.self) private var petlibroService

    @State private var email = ""
    @State private var password = ""
    @State private var isAuthenticating = false
    @State private var errorMessage: String?

    let onComplete: () -> Void
    let onSkip: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                credentialFields
                if let errorMessage {
                    errorBanner(errorMessage)
                }
                connectButton
                skipButton
            }
            .padding()
        }
        .navigationTitle("连接 Petlibro")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "wifi.router.fill")
                .font(.system(size: 40))
                .foregroundStyle(.tint)
            Text("连接 Petlibro 智能喂食器以自动记录干粮数据")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text("此步骤可选，稍后可在设置中连接")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var credentialFields: some View {
        VStack(spacing: 12) {
            TextField("Petlibro 邮箱", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            SecureField("Petlibro 密码", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.red)
            .padding(.horizontal)
    }

    private var connectButton: some View {
        Button {
            Task { await connectPetlibro() }
        } label: {
            Group {
                if isAuthenticating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("连接")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canConnect ? Color.accentColor : Color.gray.opacity(0.3))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canConnect || isAuthenticating)
    }

    private var skipButton: some View {
        Button("跳过", action: onSkip)
            .foregroundStyle(.secondary)
    }

    // MARK: - Computed

    private var canConnect: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    // MARK: - Actions

    private func connectPetlibro() async {
        errorMessage = nil
        isAuthenticating = true
        defer { isAuthenticating = false }

        let hashedPassword = md5Hash(password)

        let result = await petlibroService.authenticate(email: email, hashedPassword: hashedPassword)
        switch result {
        case .success:
            do {
                try KeychainHelper.save(key: PetlibroCredentialKeys.email, value: email)
                try KeychainHelper.save(key: PetlibroCredentialKeys.passwordHash, value: hashedPassword)
            } catch {
                errorMessage = "凭证保存失败: \(error.localizedDescription)"
                return
            }
            onComplete()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    private func md5Hash(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
