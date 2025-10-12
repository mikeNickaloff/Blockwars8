import QtQuick 2.4
import QtQuick.Particles 2.0
import "."

Item {
    objectName: "Particle scene"
    width: parent.width
    height: parent.height
    id: launchController

    function burstAt(xpos, ypos) {
        flashEmitter.lifeSpan = 2600
        flashEmitter.burst(65, xpos, ypos)
    }
    ParticleSystem {
        id: particleSystem
        anchors.fill: parent
    }
    function enableEmitter() {
        flashEmitter.enabled = true
    }
    function disableEmitter() {
        flashEmitter.enabled = false
    }
    ImageParticle {

        objectName: "FlashParticle"
        groups: ["FlashParticles"]
        source: "qrc:///images/particles/particle.png"
        // color: "#00aaff"
        colorVariation: 0
        alpha: 0.7
        alphaVariation: 0
        redVariation: 0
        greenVariation: 0
        blueVariation: 0
        rotation: 0
        rotationVariation: 0
        autoRotation: false
        rotationVelocity: 0
        rotationVelocityVariation: 0
        entryEffect: ImageParticle.Scale
        system: particleSystem
    }

    ImageParticle {
        objectName: "FlashTracer"
        groups: ["FlashParticles"]
        source: "qrc:///images/particles/star.png"
        // color: "#aaffff"
        colorVariation: 0
        alpha: 0.5
        alphaVariation: 0
        redVariation: 0
        greenVariation: 0
        blueVariation: 0
        rotation: 0
        rotationVariation: 0
        autoRotation: false
        rotationVelocity: 0
        rotationVelocityVariation: 0
        entryEffect: ImageParticle.Scale
        system: particleSystem
    }

    Emitter {
        id: flashEmitter
        objectName: "FlashEmiter"
        x: 0
        y: 0
        width: 20
        height: 20
        enabled: false
        group: "FlashParticles"
        emitRate: 30
        maximumEmitted: 75
        startTime: 0
        lifeSpan: 800
        lifeSpanVariation: 0
        size: 30
        sizeVariation: 1
        endSize: 16
        velocityFromMovement: 63
        system: particleSystem
        velocity: PointDirection {
            x: 7
            xVariation: 60
            y: 0
            yVariation: 35
        }
        acceleration: PointDirection {
            x: 1
            xVariation: 27
            y: 0
            yVariation: 21
        }
        shape: EllipseShape {
            fill: true
        }
    }

    Gravity {
        objectName: "GravityBox"
        x: 0
        y: 0
        width: 180
        height: 180
        enabled: true
        groups: []
        whenCollidingWith: []
        once: false
        angle: 90
        magnitude: 153
        system: particleSystem
    }
}
