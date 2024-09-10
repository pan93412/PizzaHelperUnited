// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - AssignmentInfo4HSR

/// A struct representing the assignment info generated by Note API
public struct AssignmentInfo4HSR: Sendable {
    // MARK: Public

    // MARK: - Assignment

    /// Each assignment info generated by Note API
    public struct Assignment: Hashable, Sendable {
        // MARK: Public

        /// The status of the assignment
        public enum Status: String, Decodable, Hashable {
            case onGoing = "Ongoing"
            case finished = "Finished"
        }

        public static let totalTime: TimeInterval = 20 * 60 * 60

        @BenchmarkTime public var benchmarkTime: Date

        /// The avatars' icons of the assignment
        public let avatarIconURLs: [URL]
        /// The name of assignment
        public let name: String

        /// Remaining time of assignment
        public var remainingTime: TimeInterval {
            max(_remainingTime - benchmarkTime.timeIntervalSince(fetchTime), 0)
        }

        /// The status of the assignment
        public var status: Status {
            remainingTime == 0 ? .finished : .onGoing
        }

        /// The finished time of assignment
        public var finishedTime: Date {
            Date(timeInterval: _remainingTime, since: fetchTime)
        }

        /// Percentage of Completion
        public var percOfCompletion: Double {
            1.0 - remainingTime / Self.totalTime
        }

        // MARK: Private

        // MARK: CodingKeys

        private enum CodingKeys: String, CodingKey {
            case status
            case remainingTime = "remaining_time"
            case avatarIconURLs = "avatars"
            case name
        }

        /// The time when this struct is generated
        private let fetchTime: Date = .init()

        /// Remaining time of assignment when fetch
        private let _remainingTime: TimeInterval
    }

    /// Details of all accepted assignments
    public var assignments: [Assignment]
    /// Max assignments number
    public let totalAssignmentNumber: Int
    /// Current accepted assignment number
    public let acceptedAssignmentNumber: Int

    /// The number on going assignments
    public var onGoingAssignmentNumber: Int {
        assignments.map { assignment in
            assignment.status == .onGoing ? 1 : 0
        }.reduce(0, +)
    }

    // MARK: Private

    // MARK: CodingKeys

    private enum CodingKeys: String, CodingKey {
        case assignments = "expeditions"
        case totalAssignmentNumber = "total_expedition_num"
        case acceptedAssignmentNumber = "accepted_epedition_num"
        // Mihoyo's api has a spell error here. So there are 2 keys for this field.
        case alterKeyForAcceptedAssignmentNumber = "accepted_expedition_num"
    }
}

// MARK: Decodable

extension AssignmentInfo4HSR: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.assignments = try container.decode([AssignmentInfo4HSR.Assignment].self, forKey: .assignments)
        self.totalAssignmentNumber = try container.decode(Int.self, forKey: .totalAssignmentNumber)
        if let acceptedAssignmentNumber = try? container.decode(Int.self, forKey: .acceptedAssignmentNumber) {
            self.acceptedAssignmentNumber = acceptedAssignmentNumber
        } else {
            self.acceptedAssignmentNumber = try container.decode(Int.self, forKey: .alterKeyForAcceptedAssignmentNumber)
        }
    }
}

// MARK: - AssignmentInfo4HSR.Assignment + Decodable

extension AssignmentInfo4HSR.Assignment: Decodable {
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder
            .container(keyedBy: CodingKeys.self)
        self._remainingTime = try container.decode(TimeInterval.self, forKey: .remainingTime)
        self.avatarIconURLs = try container.decode([URL].self, forKey: .avatarIconURLs)
        self.name = try container.decode(String.self, forKey: .name)
    }
}

// MARK: - AssignmentInfo4HSR.Assignment + Identifiable

extension AssignmentInfo4HSR.Assignment: Identifiable {
    public var id: String { name }
}

// MARK: - AssignmentInfo4HSR.Assignment + ReferencingBenchmarkTime

extension AssignmentInfo4HSR.Assignment: ReferencingBenchmarkTime {}

// MARK: - AssignmentInfo4HSR + BenchmarkTimeEditable

extension AssignmentInfo4HSR: BenchmarkTimeEditable {
    public func replacingBenchmarkTime(_ newBenchmarkTime: Date) -> AssignmentInfo4HSR {
        var info = self
        info.assignments = assignments.map { assignment in
            assignment.replacingBenchmarkTime(newBenchmarkTime)
        }
        return info
    }
}
