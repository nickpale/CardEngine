//
// Created by Erik Little on 4/2/18.
//

import Foundation

/// Represents someone who labors. These guys build stuff.
public protocol Laborer : Playable {
    /// The skill of this laborer.
    var skill: SkillType { get }

    /// The skill of this laborer. This controls how productive and the quality of their work.
    var skillLevel: Double { get set }
}

/// The type of a worker.
public enum SkillType {
    /// A metal worker. These guys bend metal and stuff.
    case metalWorker

    /// An electrician. These guys install wiring and lights.
    case electrician

    /// A painter. These guys make things pretty.
    case painter

    /// A foreman. These guys make other workers more productive.
    case foreman

    /// A random skill.
    public static var randomSkill: SkillType {
        // FIXME linux
        return [.electrician, .foreman, .painter, .metalWorker][Int(arc4random_uniform(4))]
    }
}

/// Represents a worker. These guys build stuff.
public struct Worker : Laborer {
    /// The type of this playable.
    public let playType = PlayType.worker

    /// The skill of this laborer.
    public let skill: SkillType

    /// The skill of this laborer. This controls how productive and the quality of their work.
    public var skillLevel = 1.0

    /// Creates a random worker.
    public static func getInstance() -> Worker {
        return Worker(skill: SkillType.randomSkill, skillLevel: 1.0)
    }
}
