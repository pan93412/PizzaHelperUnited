// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

public enum MiHoYoAPIError: Error, LocalizedError {
    case verificationNeeded
    case fingerPrintInvalidOrMissing
    case sTokenV2InvalidOrMissing
    case reloginRequired
    case other(retcode: Int, message: String)

    // MARK: Lifecycle

    public init(retcode: Int, message: String) {
        self = switch retcode {
        case 1034, 10035: .verificationNeeded
        case 5003: .fingerPrintInvalidOrMissing
        case 10001: .reloginRequired
        default: .other(retcode: retcode, message: message)
        }
    }

    // MARK: Public

    public var description: String { localizedDescription }

    public var localizedDescription: String {
        switch self {
        case .verificationNeeded: "MiHoYoAPIError.verificationNeeded".i18nAK
        case .fingerPrintInvalidOrMissing: "MiHoYoAPIError.fingerPrintInvalidOrMissing".i18nAK
        case .sTokenV2InvalidOrMissing: "MiHoYoAPIError.sTokenV2InvalidOrMissing".i18nAK
        case .reloginRequired: "MiHoYoAPIError.reloginRequired".i18nAK
        case let .other(retcode, message):
            "[HoYoAPIErr] Ret: \(retcode); Msg: \(message)"
        }
    }

    public var errorDescription: String? {
        localizedDescription
    }
}
