////
////  ContentView.swift
////  FunCubatorMassageAR
////
////  Created by Bizhan on 18.07.25.
////
//
//import SwiftUI
//import RealityKit
//import ARKit
//import AVFoundation
//import UIKit
//import SpriteKit
//
//// MARK: - Главный экран
//struct ContentView: View {
//    @State private var showMassageGame = false
//    @State private var showCostumeGame = false
//    @State private var showRoastGame = false
//    
//    var body: some View {
//        ZStack {
//            ARViewContainer(
//                showMassageGame: $showMassageGame,
//                showCostumeGame: $showCostumeGame,
//                showRoastGame: $showRoastGame
//            )
//            .edgesIgnoringSafeArea(.all)
//            
//            if showMassageGame {
//                MassageView(showMassageGame: $showMassageGame)
//            }
//            
//            if showCostumeGame {
//                CostumeGameView(showCostumeGame: $showCostumeGame)
//            }
//        }
//        .onChange(of: showMassageGame) { newValue in
//            if !newValue {
//                // Сбрасываем состояние костюмов при закрытии массажа
//                showCostumeGame = false
//            }
//        }
//        .fullScreenCover(isPresented: $showRoastGame) {
//            RoastGameView()
//        }
//    }
//}
//
//// MARK: - AR-сцена
//struct ARViewContainer: UIViewRepresentable {
//    @Binding var showMassageGame: Bool
//    @Binding var showCostumeGame: Bool
//    @Binding var showRoastGame: Bool
//    
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//    
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//
//        // Конфигурация AR-сессии
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal]
//        config.environmentTexturing = .automatic
//        arView.session.run(config, options: [])
//
//        // Группа для массажа
//        let massageGroup = Entity()
//        massageGroup.name = "massageGroup"
//
//        // Картинка массажа - безопасная загрузка
//        let massageImagePlane = MeshResource.generatePlane(width: 0.3, height: 0.3)
//        var massageImgMat = UnlitMaterial()
//        
//        if let massageImageTexture = try? TextureResource.load(named: "massage") {
//            massageImgMat.color = .init(texture: MaterialParameters.Texture(massageImageTexture))
//        } else {
//            massageImgMat.color = .init(tint: .red)
//        }
//        
//        let massageImgEntity = ModelEntity(mesh: massageImagePlane, materials: [massageImgMat])
//        massageImgEntity.position = SIMD3(0, 0.2, 0)
//        massageImgEntity.generateCollisionShapes(recursive: true)
//
//        // Текст массажа
//        let massageTextMesh = MeshResource.generateText(
//            "Массажка",
//            extrusionDepth: 0.02,
//            font: .systemFont(ofSize: 0.2),
//            containerFrame: .zero,
//            alignment: .center
//        )
//        let massageTextMaterial = SimpleMaterial(color: .red, isMetallic: false)
//        let massageTextEntity = ModelEntity(mesh: massageTextMesh, materials: [massageTextMaterial])
//        massageTextEntity.generateCollisionShapes(recursive: true)
//        let massageBounds = massageTextEntity.visualBounds(relativeTo: nil)
//        let massageCenterOffsetX = (massageBounds.max.x + massageBounds.min.x) / 2
//        massageTextEntity.position = SIMD3(-massageCenterOffsetX, -0.15, 0)
//
//        massageGroup.addChild(massageImgEntity)
//        massageGroup.addChild(massageTextEntity)
//        massageGroup.position = SIMD3(-0.5, 0.1, -0.6) // Левее
//
//        // Группа для CEO (теперь открывает игру костюмов)
//        let ceoGroup = Entity()
//        ceoGroup.name = "ceoGroup"
//
//        // Картинка CEO - безопасная загрузка
//        let ceoImagePlane = MeshResource.generatePlane(width: 0.3, height: 0.3)
//        var ceoImgMat = UnlitMaterial()
//        
//        if let ceoImageTexture = try? TextureResource.load(named: "ceo") {
//            ceoImgMat.color = .init(texture: MaterialParameters.Texture(ceoImageTexture))
//        } else {
//            ceoImgMat.color = .init(tint: .blue)
//        }
//        
//        let ceoImgEntity = ModelEntity(mesh: ceoImagePlane, materials: [ceoImgMat])
//        ceoImgEntity.position = SIMD3(0, 0.2, 0)
//        ceoImgEntity.generateCollisionShapes(recursive: true)
//
//        // Текст CEO
//        let ceoTextMesh = MeshResource.generateText(
//            "Стать CEO",
//            extrusionDepth: 0.02,
//            font: .systemFont(ofSize: 0.15),
//            containerFrame: .zero,
//            alignment: .center
//        )
//        let ceoTextMaterial = SimpleMaterial(color: .blue, isMetallic: false)
//        let ceoTextEntity = ModelEntity(mesh: ceoTextMesh, materials: [ceoTextMaterial])
//        ceoTextEntity.generateCollisionShapes(recursive: true)
//        let ceoBounds = ceoTextEntity.visualBounds(relativeTo: nil)
//        let ceoCenterOffsetX = (ceoBounds.max.x + ceoBounds.min.x) / 2
//        ceoTextEntity.position = SIMD3(-ceoCenterOffsetX, -0.15, 0)
//
//        ceoGroup.addChild(ceoImgEntity)
//        ceoGroup.addChild(ceoTextEntity)
//        ceoGroup.position = SIMD3(0.5, 0.1, -0.6) // Правее
//
//        // Группа для Mentor Roast (размещаем позади и выше других кнопок)
//        let mentorGroup = Entity()
//        mentorGroup.name = "mentorGroup"
//
//        // Картинка Баходреддина - улучшенная загрузка
//        let mentorImagePlane = MeshResource.generatePlane(width: 0.3, height: 0.3)
//        var mentorImgMat = UnlitMaterial()
//        
//        // Пробуем загрузить через UIImage сначала
//        if let uiImage = UIImage(named: "bahr"),
//           let cgImage = uiImage.cgImage {
//            do {
//                let textureResource = try TextureResource.generate(from: cgImage, options: TextureResource.CreateOptions(semantic: .color))
//                mentorImgMat.color = UnlitMaterial.BaseColor(texture: MaterialParameters.Texture(textureResource))
//                print("✅ bahr изображение загружено через UIImage!")
//            } catch {
//                print("❌ Ошибка создания TextureResource: \(error)")
//                // Пробуем стандартный способ
//                if let mentorImageTexture = try? TextureResource.load(named: "bahr") {
//                    mentorImgMat.color = UnlitMaterial.BaseColor(texture: MaterialParameters.Texture(mentorImageTexture))
//                    print("✅ bahr изображение загружено напрямую!")
//                } else {
//                    mentorImgMat.color = UnlitMaterial.BaseColor(tint: .orange)
//                    print("❌ bahr изображение не найдено, используем fallback")
//                }
//            }
//        } else if let mentorImageTexture = try? TextureResource.load(named: "bahr") {
//            mentorImgMat.color = UnlitMaterial.BaseColor(texture: MaterialParameters.Texture(mentorImageTexture))
//            print("✅ bahr изображение загружено напрямую!")
//        } else {
//            print("❌ bahr изображение не найдено, используем fallback")
//            mentorImgMat.color = UnlitMaterial.BaseColor(tint: .orange)
//        }
//        
//        let mentorImgEntity = ModelEntity(mesh: mentorImagePlane, materials: [mentorImgMat])
//        mentorImgEntity.position = SIMD3(0, 0.2, 0)
//        mentorImgEntity.generateCollisionShapes(recursive: true)
//
//        // Текст Mentor Roast
//        let mentorTextMesh = MeshResource.generateText(
//            "Mentor Roast",
//            extrusionDepth: 0.02,
//            font: .systemFont(ofSize: 0.2, weight: .bold),
//            containerFrame: .zero,
//            alignment: .center
//        )
//        let mentorTextMaterial = SimpleMaterial(color: .orange, isMetallic: false)
//        let mentorTextEntity = ModelEntity(mesh: mentorTextMesh, materials: [mentorTextMaterial])
//        mentorTextEntity.generateCollisionShapes(recursive: true)
//        let mentorBounds = mentorTextEntity.visualBounds(relativeTo: nil)
//        let mentorCenterOffsetX = (mentorBounds.max.x + mentorBounds.min.x) / 2
//        mentorTextEntity.position = SIMD3(-mentorCenterOffsetX, -0.15, 0)
//
//        mentorGroup.addChild(mentorImgEntity)
//        mentorGroup.addChild(mentorTextEntity)
//        mentorGroup.position = SIMD3(0, 0.3, -0.8) // Позади и выше других кнопок
//
//        // Якорь
//        let anchor = AnchorEntity(world: .zero)
//        anchor.addChild(massageGroup)
//        anchor.addChild(ceoGroup)
//        anchor.addChild(mentorGroup)
//        arView.scene.anchors.append(anchor)
//
//        // Жест
//        let tap = UITapGestureRecognizer(
//            target: context.coordinator,
//            action: #selector(Coordinator.handleTap(_:))
//        )
//        arView.addGestureRecognizer(tap)
//        
//        context.coordinator.arView = arView
//
//        return arView
//    }
//    
//    func updateUIView(_ uiView: ARView, context: Context) {}
//    
//    // MARK: Coordinator
//    class Coordinator: NSObject {
//        var parent: ARViewContainer
//        var arView: ARView?
//        
//        init(_ parent: ARViewContainer) {
//            self.parent = parent
//        }
//        
//        @objc func handleTap(_ sender: UITapGestureRecognizer) {
//            guard let arView = arView else { return }
//            
//            let location = sender.location(in: arView)
//            let results = arView.hitTest(location)
//            
//            print("Tap detected at location: \(location)")
//            print("Hit test results count: \(results.count)")
//            
//            for result in results {
//                print("Hit entity: \(result.entity.name)")
//                
//                // Проверяем, к какой группе принадлежит нажатый объект
//                var currentEntity: Entity? = result.entity
//                while currentEntity != nil {
//                    print("Checking entity: \(currentEntity?.name ?? "unnamed")")
//                    
//                    if currentEntity?.name == "massageGroup" {
//                        print("Opening massage game")
//                        DispatchQueue.main.async {
//                            self.parent.showMassageGame = true
//                        }
//                        return
//                    } else if currentEntity?.name == "ceoGroup" {
//                        print("Opening costume game directly")
//                        DispatchQueue.main.async {
//                            self.parent.showCostumeGame = true
//                        }
//                        return
//                    } else if currentEntity?.name == "mentorGroup" {
//                        print("Opening roast game")
//                        DispatchQueue.main.async {
//                            self.parent.showRoastGame = true
//                        }
//                        return
//                    }
//                    currentEntity = currentEntity?.parent
//                }
//            }
//            
//            print("No matching group found")
//        }
//    }
//}
//
//// MARK: - Roast Game View
//struct RoastGameView: UIViewRepresentable {
//    func makeUIView(context: Context) -> SKView {
//        let skView = SKView()
//        let scene = RoastScene(size: UIScreen.main.bounds.size)
//        scene.scaleMode = .resizeFill
//        skView.presentScene(scene)
//        return skView
//    }
//    
//    func updateUIView(_ uiView: SKView, context: Context) {}
//}
//
//// MARK: - Roast Scene (SpriteKit)
//class RoastScene: SKScene, SKPhysicsContactDelegate {
//    
//    // Битмаски для физики
//    enum Category {
//        static let question: UInt32 = 1
//        static let shield: UInt32 = 2
//        static let boss: UInt32 = 4  // BOSS
//    }
//    
//    // Игровые переменные
//    private var headNode: SKSpriteNode!
//    private var shieldNode: SKSpriteNode!
//    private var timerLabel: SKLabelNode!
//    private var gameOverLabel: SKLabelNode!
//    
//    private var startTime: TimeInterval = 0
//    private var elapsed: TimeInterval = 0
//    private var lastQuestionTime: TimeInterval = 0
//    private var lastBossTime: TimeInterval = 0  // BOSS
//    private var lastShieldTextureChange: TimeInterval = 0  // Assets
//    private var currentSpawnInterval: TimeInterval = 1.2
//    private var gameEnded = false
//    
//    // ENERGY-ЩИТ («перегрев»)
//    private var shieldHoldTime: TimeInterval = 0
//    private var shieldCooldown: TimeInterval = 0
//    private let shieldMaxHold: TimeInterval = 3   // сек
//    private let shieldRest: TimeInterval = 1      // сек
//    private var userIsTouching = false
//    private var shieldOverheated = false
//    
//    // Список вопросов
//    private let questions = [
//        "А CI/CD настроено? 🤨",
//        "Кто будет платить за OpenAI API?",
//        "А юнит-тесты где? 😏",
//        "Кэш-инвалидация решил?",
//        "MVP без аналитики? 😂",
//        "Где viral loop, брат?",
//        "ТикТок-контент план есть?",
//        "Аккаунт в Threads ведёшь?",
//        "Монетизация кроме донатов?",
//        "Оптимизировал под 3G? 📶"
//    ]
//    
//    // Стикеры для щита
//    private let shieldTextures = ["huesitos", "okay", "done"]
//    
//    override func didMove(to view: SKView) {
//        setupScene()
//        setupPhysics()
//        setupUI()
//        setupHead()
//    }
//    
//    private func setupScene() {
//        backgroundColor = .black
//        physicsWorld.contactDelegate = self
//        // ВОЛНЫ и настройки - gravity изменяется в updateWaves()
//        physicsWorld.gravity = CGVector(dx: 0, dy: -6)  // WAVE 1
//    }
//    
//    private func setupPhysics() {
//        // Настройка физического мира
//    }
//    
//    private func setupUI() {
//        // Таймер - UI-таймер сверху → обновление каждые 0.1 с
//        timerLabel = SKLabelNode(text: "⏱ 120s")
//        timerLabel.fontName = "Menlo-Bold"
//        timerLabel.fontSize = 24
//        timerLabel.fontColor = .white
//        timerLabel.position = CGPoint(x: 100, y: size.height - 50)
//        addChild(timerLabel)
//    }
//    
//    private func setupHead() {
//        // Голова Баходреддина - используем UIImage для безопасной загрузки
//        if let bahrImage = UIImage(named: "bahr") {
//            headNode = SKSpriteNode(texture: SKTexture(image: bahrImage))
//        } else {
//            // Fallback - создаем оранжевый круг
//            headNode = SKSpriteNode(color: .orange, size: CGSize(width: 120, height: 120))
//        }
//        
//        headNode.size = CGSize(width: 120, height: 120)
//        headNode.position = CGPoint(x: size.width / 2, y: size.height - 120)
//        addChild(headNode)
//        
//        // Анимация вращения головы
//        let rotateLeft = SKAction.rotate(toAngle: -0.26, duration: 1.0)
//        let rotateRight = SKAction.rotate(toAngle: 0.26, duration: 1.0)
//        let rotateSequence = SKAction.sequence([rotateLeft, rotateRight])
//        let rotateForever = SKAction.repeatForever(rotateSequence)
//        headNode.run(rotateForever)
//    }
//    
//    override func update(_ currentTime: TimeInterval) {
//        if gameEnded { return }
//        
//        // Инициализируем стартовое время при первом вызове
//        if startTime == 0 {
//            startTime = currentTime
//            lastBossTime = currentTime  // BOSS
//            lastShieldTextureChange = currentTime  // Assets
//        }
//        
//        let dt = currentTime - (elapsed + startTime)
//        elapsed = currentTime - startTime
//        
//        updateTimer()
//        updateWaves()
//        updateShieldEnergy(dt: dt)  // ENERGY-ЩИТ
//        updateQuestionTrajectories(currentTime: currentTime)  // КОСЫЕ ТРАЕКТОРИИ
//        spawnQuestions(currentTime)
//        spawnBoss(currentTime)  // БОСС-ВОПРОС
//        changeShieldTexture(currentTime)  // Assets
//        
//        // Проверка победы - При elapsed >= 120 → победа
//        if elapsed >= 120 {
//            gameWon()
//        }
//    }
//    
//    // ENERGY-ЩИТ («перегрев») - Логика в update(currentTime:)
//    private func updateShieldEnergy(dt: TimeInterval) {
//        if userIsTouching && !shieldOverheated {
//            shieldHoldTime += dt
//            if shieldHoldTime >= shieldMaxHold {
//                deactivateShield()  // hidden = true, physics disabled
//                shieldCooldown = shieldRest
//                shieldOverheated = true
//            }
//        } else if shieldCooldown > 0 {
//            shieldCooldown -= dt
//            if shieldCooldown <= 0 {
//                reactivateShield()  // вернуть текстуру, сброс holdTime
//                shieldOverheated = false
//            }
//        }
//    }
//    
//    // deactivateShield() → покрасить спрайт в красный + rigid-haptic
//    private func deactivateShield() {
//        shieldNode?.color = .red
//        shieldNode?.colorBlendFactor = 0.7
//        shieldNode?.physicsBody?.categoryBitMask = 0  // physics disabled
//        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
//    }
//    
//    // reactivateShield() → вернуть текстуру, сброс holdTime
//    private func reactivateShield() {
//        shieldNode?.color = .white
//        shieldNode?.colorBlendFactor = 0
//        shieldNode?.physicsBody?.categoryBitMask = Category.shield  // physics enabled
//        shieldHoldTime = 0
//    }
//    
//    // КОСЫЕ ТРАЕКТОРИИ - Вопрос-нода (QuestionNode) хранит spawnTime
//    private func updateQuestionTrajectories(currentTime: TimeInterval) {
//        children.forEach { node in
//            if let questionNode = node as? QuestionNode {
//                let life = CGFloat(currentTime - questionNode.spawnTime)
//                let omega = CGFloat.pi * 2  // 1 колебание/сек
//                let dt = CGFloat(1.0/60.0)  // примерно 60 FPS
//                
//                // Амплитуда волны: Wave1 0 → Wave2 20 pt → Wave3 40 pt + рандом dx
//                var amplitude: CGFloat = 0
//                if elapsed >= 90 {  // Wave3
//                    amplitude = 40 + questionNode.randomAmplitude
//                } else if elapsed >= 40 {  // Wave2
//                    amplitude = 20
//                }
//                // Wave1 amplitude = 0
//                
//                // position.x += sin(life * omega) * amplitude * dt
//                questionNode.position.x += sin(life * omega) * amplitude * dt
//            }
//        }
//    }
//    
//    private func updateTimer() {
//        let remainingTime = max(0, 120 - Int(elapsed))
//        timerLabel.text = "⏱ \(remainingTime)s"
//    }
//    
//    // ВОЛНЫ и настройки
//    private func updateWaves() {
//        // Время    spawnInterval    gravity.dy    amplitude    shield.size
//        // 0-40 с    1.2 с    −6    0    64×64
//        if elapsed < 40 {  // WAVE 1
//            currentSpawnInterval = 1.2
//            physicsWorld.gravity = CGVector(dx: 0, dy: -6)
//        }
//        // 40-90 с    0.9 с    −7    20    48×48
//        else if elapsed < 90 {  // WAVE 2
//            currentSpawnInterval = 0.9
//            physicsWorld.gravity = CGVector(dx: 0, dy: -7)
//        }
//        // 90-120 с    0.7 с    −8    40 + random    48×48, shieldTexture = "("
//        else {  // WAVE 3
//            currentSpawnInterval = 0.7
//            physicsWorld.gravity = CGVector(dx: 0, dy: -8)
//        }
//    }
//    
//    private func spawnQuestions(_ currentTime: TimeInterval) {
//        // Добавляем задержку в 2 секунды перед началом спавна
//        if elapsed < 2.0 { return }
//        
//        if currentTime - lastQuestionTime >= currentSpawnInterval {
//            createQuestion(currentTime)
//            lastQuestionTime = currentTime
//        }
//    }
//    
//    // БОСС-ВОПРОС - Каждые 15 с spawnBoss() (text = "Где KPI????")
//    private func spawnBoss(_ currentTime: TimeInterval) {
//        if elapsed < 2.0 { return }  // задержка как у обычных вопросов
//        
//        if currentTime - lastBossTime >= 15.0 {  // каждые 15 с
//            createBoss(currentTime)
//            lastBossTime = currentTime
//            
//            // boss речь: от Баходреддина — play "nuuu.mp3" при spawnBoss
//            playBossSound()
//        }
//    }
//    
//    private func createQuestion(_ currentTime: TimeInterval) {
//        let question = questions.randomElement() ?? "Вопрос не найден"
//        let questionNode = QuestionNode(text: question)
//        questionNode.spawnTime = currentTime  // КОСЫЕ ТРАЕКТОРИИ
//        questionNode.fontName = "Menlo-Bold"
//        questionNode.fontSize = 18
//        questionNode.fontColor = .white
//        
//        // Wave3 40 pt + рандом dx
//        if elapsed >= 90 {
//            questionNode.randomAmplitude = CGFloat.random(in: -20...20)
//        }
//        
//        // ИСПРАВЛЕНО: Спавним вопросы с самого верха экрана
//        var spawnX = size.width / 2
//        var spawnY = size.height + 50 // Спавним выше экрана
//        var velocity = CGVector(dx: 0, dy: -380)
//        
//        // Волна 3: случайные направления
//        if elapsed >= 90 {
//            let directions = [0, 1, 2] // сверху, слева, справа
//            let direction = directions.randomElement() ?? 0
//            
//            switch direction {
//            case 0: // сверху
//                spawnX = CGFloat.random(in: 50...(size.width - 50))
//                spawnY = size.height + 50
//                velocity = CGVector(dx: 0, dy: -450)
//            case 1: // слева
//                spawnX = -50
//                spawnY = size.height / 2
//                velocity = CGVector(dx: 240, dy: -200)
//            case 2: // справа
//                spawnX = size.width + 50
//                spawnY = size.height / 2
//                velocity = CGVector(dx: -240, dy: -200)
//            default:
//                break
//            }
//        }
//        // Волна 2: случайный dx
//        else if elapsed >= 40 {
//            spawnY = size.height + 50
//            velocity = CGVector(dx: CGFloat.random(in: -120...120), dy: -420)
//        }
//        
//        questionNode.position = CGPoint(x: spawnX, y: spawnY)
//        
//        // Физика
//        questionNode.physicsBody = SKPhysicsBody(rectangleOf: questionNode.frame.size)
//        questionNode.physicsBody?.categoryBitMask = Category.question
//        questionNode.physicsBody?.contactTestBitMask = Category.shield
//        questionNode.physicsBody?.collisionBitMask = 0
//        questionNode.physicsBody?.velocity = velocity
//        questionNode.physicsBody?.affectedByGravity = true  // используем gravity из updateWaves
//        
//        addChild(questionNode)
//        
//        // Удаление через 8 секунд (увеличено время)
//        let removeAction = SKAction.sequence([
//            SKAction.wait(forDuration: 8.0),
//            SKAction.removeFromParent()
//        ])
//        questionNode.run(removeAction)
//    }
//    
//    // БОСС-ВОПРОС - У него hitsRemaining = 3, fontSize = 26, category .boss
//    private func createBoss(_ currentTime: TimeInterval) {
//        let bossNode = BossQuestionNode(text: "Где KPI????")
//        bossNode.spawnTime = currentTime
//        bossNode.fontName = "Menlo-Bold"
//        bossNode.fontSize = 26  // fontSize = 26
//        bossNode.fontColor = .yellow
//        bossNode.hitsRemaining = 3  // hitsRemaining = 3
//        
//        // Wave3 40 pt + рандом dx
//        if elapsed >= 90 {
//            bossNode.randomAmplitude = CGFloat.random(in: -20...20)
//        }
//        
//        let spawnX = size.width / 2
//        let spawnY = size.height + 50
//        let velocity = CGVector(dx: 0, dy: -300)  // медленнее обычных вопросов
//        
//        bossNode.position = CGPoint(x: spawnX, y: spawnY)
//        
//        // Физика
//        bossNode.physicsBody = SKPhysicsBody(rectangleOf: bossNode.frame.size)
//        bossNode.physicsBody?.categoryBitMask = Category.boss  // category .boss
//        bossNode.physicsBody?.contactTestBitMask = Category.shield
//        bossNode.physicsBody?.collisionBitMask = 0
//        bossNode.physicsBody?.velocity = velocity
//        bossNode.physicsBody?.affectedByGravity = true
//        
//        addChild(bossNode)
//        
//        // Удаление через 10 секунд
//        let removeAction = SKAction.sequence([
//            SKAction.wait(forDuration: 10.0),
//            SKAction.removeFromParent()
//        ])
//        bossNode.run(removeAction)
//    }
//    
//    // Assets - shield textures: huesitos / okay / done ⇒ random каждые 10 с
//    private func changeShieldTexture(_ currentTime: TimeInterval) {
//        if currentTime - lastShieldTextureChange >= 10.0 {
//            lastShieldTextureChange = currentTime
//            // Если щит активен, меняем текстуру
//            if let shield = shieldNode, !shieldOverheated {
//                let textureName = shieldTextures.randomElement() ?? "okay"
//                if let shieldImage = UIImage(named: textureName) {
//                    shield.texture = SKTexture(image: shieldImage)
//                }
//            }
//        }
//    }
//    
//    // boss речь: от Баходреддина — play "nuuu.mp3" при spawnBoss
//    private func playBossSound() {
//        if let url = Bundle.main.url(forResource: "nuuu", withExtension: "mp3") {
//            do {
//                let player = try AVAudioPlayer(contentsOf: url)
//                player.volume = 0.5
//                player.play()
//            } catch {
//                print("Не удалось воспроизвести nuuu.mp3: \(error)")
//            }
//        }
//    }
//    
//    // Touch-контроль
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        
//        // touchesBegan: set userIsTouching = true, move shield to finger
//        userIsTouching = true
//        
//        if shieldNode == nil && !shieldOverheated {
//            createShield(at: location)
//        } else if !shieldOverheated {
//            shieldNode?.position = location
//        }
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        
//        // touchesMoved: follow finger (clamp к рамке)
//        if !shieldOverheated {
//            if shieldNode == nil {
//                createShield(at: location)
//            } else {
//                // clamp к рамке
//                let clampedX = max(50, min(size.width - 50, location.x))
//                let clampedY = max(50, min(size.height - 50, location.y))
//                shieldNode?.position = CGPoint(x: clampedX, y: clampedY)
//            }
//        }
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // touchesEnded: userIsTouching = false, reset holdTime
//        userIsTouching = false
//        shieldHoldTime = 0  // reset holdTime
//        
//        // Убираем щит когда палец убрали (если не перегрет)
//        if !shieldOverheated {
//            shieldNode?.removeFromParent()
//            shieldNode = nil
//        }
//    }
//    
//    private func createShield(at position: CGPoint) {
//        let textureName: String
//        
//        // 90-120 с    shieldTexture = "("
//        if elapsed >= 90 {
//            textureName = "("  // специальная текстура для Wave 3
//        } else {
//            textureName = shieldTextures.randomElement() ?? "okay"
//        }
//        
//        // Безопасная загрузка изображения щита
//        if textureName == "(" {
//            // Создаем текстовый щит для Wave 3
//            shieldNode = SKSpriteNode(color: .blue, size: CGSize(width: 48, height: 48))
//            let label = SKLabelNode(text: "(")
//            label.fontName = "Menlo-Bold"
//            label.fontSize = 40
//            label.fontColor = .white
//            label.position = CGPoint.zero
//            shieldNode.addChild(label)
//        } else if let shieldImage = UIImage(named: textureName) {
//            shieldNode = SKSpriteNode(texture: SKTexture(image: shieldImage))
//        } else {
//            // Fallback - цветной круг
//            let colors: [UIColor] = [.blue, .green, .purple]
//            shieldNode = SKSpriteNode(color: colors.randomElement() ?? .blue, size: CGSize(width: 64, height: 64))
//        }
//        
//        // shield.size - ВОЛНЫ и настройки
//        let baseSize: CGFloat
//        if elapsed < 40 {  // 0-40 с shield.size 64×64
//            baseSize = 64
//        } else {  // 40-90 с и 90-120 с shield.size 48×48
//            baseSize = 48
//        }
//        
//        shieldNode.size = CGSize(width: baseSize, height: baseSize)
//        shieldNode.position = position
//        
//        // Физика
//        shieldNode.physicsBody = SKPhysicsBody(circleOfRadius: baseSize / 2)
//        shieldNode.physicsBody?.isDynamic = false
//        shieldNode.physicsBody?.categoryBitMask = Category.shield
//        shieldNode.physicsBody?.contactTestBitMask = Category.question | Category.boss
//        shieldNode.physicsBody?.collisionBitMask = Category.question | Category.boss
//        
//        addChild(shieldNode)
//    }
//    
//    // MARK: - Physics Contact
//    func didBegin(_ contact: SKPhysicsContact) {
//        let bodyA = contact.bodyA
//        let bodyB = contact.bodyB
//        
//        var questionBody: SKPhysicsBody?
//        var bossBody: SKPhysicsBody?
//        var shieldBody: SKPhysicsBody?
//        
//        // Обычный вопрос + щит
//        if bodyA.categoryBitMask == Category.question && bodyB.categoryBitMask == Category.shield {
//            questionBody = bodyA
//            shieldBody = bodyB
//        } else if bodyA.categoryBitMask == Category.shield && bodyB.categoryBitMask == Category.question {
//            questionBody = bodyB
//            shieldBody = bodyA
//        }
//        // Босс + щит
//        else if bodyA.categoryBitMask == Category.boss && bodyB.categoryBitMask == Category.shield {
//            bossBody = bodyA
//            shieldBody = bodyB
//        } else if bodyA.categoryBitMask == Category.shield && bodyB.categoryBitMask == Category.boss {
//            bossBody = bodyB
//            shieldBody = bodyA
//        }
//        
//        // ОБРАТНАЯ СВЯЗЬ - Успешный блок обычного вопроса → UIImpactFeedbackGenerator(.light)
//        if let questionNode = questionBody?.node {
//            questionNode.removeFromParent()
//            UIImpactFeedbackGenerator(style: .light).impactOccurred()
//        }
//        
//        // БОСС-ВОПРОС - При контакте со щитом hitsRemaining -= 1
//        if let bossNode = bossBody?.node as? BossQuestionNode {
//            bossNode.hitsRemaining -= 1
//            
//            // 2 → sprite цвет оранжевый
//            if bossNode.hitsRemaining == 2 {
//                bossNode.fontColor = .orange
//            }
//            // 1 → красный, скорость ×1.3
//            else if bossNode.hitsRemaining == 1 {
//                bossNode.fontColor = .red
//                bossNode.physicsBody?.velocity.dy *= 1.3  // скорость ×1.3
//            }
//            // 0 → remove(), light-haptic
//            else if bossNode.hitsRemaining <= 0 {
//                bossNode.removeFromParent()
//                // ОБРАТНАЯ СВЯЗЬ - Блок босса (последний удар) → .medium
//                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//            }
//        }
//    }
//    
//    private func checkQuestionReachedBottom() {
//        // ИСПРАВЛЕНО: Проверяем только когда вопросы достигают самого дна
//        children.forEach { node in
//            if (node is QuestionNode || node is BossQuestionNode),
//               let labelNode = node as? SKLabelNode,
//               labelNode != timerLabel,
//               labelNode != gameOverLabel,
//               labelNode.position.y < -50 { // Проверяем только когда вопрос ушел за экран
//                // ОБРАТНАЯ СВЯЗЬ - Поражение → .heavy + shake сцены
//                gameOver()
//            }
//        }
//    }
//    
//    override func didFinishUpdate() {
//        if !gameEnded {
//            checkQuestionReachedBottom()
//        }
//    }
//    
//    private func gameOver() {
//        gameEnded = true
//        
//        // ОБРАТНАЯ СВЯЗЬ - Поражение → .heavy + shake сцены (run(SKAction.shake…​))
//        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
//        
//        // shake сцены
//        let shake = SKAction.sequence([
//            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
//            SKAction.moveBy(x: 20, y: 0, duration: 0.05),
//            SKAction.moveBy(x: -20, y: 0, duration: 0.05),
//            SKAction.moveBy(x: 10, y: 0, duration: 0.05)
//        ])
//        run(shake)
//        
//        showGameOverMessage("💀 Game Over!\nМентор тебя поджарил!")
//    }
//    
//    private func gameWon() {
//        gameEnded = true
//        
//        // При elapsed >= 120 → победа (алерт "🎉 Survived mentor roast!")
//        showGameOverMessage("🎉 Survived mentor roast!\nТы выжил!")
//    }
//    
//    private func showGameOverMessage(_ message: String) {
//        gameOverLabel = SKLabelNode(text: message)
//        gameOverLabel.fontName = "Menlo-Bold"
//        gameOverLabel.fontSize = 32
//        gameOverLabel.fontColor = .white
//        gameOverLabel.numberOfLines = 0
//        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        addChild(gameOverLabel)
//        
//        // Автоматически закрываем через 3 секунды
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            if let view = self.view {
//                view.window?.rootViewController?.dismiss(animated: true)
//            }
//        }
//    }
//}
//
//// КОСЫЕ ТРАЕКТОРИИ - Вопрос-нода (QuestionNode) хранит spawnTime
//class QuestionNode: SKLabelNode {
//    var spawnTime: TimeInterval = 0
//    var randomAmplitude: CGFloat = 0  // Wave3 40 pt + рандом dx
//}
//
//// БОСС-ВОПРОС
//class BossQuestionNode: QuestionNode {
//    var hitsRemaining: Int = 3
//}
//
//// MARK: - Costume Game View
//struct CostumeGameView: View {
//    @Binding var showCostumeGame: Bool
//    
//    @State private var topPosition: CGFloat = 0
//    @State private var bottomPosition: CGFloat = 0
//    @State private var topMovingRight = false
//    @State private var bottomMovingRight = false
//    @State private var showTop = true
//    @State private var showBottom = false
//    @State private var topStopped = false
//    @State private var bottomStopped = false
//    @State private var successCount = 0
//    @State private var missCount = 0
//    @State private var gameOver = false
//    @State private var gameWon = false
//    @State private var topTimer: Timer?
//    @State private var bottomTimer: Timer?
//    
//    private let screenWidth = UIScreen.main.bounds.width
//    private let figureWidth: CGFloat = 220
//    private let costumeWidth: CGFloat = 150
//    private let tolerance: CGFloat = 15
//    private let targetSuccesses = 5
//    private let maxMisses = 3
//    
//    // Позиции для правильного размещения костюма на фигуре
//    private let figureTopY: CGFloat = 230 // Y позиция верха фигуры (туловище)
//    private let figureBottomY: CGFloat = 360 // Y позиция низа фигуры (ноги)
//    private let figureCenterX: CGFloat = UIScreen.main.bounds.width / 2
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.8).ignoresSafeArea()
//            
//            VStack {
//                // Заголовок и статистика
//                HStack {
//                    Text("👔 Примерка костюма")
//                        .font(.title2.bold())
//                        .foregroundColor(.white)
//                    Spacer()
//                    VStack(alignment: .trailing) {
//                        Text("Успешно: \(successCount)/\(targetSuccesses)")
//                            .foregroundColor(.green)
//                        Text("Промахи: \(missCount)/\(maxMisses)")
//                            .foregroundColor(.red)
//                    }
//                    .font(.caption.bold())
//                }
//                .padding()
//                
//                Spacer()
//                
//                // Игровая область
//                ZStack {
//                    // Фигура человечка - используем ваше изображение
//                    Image(systemName: "figure.stand")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: figureWidth, height: figureWidth * 1.5)
//                        .foregroundColor(.white)
//                        .position(x: figureCenterX, y: 250)
//                    
//                    // Лицо CEO поверх головы фигуры
//                    Image("ceoFace")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 100, height: 100)
//                        .clipShape(Circle())
//                        .position(x: figureCenterX, y: 125) // Позиция головы фигуры
//                    
//                    // Верх костюма
//                    if showTop {
//                        Image("costumeTop")
//                            .resizable()
//                            .frame(width: costumeWidth, height: 112.5)
//                            .position(x: topPosition, y: figureTopY)
//                    }
//                    
//                    // Низ костюма
//                    if showBottom {
//                        Image("costumeDown")
//                            .resizable()
//                            .frame(width: costumeWidth * 0.625 , height: 150)
//                            .position(x: bottomPosition, y: figureBottomY)
//                    }
//                    
//                    // Индикаторы целевых зон (для отладки - можно убрать)
//                    Circle()
//                        .fill(Color.green.opacity(0.3))
//                        .frame(width: tolerance * 2, height: tolerance * 2)
//                        .position(x: figureCenterX, y: figureTopY)
//                    
//                    Circle()
//                        .fill(Color.blue.opacity(0.3))
//                        .frame(width: tolerance * 2, height: tolerance * 2)
//                        .position(x: figureCenterX, y: figureBottomY)
//                }
//                .frame(height: 400)
//                .onAppear {
//                    startTopMovement()
//                }
//                
//                Spacer()
//                
//                // Кнопки управления
//                VStack(spacing: 20) {
//                    if showTop && !topStopped {
//                        Button("🎯 Остановить верх костюма") {
//                            stopTop()
//                        }
//                        .font(.title2.bold())
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.orange)
//                        .cornerRadius(15)
//                        .shadow(radius: 5)
//                    }
//                    
//                    if showBottom && !bottomStopped {
//                        Button("🎯 Остановить низ костюма") {
//                            stopBottom()
//                        }
//                        .font(.title2.bold())
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.purple)
//                        .cornerRadius(15)
//                        .shadow(radius: 5)
//                    }
//                    
//                    Button("Назад") {
//                        showCostumeGame = false
//                    }
//                    .font(.title2.bold())
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.gray)
//                    .cornerRadius(15)
//                    .shadow(radius: 5)
//                }
//                .padding()
//            }
//        }
//        .alert(alertTitle(), isPresented: $gameOver) {
//            Button("Ок") {
//                showCostumeGame = false
//            }
//        }
//        .onDisappear {
//            // Останавливаем таймеры при закрытии игры
//            topTimer?.invalidate()
//            bottomTimer?.invalidate()
//        }
//    }
//    
//    private func startTopMovement() {
//        topPosition = 50
//        topMovingRight = true
//        
//        topTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
//            if topStopped {
//                timer.invalidate()
//                return
//            }
//            
//            if topMovingRight {
//                topPosition += 3
//                if topPosition >= screenWidth - 50 {
//                    topMovingRight = false
//                }
//            } else {
//                topPosition -= 3
//                if topPosition <= 50 {
//                    topMovingRight = true
//                }
//            }
//        }
//    }
//    
//    private func startBottomMovement() {
//        bottomPosition = 50
//        bottomMovingRight = true
//        showBottom = true
//        
//        bottomTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
//            if bottomStopped {
//                timer.invalidate()
//                return
//            }
//            
//            if bottomMovingRight {
//                bottomPosition += 3
//                if bottomPosition >= screenWidth - 50 {
//                    bottomMovingRight = false
//                }
//            } else {
//                bottomPosition -= 3
//                if bottomPosition <= 50 {
//                    bottomMovingRight = true
//                }
//            }
//        }
//    }
//    
//    private func stopTop() {
//        topStopped = true
//        topTimer?.invalidate()
//        
//        // Проверяем попадание верха костюма в целевую зону
//        let topHit = abs(topPosition - figureCenterX) <= tolerance
//        
//        // Добавляем тактильную обратную связь
//        if topHit {
//            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//            // Успешное попадание верха, запускаем низ
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                startBottomMovement()
//            }
//        } else {
//            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
//            // Промах
//            handleMiss()
//        }
//    }
//    
//    private func stopBottom() {
//        bottomStopped = true
//        bottomTimer?.invalidate()
//        
//        // Проверяем попадание низа костюма в целевую зону
//        let bottomHit = abs(bottomPosition - figureCenterX) <= tolerance
//        
//        if bottomHit {
//            UIImpactFeedbackGenerator(style: .light).impactOccurred()
//            // Успешное попадание обеих частей
//            successCount += 1
//            
//            if successCount >= targetSuccesses {
//                gameWon = true
//                gameOver = true
//            } else {
//                // Начинаем новый раунд
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    resetRound()
//                }
//            }
//        } else {
//            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
//            // Промах
//            handleMiss()
//        }
//    }
//    
//    private func handleMiss() {
//        missCount += 1
//        
//        if missCount >= maxMisses {
//            gameWon = false
//            gameOver = true
//        } else {
//            // Начинаем новый раунд
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                resetRound()
//            }
//        }
//    }
//    
//    private func resetRound() {
//        showTop = true
//        showBottom = false
//        topStopped = false
//        bottomStopped = false
//        
//        startTopMovement()
//    }
//    
//    private func alertTitle() -> String {
//        gameWon ? "🎉 Поздравляем! Костюм идеально подошел!" : "😢 Не получилось... Попробуйте еще раз!"
//    }
//}
//
//// MARK: - Massage View (без изменений)
//struct MassageView: View {
//    @Binding var showMassageGame: Bool
//    
//    @State private var score = 0
//    @State private var lastPoint: CGPoint?
//    @State private var timeLeft = 5
//    @State private var gameOver = false
//    @State private var player: AVAudioPlayer?
//    
//    private let targetScore = 25_000
//    private let distThresh: CGFloat = 10
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.6).ignoresSafeArea()
//            
//            VStack(spacing: 20) {
//                HStack {
//                    Text("👐 Массаж!")
//                    Spacer()
//                    Text("⏱ \(timeLeft)s")
//                }
//                .font(.title3.bold())
//                .foregroundColor(.white)
//                .padding(.horizontal)
//                
//                Image("model")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 260, height: 360)
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { value in
//                                if let last = lastPoint {
//                                    let dist = hypot(value.location.x - last.x,
//                                                     value.location.y - last.y)
//                                    if dist > distThresh {
//                                        incrementScore()
//                                        lastPoint = value.location
//                                    }
//                                } else {
//                                    lastPoint = value.location
//                                }
//                            }
//                            .onEnded { _ in lastPoint = nil }
//                    )
//                
//                Text("Очки: \(score)")
//                    .foregroundColor(.white)
//                    .font(.title2.bold())
//                
//            }
//        }
//        .onAppear {
//            startTimer()
//            playLoop()
//        }
//        .alert(alertTitle(), isPresented: $gameOver) {
//            Button("Ок") { showMassageGame = false }
//        }
//    }
//    
//    private func incrementScore() {
//        score += 100
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//    }
//    
//    private func startTimer() {
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
//            if timeLeft > 0 {
//                timeLeft -= 1
//            } else {
//                t.invalidate()
//                gameOver = true
//            }
//        }
//    }
//    
//    private func alertTitle() -> String {
//        score >= targetScore ? "Массаж удался! Бахреддину понравилось!🎉" : "Ты можешь лучше… 😢"
//    }
//    
//    private func playLoop() {
//        guard
//            let url = Bundle.main.url(forResource: "ambience", withExtension: "mp3")
//        else { return }
//        player = try? AVAudioPlayer(contentsOf: url)
//        player?.numberOfLoops = -1
//        player?.volume = 0.25
//        player?.play()
//    }
//}
