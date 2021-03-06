//
// Created by Erik Little on 4/3/18.
//

import Foundation
import NIO
import Kit

/// Represents the playing area for a game. This contains the context for the entire game.
public final class BuildersBoard : GameContext {
    public typealias RulesType = BuildersRules

    /// The name of this game.
    public static let name = "TheBuilders"

    /// The player who is currently making moves
    public var activePlayer: RulesType.PlayerType {
        return players[0]
    }

    /// The id for this game.
    public let id = UUID()

    /// The accidents that are afflicting a user.
    public internal(set) var accidents = [RulesType.PlayerType: [Accident]]()

    // TODO This is a bit crappy. Eventually we'll probably have another object that encapsulates this state
    /// The cards that are currently in play.
    public internal(set) var cardsInPlay = [RulesType.PlayerType: [BuildersPlayable]]()

    /// Each player's hotel.
    public internal(set) var hotels = [RulesType.PlayerType: Hotel]()

    /// The players in this game.
    public private(set) var players = [RulesType.PlayerType]()

    /// What a turn looks like in this context.
    public private(set) var rules: RulesType!

    /// The run loop for this game.
    let runLoop: EventLoop

    /// Creates a new game with the given players.
    public init(runLoop: EventLoop) {
        self.runLoop = runLoop
        self.rules = BuildersRules(context: self)
    }

    deinit {
        print("Game is dying")
    }

    @discardableResult
    private func nextTurn() -> EventLoopFuture<()> {
        // FIXME Notify who won the game
        guard !rules.isGameOver() else {
            for player in players {
                player.show("Game over!")
            }

            return runLoop.newSucceededFuture(result: ())
        }

        return rules.executeTurn(forPlayer: activePlayer).then {[weak self] void -> EventLoopFuture<()> in
            guard let this = self else { return deadGame }

            this.players = Array(this.players[1...]) + [this.activePlayer]

            return this.nextTurn()
        }.thenIfError {[weak self] error in
            guard let this = self else { return deadGame }

            switch error {
            case let builderError as BuildersError where builderError == .gameDeath:
                return deadGame
            case let builderError as BuildersError where builderError == .badPlay:
                let active = this.activePlayer

                // This wasn't a valid turn, decrement the accident turns
                this.accidents[active] = this.accidents[active, default: []].map({accident in
                    return Accident(type: accident.type, turns: accident.turns - 1)
                })

                return this.nextTurn()
            default:
                fatalError("Unknown error")
            }
        }
    }

    /// Sets up this game with players.
    ///
    /// - parameter players: The players.
    public func setupPlayers(_ players: [RulesType.PlayerType]) {
        assert(players.count >= 2, "You need more players for this game!")

        self.players = players
    }

    /// Starts this game.
    public func startGame() {
        rules.setupGame()

        runLoop.execute {
            print("start first turn")
            self.nextTurn()
        }
    }

    public func stopGame() {
        runLoop.execute {
            for player in self.players {
                player.interfacer.responsePromise?.fail(error: BuildersError.gameDeath)
            }
        }
    }
}
