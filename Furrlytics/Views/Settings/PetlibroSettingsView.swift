import SwiftUI
import CryptoKit

struct PetlibroSettingsView: View {
    @Environment(PetlibroService.self) private var petlibroService

    @State private var email = ""
    @State private var password = ""
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    @State private var showDisconnectConfirm = false

    var body: some View {
        List {
            statusSection
            if petlibroService.isAuthenticated {
                disconnectSection
            } else {
                credentialSection
            }
        }
        .navigationTitle("Petlibro")
        .onAppear { loadSavedEmail() }
        .alert("断开连接", isPresented: $showDisconnectConfirm) {
            Button("断开", role: .destructive) { disconnect() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定要断开 Petlibro 连接吗？")
        }
    }

    // MARK: - Subviews

    private var statusSection: some View {
        Section("状态") {
            HStack {
                Image(systemName: petlibroService.isAuthenticated ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(petlibroService.isAuthenticated ? .green : .red)
                Text(petlibroService.isAuthenticated ? "已连接" : "未连接")
            }
        }
    }

    private var credentialSection: some View {
        Section("连接") {
            TextField("Petlibro 邮箱", text: $email)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            SecureField("Petlibro 密码", text: $password)
                .textContentType(.password)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await connectPetlibro() }
            } label: {
                if isAuthenticating {
                    ProgressView()
                } else {
                    Text("连接")
                }
            }
            .disabled(!canConnect || isAuthenticating)
        }
    }

    private var disconnectSection: some View {
        Section {
            Button("断开连接", role: .destructive) {
                showDisconnectConfirm = true
            }
        }
    }

    // MARK: - Computed

    private var canConnect: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    // MARK: - Actions

    private func loadSavedEmail() {
        email = (try? KeychainHelper.read(key: PetlibroCredentialKeys.email)) ?? ""
    }

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
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    private func disconnect() {
        petlibroService.logout()
        try? KeychainHelper.delete(key: PetlibroCredentialKeys.email)
        try? KeychainHelper.delete(key: PetlibroCredentialKeys.passwordHash)
        email = ""
        password = ""
    }

    private func md5Hash(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
