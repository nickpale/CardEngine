//
// Created by Erik Little on 4/2/18.
//

import Foundation
import NIO

/// Represents the state of a game.
public protocol GameContext : AnyObject {
    /// The type of game this context is playing.
    associatedtype RulesType: GameRules where RulesType.ContextType == Self

    /// The name of this game.
    static var name: String { get }

    /// Creates a new game controlled on `runLoop`.
    init(runLoop: EventLoop)

    /// The player who is currently making moves
    var activePlayer: RulesType.PlayerType { get }

    /// The id for this game.
    var id: UUID { get }

    /// The players in this game.
    var players: [RulesType.PlayerType] { get }

    /// The rules for the game executing in this context.
    var rules: RulesType! { get }

    /// Sets up this game with some players.
    func setupPlayers(_ players: [RulesType.PlayerType])

    /// Starts this game.
    func startGame()

    /// Halts this game.
    func stopGame()
}
