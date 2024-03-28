//
//  PasswordResetToken+Ext.swift
//
//
//  Created by Raphaël Payet on 28/03/2024.
//

import Fluent
import Vapor

extension PasswordResetToken {
    func convertToPublic() -> PasswordResetToken.Public {
        PasswordResetToken.Public(id: id, userID: $user.id, expiresAt: expiresAt)
    }
}

extension EventLoopFuture where Value: PasswordResetToken {
    func convertToPublic() -> EventLoopFuture<PasswordResetToken.Public> {
        return self.map { resetToken in
            return resetToken.convertToPublic()
        }
    }
}


extension Collection where Element: PasswordResetToken {
    func convertToPublic() -> [PasswordResetToken.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<PasswordResetToken> {
    func convertToPublic() -> EventLoopFuture<[PasswordResetToken.Public]> {
        return self.map { $0.convertToPublic() }
    }
}
