////  PlayScene.swift//  Seaquest////  Created by Marcio Barros on 11/26/14.//  Copyright (c) 2014 UNIRIO. All rights reserved.//import SpriteKitimport AVFoundation struct PhysicsCategory {    static let None      : UInt32 = 0    static let Submarine : UInt32 = 0b001    static let Diver     : UInt32 = 0b010    static let Shark     : UInt32 = 0b100}class PlayScene: SKScene, SKPhysicsContactDelegate {    let azymuth = SKSpriteNode(imageNamed: "azymuth")    let seaFloor = SKSpriteNode(imageNamed: "seafloor")    let submarine = SKSpriteNode(imageNamed: "submarine")    var minSubY = CGFloat(0.0)    var maxSubY = CGFloat(0.0)    var minSubX = CGFloat(0.0)    var maxSubX = CGFloat(0.0)    var oxygen = 100.0    var oxygenRectangle = SKShapeNode()    var oxygenUsed = SKShapeNode()    var rectUsed = CGRectMake(0, 0, 0, 0)    var oxygenWidth = CGFloat(0.0)    var sharksAndDivers : [Diver] = []	var lifeNodes : [SKSpriteNode] = []    var remainingLifes = 3    var scoreNode = SKLabelNode()    var score = 0	var gamePaused = false	    override func didMoveToView(view: SKView) {		backgroundColor = UIColor(hex: 0x0000FF)				let minX = CGRectGetMinX(frame)		let maxX = CGRectGetMaxX(frame)		let minY = CGRectGetMinY(frame)		let maxY = CGRectGetMaxY(frame)			oxygenWidth = (maxX - minX) * 0.70		var rect = CGRectMake((maxX - minX - oxygenWidth) / 2, minY+10, oxygenWidth, 15)		oxygenRectangle.path = CGPathCreateWithRect(rect, nil)		oxygenRectangle.fillColor = UIColor.whiteColor()		addChild(oxygenRectangle)				physicsWorld.gravity = CGVectorMake(0, 0)		physicsWorld.contactDelegate = self				rectUsed = CGRectMake((maxX - minX - oxygenWidth * CGFloat(oxygen / 100.0)) / 2, minY+10, oxygenWidth * CGFloat(oxygen / 100.0), 15)		oxygenUsed.path = CGPathCreateWithRect(rectUsed, nil)		oxygenUsed.fillColor = UIColor.greenColor()		addChild(oxygenUsed)				let label = SKLabelNode(fontNamed: "Arial-BoldMT")		label.text = "Oxigênio"		label.fontSize = 12		label.position = CGPointMake(minX + 50, minY + 12)		addChild(label)				azymuth.anchorPoint = CGPointMake(0.0, 1.0)		azymuth.position = CGPointMake(minX, maxY - 40)		addChild(azymuth);				seaFloor.anchorPoint = CGPointMake(0.0, 1.0)		seaFloor.position = CGPointMake(minX, minY + seaFloor.size.height + 30)		addChild(seaFloor);				minSubY = minY + seaFloor.size.height + 30 + 10 + submarine.size.height / 2		maxSubY = maxY - azymuth.size.height - 40 - 10 + submarine.size.height / 2		minSubX = minX + 10 + submarine.size.width / 2		maxSubX = maxX - 10 - submarine.size.width / 2				submarine.position = CGPointMake(minSubX + (maxSubX - minSubX) / 2, minSubY + (maxSubY - minSubY) / 2)		submarine.anchorPoint = CGPointMake(0.5, 0.5)		addChild(submarine)			submarine.physicsBody = SKPhysicsBody(rectangleOfSize: submarine.size)		submarine.physicsBody?.dynamic = false		submarine.physicsBody?.categoryBitMask = PhysicsCategory.Submarine		submarine.physicsBody?.contactTestBitMask = PhysicsCategory.Shark | PhysicsCategory.Diver		submarine.physicsBody?.collisionBitMask = PhysicsCategory.None			for i in 0...3 {			var item = Diver(index: i)			sharksAndDivers += [item]			setupSharkAndDiver(i, item: item)		}				createHUD()    }    	func createHUD() {		        // Create a root node to group the HUD elemets        var hud = SKSpriteNode(texture: nil, size: CGSizeMake(self.size.width, self.size.height*0.05))        hud.anchorPoint=CGPointMake(0, 0)        hud.position = CGPointMake(0, self.size.height-hud.size.height)        self.addChild(hud)                // Display the remaining lifes        let lifeSize = CGSizeMake(hud.size.height-10, hud.size.height-10)        for(var i = 0; i<self.remainingLifes; i++) {            var tmpNode = SKSpriteNode(imageNamed: "submarine")            lifeNodes.append(tmpNode)            tmpNode.size = lifeSize            tmpNode.position=CGPointMake(tmpNode.size.width * 1.3 * (1.0 + CGFloat(i)), (hud.size.height-5)/2)            hud.addChild(tmpNode)        }                // Display the current score        self.score = 0        self.scoreNode.position = CGPointMake(hud.size.width-hud.size.width * 0.1, 1)        self.scoreNode.text = "0"        self.scoreNode.fontSize = hud.size.height		self.scoreNode.fontName = "Arial Bold"        hud.addChild(self.scoreNode)            }    func setupSharkAndDiver(position: Int, item: Diver) {        item.shark.position = CGPointMake(-100, minSubY + CGFloat(position * 45))        item.shark.anchorPoint = CGPointMake(0, 1)        addChild(item.shark)	        item.shark.physicsBody = SKPhysicsBody(rectangleOfSize: item.shark.size)        item.shark.physicsBody?.dynamic = true        item.shark.physicsBody?.categoryBitMask = PhysicsCategory.Shark        item.shark.physicsBody?.contactTestBitMask = PhysicsCategory.Submarine        item.shark.physicsBody?.collisionBitMask = PhysicsCategory.None	        let anim1 = SKAction.animateWithTextures([			SKTexture(imageNamed: "shark1"),			SKTexture(imageNamed: "shark2")], timePerFrame: 0.2)                var sharkRun = SKAction.repeatActionForever(anim1)        item.shark.runAction(sharkRun)                item.diver.position = CGPointMake(-100, minSubY + 5 + CGFloat(position * 45))        item.diver.anchorPoint = CGPointMake(0, 1)        addChild(item.diver)	        item.diver.physicsBody = SKPhysicsBody(rectangleOfSize: item.diver.size)        item.diver.physicsBody?.dynamic = true        item.diver.physicsBody?.categoryBitMask = PhysicsCategory.Diver        item.diver.physicsBody?.contactTestBitMask = PhysicsCategory.Submarine        item.diver.physicsBody?.collisionBitMask = PhysicsCategory.None	        let anim2 = SKAction.animateWithTextures([			SKTexture(imageNamed: "diver1"),			SKTexture(imageNamed: "diver2"),			SKTexture(imageNamed: "diver3")], timePerFrame: 0.2)                var diverRun = SKAction.repeatActionForever(anim2)        item.diver.runAction(diverRun)	        resetShark(item)    }        func didBeginContact(contact: SKPhysicsContact) {		if (gamePaused) {			return		}                var firstBody: SKPhysicsBody        var secondBody: SKPhysicsBody                if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {			firstBody = contact.bodyA			secondBody = contact.bodyB		} else {			firstBody = contact.bodyB			secondBody = contact.bodyA        }                if ((firstBody.categoryBitMask & PhysicsCategory.Submarine != 0) && (secondBody.categoryBitMask & PhysicsCategory.Shark != 0)) {			die()        }                if ((firstBody.categoryBitMask & PhysicsCategory.Submarine != 0) && (secondBody.categoryBitMask & PhysicsCategory.Diver != 0)) {			if (secondBody.node?.xScale != 0.0) {				score++				self.scoreNode.text = String(score)				secondBody.node?.xScale = CGFloat(0.0)				runAction(SKAction.playSoundFileNamed("button-09.wav", waitForCompletion: true))			}        }    }        func resetShark(item: Diver) {        item.reset()                var sharkMove : SKAction!        var diverMove : SKAction!                if (item.direction == Direction.Left) {			item.diver.xScale = CGFloat(+1.0)			item.shark.xScale = CGFloat(+1.0)			item.shark.position = CGPointMake(-item.diver.size.width-item.shark.size.width-CGFloat(item.distanceToShark), minSubY + CGFloat(item.index * 45))						sharkMove = SKAction.moveTo(			CGPoint(x: maxSubX + 50, y: item.shark.position.y),			duration: 8)						item.diver.position = CGPointMake(-item.diver.size.width, minSubY + 5 + CGFloat(item.index * 45))						diverMove = SKAction.moveTo(				CGPoint(x: maxSubX + 50 + item.shark.size.width + CGFloat(item.distanceToShark), y: item.diver.position.y),				duration: 8)		} else {			item.diver.xScale = CGFloat(-1.0)			item.shark.xScale = CGFloat(-1.0)			item.shark.position = CGPointMake(maxSubX + submarine.size.width + item.diver.size.width + CGFloat(item.distanceToShark) + 20, minSubY + CGFloat(item.index * 45))						sharkMove = SKAction.moveTo(			CGPoint(x: minSubX - 50, y: item.shark.position.y),			duration: 8)						item.diver.position = CGPointMake(maxSubX + submarine.size.width + 20, minSubY + 5 + CGFloat(item.index * 45))						diverMove = SKAction.moveTo(			CGPoint(x: minSubX - 50 - item.diver.size.width - CGFloat(item.distanceToShark), y: item.diver.position.y),			duration: 8)			        }                var interval = CFTimeInterval(item.random() * 5)        let diverWait = SKAction.waitForDuration(interval)                item.diver.runAction(diverWait, completion: {			item.shark.runAction(sharkMove,				withKey: "run")				item.diver.runAction(SKAction.sequence([diverMove, SKAction.waitForDuration(1.0), SKAction.runBlock { self.resetShark(item) }]),				withKey: "run")        })    }    	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {		var touch = touches.anyObject() as UITouch!		let location = touch.locationInNode(self)		moveSubmarine(location)    }		func moveSubmarine(location: CGPoint) {		if (!gamePaused) {			var newX = min(max(minSubX, location.x), maxSubX)			var newY = min(max(minSubY, location.y), maxSubY)			let actionMove = SKAction.moveTo(CGPointMake(newX, newY), duration: 0.5)			submarine.removeAllActions()			submarine.runAction(actionMove)			submarine.xScale = CGFloat(location.x < submarine.position.x ? -1.0 : 1.0)		}	}	    override func update(currentTime: NSTimeInterval) {		if (gamePaused) {			return		}	        if submarine.position.y >= maxSubY {			oxygen = min(oxygen+1, 100)		}        else {			oxygen -= 0.1			if (oxygen < 0) { die(); oxygen = 0.0 }        }                let minX = CGRectGetMinX(frame)        let maxX = CGRectGetMaxX(frame)        let minY = CGRectGetMinY(frame)        rectUsed = CGRectMake((maxX - minX - oxygenWidth) / 2, minY+10, oxygenWidth * CGFloat(oxygen / 100.0), 15)        oxygenUsed.path = CGPathCreateWithRect(rectUsed, nil)        oxygenUsed.fillColor = (oxygen > 20) ? UIColor.greenColor() : UIColor.redColor()	}        func die() {		self.gamePaused = true		runAction(SKAction.playSoundFileNamed("button-10.wav", waitForCompletion: true))			submarine.removeAllActions()		for i in 0...3 {			self.sharksAndDivers[i].diver.removeActionForKey("run")			self.sharksAndDivers[i].shark.removeActionForKey("run")		}				// remove one life from hud		if self.remainingLifes > 0 {			self.lifeNodes[remainingLifes-1].alpha = 0.0			self.remainingLifes--;		}					// check if remaining lifes exists		if (self.remainingLifes==0) {			showGameOverAlert()			return		}					// Stop movement, fade out, move to center, fade in		submarine.runAction(SKAction.fadeOutWithDuration(1) , completion: {			self.restartGame()						self.submarine.runAction(SKAction.fadeInWithDuration(1), completion: {				self.gamePaused = false			})		})    }		func restartGame() {		self.submarine.position = CGPointMake(self.size.width/2, self.size.height/2)		self.oxygen = 100				for i in 0...3 {			self.resetShark(self.sharksAndDivers[i])		}	}		func showGameOverAlert() {		self.gamePaused = true		var alert = UIAlertController(title: "Game Over", message: "", preferredStyle: UIAlertControllerStyle.Alert)		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)  { _ in							// restore lifes in HUD			self.remainingLifes=3			for(var i = 0; i<3; i++) {				self.lifeNodes[i].alpha=1.0			}			self.restartGame()			// reset score			self.score = 0			self.scoreNode.text = String(0)			self.gamePaused = false		})					// show alert		self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)	}}