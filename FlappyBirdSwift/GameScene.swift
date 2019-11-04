//
//  GameScene.swift
//  FlappyBirdSwift
//
//  Created by zhu bangqian on 2019/11/3.
//  Copyright © 2019 zhu bangqian. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var floor1:SKSpriteNode!
    var floor2:SKSpriteNode!
    var bird:SKSpriteNode!
    
    enum GameStatus {
        case idle
        case running
        case over
    }
    var gameStatus:GameStatus = .idle
    
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        floor1 = SKSpriteNode(imageNamed: "floor")
        floor1.anchorPoint = CGPoint(x: 0, y: 0)
        floor1.position = CGPoint(x: 0, y: 0)
        addChild(floor1)
        
        floor2 = SKSpriteNode(imageNamed: "floor")
        floor2.anchorPoint = CGPoint(x:0, y: 0)
        floor2.position = CGPoint(x: floor1.size.width, y: 0)
        addChild(floor2)
        
        bird = SKSpriteNode(imageNamed: "player1")
        addChild(bird)
        
        shuffle()
    }
    
    func moveScene() {
        floor1.position = CGPoint(x: floor1.position.x-1, y: floor1.position.y)
        floor2.position = CGPoint(x: floor2.position.x-1, y: floor2.position.y)
        
        //check floor position
        if floor1.position.x < -floor1.size.width {
            floor1.position = CGPoint(x: floor2.position.x+floor2.size.width, y: floor1.position.y)
        }
        
        if floor2.position.x < -floor2.size.width {
            floor2.position = CGPoint(x: floor1.position.x+floor1.size.width, y: floor2.position.y)
        }
        
        for pipeNode in self.children where pipeNode.name == "pipe" {
            if let pipeSprite = pipeNode as? SKSpriteNode {
                pipeSprite.position = CGPoint(x: pipeSprite.position.x-1, y: pipeSprite.position.y)
                
                if pipeSprite.position.x < -pipeSprite.size.width*0.5 {
                    pipeSprite.removeFromParent()
                }
            }
        }
    }
    
    func birdStartFly() {
        let flyAction = SKAction.animate(with: [SKTexture(imageNamed: "player1"), SKTexture(imageNamed: "player2"), SKTexture(imageNamed: "player3"), SKTexture(imageNamed: "player2")], timePerFrame: 0.15)
        bird.run(SKAction.repeatForever(flyAction), withKey:"fly")
    }
    
    func birdStopFly() {
        bird.removeAction(forKey: "fly")
    }
    
    //添加上下两个水管
    func addPipes(topSize:CGSize, bottomSize:CGSize) {
        let topTexture = SKTexture(imageNamed: "topPipe")
        let topPipe = SKSpriteNode(texture: topTexture, size: topSize)
        topPipe.name = "pipe"
        topPipe.position = CGPoint(x: self.size.width+topSize.width*0.5, y: self.size.height-topSize.height*0.5)
        
        let bottomTexture = SKTexture(imageNamed: "bottomPipe")
        let bottomPipe = SKSpriteNode(texture: bottomTexture, size: bottomSize)
        bottomPipe.name = "pipe"
        bottomPipe.position = CGPoint(x: self.size.width+bottomSize.width*0.5, y: self.floor1.size.height+bottomSize.height*0.5);
        
        addChild(topPipe)
        addChild(bottomPipe)
    }
    
    func createRandomPipes() {
        let height = self.size.height-self.floor1.size.height
        //2.5~3.5个鸟的高度
        let pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height)))+bird.size.height*2.5
        let pipeWidth = CGFloat(60.0)
        //随机计算顶部pipe的随机高度，这个高度肯定要小于(总的可用高度减去空档的高度)
        let topPipeHeight = CGFloat(arc4random_uniform(UInt32(height-pipeGap)))
        let bottomPipeHeight = height-pipeGap-topPipeHeight
        addPipes(topSize: CGSize(width: pipeWidth, height: topPipeHeight), bottomSize: CGSize(width:pipeWidth , height: bottomPipeHeight))
    }
    
    func startCreateRandomPipesAction() {
        let waitAct = SKAction.wait(forDuration: 3.5, withRange: 1.0)
        let generatePipeAct = SKAction.run {
            self.createRandomPipes()
        }
        
        run(SKAction.repeatForever(SKAction.sequence([waitAct, generatePipeAct])), withKey: "createPipe")
    }
    
    func stopCreateRandomPipesAction() {
        self.removeAction(forKey: "createPipe")
    }
    
    func removeAllPipesNode() {
        for pipe in self.children where pipe.name == "pipe" {
            pipe.removeFromParent()
        }
    }
    
    func shuffle() {
        gameStatus = .idle
        bird.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
        birdStartFly()
        removeAllPipesNode()
    }
    
    func startGame() {
        gameStatus = .running
        startCreateRandomPipesAction()
    }
    
    func gameOver() {
        gameStatus = .over
        birdStopFly()
        stopCreateRandomPipesAction()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameStatus {
        case .idle:
            startGame()
        case .running:
            print("给小鸟一个向上的力")
        case .over:
            shuffle()
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameStatus != .over {
            moveScene()
        }
    }
}
