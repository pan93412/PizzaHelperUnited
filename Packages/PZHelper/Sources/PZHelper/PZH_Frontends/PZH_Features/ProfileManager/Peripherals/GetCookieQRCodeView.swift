// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - GetCookieQRCodeView

struct GetCookieQRCodeView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State var viewModel = GetCookieQRCodeViewModel.shared
    @Binding var cookie: String
    @Binding var deviceFP: String
    @Binding var deviceID: String

    private var qrWidth: CGFloat {
        #if os(OSX) || targetEnvironment(macCatalyst)
        340
        #else
        280
        #endif
    }

    private var qrImage: Image? {
        guard let qrCodeAndTicket = viewModel.qrCodeAndTicket else { return nil }
        let newSize = CGSize(width: qrWidth, height: qrWidth)
        guard let imgResized = qrCodeAndTicket.qrCode.directResized(
            size: newSize,
            quality: .none
        ) else { return nil } // 应该不会出现这种情况。
        return Image(decorative: imgResized, scale: 1)
    }

    private static var isMiyousheInstalled: Bool {
        #if !canImport(UIKit)
        false
        #else
        UIApplication.shared.canOpenURL(URL(string: miyousheHeader)!)
        #endif
    }

    private static var miyousheHeader: String { "mihoyobbs://" }

    private static var miyousheStorePage: String {
        "https://apps.apple.com/cn/app/id1470182559"
    }

    private var shouldShowRetryButton: Bool {
        viewModel.qrCodeAndTicket != nil || viewModel.error != nil
    }

    private func fireAutoCheckScanningConfirmationStatus() async {
        guard !viewModel.scanningConfirmationStatus.isBusy else { return }
        guard let ticket = viewModel.qrCodeAndTicket?.ticket else { return }
        let task = Task { @MainActor [weak viewModel] in
            var counter = 0
            loopTask: while case let .automatically(task) = viewModel?.scanningConfirmationStatus, !task.isCancelled {
                guard let viewModel = viewModel else { break loopTask }
                do {
                    let status = try await HoYo.queryQRCodeStatus(
                        deviceId: viewModel.taskId,
                        ticket: ticket
                    )
                    if let parsedResult = try await status.parsed() {
                        try await parseGameToken(from: parsedResult, dismiss: true)
                        break loopTask
                    }
                    try await Task.sleep(nanoseconds: 3 * 1_000_000_000) // 3sec.
                } catch {
                    if error._code != NSURLErrorNetworkConnectionLost || counter >= 20 {
                        viewModel.error = error
                        counter = 0
                        break loopTask
                    } else {
                        counter += 1
                    }
                }
            }
            viewModel?.scanningConfirmationStatus = .idle
        }
        viewModel.scanningConfirmationStatus = .automatically(task)
    }

    private func loginCheckScannedButtonDidPress(ticket: String) async {
        viewModel.cancelAllConfirmationTasks(resetState: false)
        let task = Task { @MainActor in
            do {
                let status = try await HoYo.queryQRCodeStatus(
                    deviceId: viewModel.taskId,
                    ticket: ticket
                )
                if let parsedResult = try await status.parsed() {
                    try await parseGameToken(from: parsedResult, dismiss: true)
                } else {
                    viewModel.isNotScannedAlertShown = true
                }
            } catch {
                viewModel.error = error
            }
            viewModel.scanningConfirmationStatus = .idle
        }
        viewModel.scanningConfirmationStatus = .manually(task)
    }

    private func parseGameToken(
        from parsedResult: QueryQRCodeStatus.ParsedResult,
        dismiss shouldDismiss: Bool = true
    ) async throws {
        var cookie = ""
        cookie += "stuid=" + parsedResult.accountId + "; "
        cookie += "stoken=" + parsedResult.stoken + "; "
        cookie += "ltuid=" + parsedResult.accountId + "; "
        cookie += "ltoken=" + parsedResult.ltoken + "; "
        cookie += "mid=" + parsedResult.mid + "; "
        try await extraCookieProcess(cookie: &cookie)
        self.cookie = cookie
        if shouldDismiss {
            presentationMode.wrappedValue.dismiss()
        }
    }

    @ViewBuilder
    private func errorView() -> some View {
        if let error = viewModel.error {
            Label {
                Text(error.localizedDescription)
            } icon: {
                Image(systemSymbol: .exclamationmarkCircle)
                    .foregroundStyle(.red)
            }.onAppear {
                viewModel.qrCodeAndTicket = nil
            }
        }
    }

    @ViewBuilder
    private func qrImageView(_ image: Image) -> some View {
        HStack(alignment: .center) {
            Spacer()
            ShareLink(
                item: image,
                preview: SharePreview(
                    "profileMgr.account.qr_code_login.shared_qr_code_title".i18nPZHelper,
                    image: image
                )
            ) {
                image
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: qrWidth, height: qrWidth + 12, alignment: .top)
                    .padding()
            }
            Spacer()
        }
        .overlay(alignment: .bottom) {
            Text("profileMgr.account.qr_code_login.click_qr_to_save".i18nPZHelper).font(.footnote)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.primary.opacity(0.05)))
        }
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    errorView()
                    if let qrCodeAndTicket = viewModel.qrCodeAndTicket, let qrImage = qrImage {
                        qrImageView(qrImage)
                        if case .manually = viewModel.scanningConfirmationStatus {
                            ProgressView()
                        } else {
                            Button("profileMgr.account.qr_code_login.check_scanned".i18nPZHelper) {
                                Task {
                                    await loginCheckScannedButtonDidPress(
                                        ticket: qrCodeAndTicket.ticket
                                    )
                                }
                            }.onAppear {
                                Task {
                                    await fireAutoCheckScanningConfirmationStatus()
                                }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                    if shouldShowRetryButton {
                        Button("profileMgr.account.qr_code_login.regenerate_qrcode".i18nPZHelper) {
                            simpleTaptic(type: .light)
                            viewModel.reCreateQRCode()
                        }
                    }
                    if Self.isMiyousheInstalled {
                        Link(destination: URL(string: Self.miyousheHeader + "me")!) {
                            Text("profileMgr.account.qr_code_login.open_miyoushe".i18nPZHelper)
                        }
                    } else {
                        Link(destination: URL(string: Self.miyousheStorePage)!) {
                            Text("profileMgr.account.qr_code_login.open_miyoushe_mas_page".i18nPZHelper)
                        }
                    }
                } footer: {
                    Text("profileMgr.account.qr_code_login.footer".i18nPZHelper)
                }
            }
            .alert(
                "profileMgr.account.qr_code_login.not_scanned_alert".i18nPZHelper,
                isPresented: $viewModel.isNotScannedAlertShown
            ) {
                Button("sys.done".i18nBaseKit) {
                    viewModel.isNotScannedAlertShown.toggle()
                }
            }
            .navigationTitle("profileMgr.account.qr_code_login.title".i18nPZHelper)
            .navBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("sys.cancel".i18nBaseKit) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - GetCookieQRCodeViewModel

// Credit: Bill Haku for the fix.
@Observable
final class GetCookieQRCodeViewModel: ObservableObject, @unchecked Sendable {
    // MARK: Lifecycle

    init() {
        self.taskId = .init()
        reCreateQRCode()
    }

    deinit {
        scanningConfirmationStatus = .idle
    }

    // MARK: Public

    public func reCreateQRCode() {
        taskId = .init()
        Task { @MainActor in
            do {
                self.qrCodeAndTicket = try await HoYo.generateLoginQRCode(deviceId: self.taskId)
                self.error = nil
            } catch {
                self.error = error
            }
        }
    }

    // MARK: Internal

    enum ScanningConfirmationStatus: Sendable {
        case manually(Task<Void, Never>)
        case automatically(Task<Void, Never>)
        case idle

        // MARK: Internal

        var isBusy: Bool {
            switch self {
            case .automatically, .manually: true
            case .idle: false
            }
        }
    }

    nonisolated(unsafe) static var shared: GetCookieQRCodeViewModel = .init()

    var qrCodeAndTicket: (qrCode: CGImage, ticket: String)?
    var taskId: UUID
    var scanningConfirmationStatus: ScanningConfirmationStatus = .idle
    var isNotScannedAlertShown: Bool = false

    var error: Error? {
        didSet {
            if error != nil {
                qrCodeAndTicket = nil
            }
        }
    }

    func cancelAllConfirmationTasks(resetState: Bool) {
        switch scanningConfirmationStatus {
        case let .automatically(task), let .manually(task):
            task.cancel()
            if resetState {
                scanningConfirmationStatus = .idle
            }
        case .idle: return
        }
    }
}
