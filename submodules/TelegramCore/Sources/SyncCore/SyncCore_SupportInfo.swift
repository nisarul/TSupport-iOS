//
//  SyncCore_SupportInfo.swift
//  _idx_TelegramCore_BEEE04EA_ios_min9.0
//
//  Created by Syed Nisar Ul Haq on 16/10/21.
//

import Foundation
import Postbox

public final class SupportInfo: PostboxCoding, Equatable {
        public let message: String
        public let author: String
        public let date: Date
    
    public init() {
        self.message = String()
        self.author = String()
        self.date = Date.init(timeIntervalSince1970: 0)
    }
    
    public init(message: String, author: String, date: Date) {
        self.message = message
        self.author = author
        self.date = date
    }
    
    public init(decoder: PostboxDecoder) {
        self.message = decoder.decodeStringForKey("m", orElse: "")
        self.author = decoder.decodeStringForKey("a", orElse: "")
        self.date = Date.init(timeIntervalSince1970: decoder.decodeDoubleForKey("d", orElse: 0))
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeString(self.message, forKey: "m")
        encoder.encodeString(self.author, forKey: "a")
        encoder.encodeDouble(self.date.timeIntervalSince1970, forKey: "d")
    }
    
    public static func ==(lhs: SupportInfo, rhs: SupportInfo) -> Bool {
        return lhs.message == rhs.message && lhs.author == rhs.author && lhs.date == rhs.date
    }
}
