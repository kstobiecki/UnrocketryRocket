import SpriteKit

class RocketParticles {
    static func createSmokeEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Create a pixelated, retro-style smoke texture
        let size = CGSize(width: 16, height: 16)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        
        // Create a more "blocky" particle texture
        context.setFillColor(UIColor.white.cgColor)
        let rect = CGRect(x: 2, y: 2, width: 12, height: 12)
        context.fillEllipse(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        emitter.particleTexture = SKTexture(image: image)
        
        // Basic emitter properties
        emitter.particleBirthRate = 80
        emitter.numParticlesToEmit = -1
        emitter.particleLifetime = 0.8  // Reduced lifetime
        emitter.particleLifetimeRange = 0.2
        
        // Particle movement - matched to obstacle speed
        emitter.particleSpeed = 200  // Match initial obstacle speed
        emitter.particleSpeedRange = 20
        emitter.emissionAngle = -.pi/2
        emitter.emissionAngleRange = .pi/12
        
        // Particle appearance
        emitter.particleAlpha = 0.7
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.8  // Faster fade
        
        // Scale changes for puff effect
        emitter.particleScale = 1.5
        emitter.particleScaleRange = 0.3
        emitter.particleScaleSpeed = 0.5
        
        // More retro-style color
        let smokeGray = UIColor(white: 0.8, alpha: 1.0)
        emitter.particleColor = smokeGray
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .alpha
        
        return emitter
    }
} 