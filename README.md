## StarMazeRollGame_Swift_SpriteKit_CMMotionManager
| Oyun Başlıyor | Oyunda Yanma Olayı | Level 2 Geciş && Oyun bitti |
|---------|---------|---------|
| ![Video 1](https://github.com/user-attachments/assets/389f7f25-1d36-4e90-b262-c03af23e6e96) | ![Video 2](https://github.com/user-attachments/assets/62255bd6-aaa8-4f2f-950e-92d70ad6631d) |![Video 3](https://github.com/user-attachments/assets/568dee55-2ad0-40a6-bcca-9a4e3823ec7e) |

 <details>
    <summary><h2>Oyunun Amacı</h2></summary>
    Proje Amacı
   Bu oyunun amacı, oyuncunun bir karakteri (player) kontrol ederek seviyelerdeki engelleri aşarak yıldızları toplaması ve seviyenin sonuna, bitiş noktasına (finish) ulaşmasıdır.
   Oyuncu, hareketlerini cihazın ivmeölçerini kullanarak yapar ve oyunda çeşitli engeller (örneğin, duvarlar ve vortex'ler) ve ödüller (yıldızlar) bulunur.
  Oyuncu her seviyede başarılı olursa, bir sonraki seviyeye geçebilir. Oyun, oyuncunun seviyeleri geçerken puan toplamasını sağlar ve her seviyede daha zorlayıcı engellerle karşılaşır. Eğer oyuncu bir vortex'e çarparsa, oyun sona erer ve oyuncu bir puan kaybeder.
  Kısacası, oyun, oyuncuyu her seviyede daha zorlayıcı engellerle karşılaştırarak eğlenceli ve dinamik bir deneyim sunmayı amaçlar
  </details>  

  <details>
    <summary><h2>CollisionTypes Enum</h2></summary>
    Bu enum, oyundaki çarpışma kategorilerini tanımlar. Her bir kategoriye benzersiz bir UInt32 değeri atanır. Bu değerler, fiziksel çarpışmaların doğru şekilde yönetilmesi için kullanılır. Örneğin, bir oyuncu "vortex" ile çarpıştığında, bu çarpışma vortext kategorisiyle tetiklenir.
    
    ```
    enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortext = 8
    case finish = 16
    }

    ```
  </details> 

  <details>
    <summary><h2>startGame Fonksiyonu</h2></summary>
    Bu fonksiyon, oyunun başlangıcında gerekli öğeleri ekler. Arka plan, skor etiketi, seviyeler ve oyuncu karakteri yaratılır. Ayrıca, ivme ölçer verilerini başlatan motionManager başlatılır. physicsWorld.gravity = .zero ifadesi, başlangıçta yerçekimsiz bir ortam oluşturur

    
    ```
     func startGame(){
    let background = SKSpriteNode(imageNamed: "background")
    background.position = CGPoint(x: 512, y: 384)
    background.blendMode = .replace
    background.zPosition = -1
    addChild(background)
    
    scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    scoreLabel.text = "Score: 0"
    scoreLabel.horizontalAlignmentMode = .left
    scoreLabel.position = CGPoint(x: 16, y: 16)
    scoreLabel.zPosition = 2
    addChild(scoreLabel)

    loadLevel()
    creatPlayer()
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    motionManager = CMMotionManager()
    motionManager.startAccelerometerUpdates()
    }



    ```
  </details> 

  <details>
    <summary><h2>loadLevel Fonksiyonu</h2></summary>
    Bu fonksiyon, seviyelerin bir dosyadan yüklenmesini sağlar. Bu seviyeler .txt formatında tutulur ve haritada her bir karakterin temsil ettiği nesneler yüklenir (x duvar, v vortex, s yıldız, vb.). Her nesne, fiziksel özelliklere sahip SKSpriteNode nesnelerine dönüştürülür ve sahneye eklenir.
    
    ```
         func loadLevel(){
    guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
        fatalError("Could not find level1.txt in the app bundle")
    }
    ...
    }



    
    ```
  </details> 


  <details>
    <summary><h2>creatPlayer Fonksiyonu</h2></summary>
    Bu fonksiyon, oyuncu karakterini sahneye ekler. Oyuncu bir SKSpriteNode olarak tanımlanır ve fiziksel özellikler atanır. Ayrıca, oyuncunun hangi nesnelerle çarpışacağını belirleyen categoryBitMask, contactTestBitMask ve collisionBitMask ayarlanır
    
    ```
       func creatPlayer(){
    player = SKSpriteNode(imageNamed: "player")
    player.position = CGPoint(x: 96, y: 672)
    player.zPosition = 1
    player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
    player.physicsBody?.allowsRotation = false
    player.physicsBody?.linearDamping = 0.5
    player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
    player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortext.rawValue | CollisionTypes.finish.rawValue
    player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
    addChild(player)
    }



    ```
  </details> 

  <details>
    <summary><h2>touchesBegan Fonksiyonu</h2></summary>
    Bu fonksiyon, ekrana dokunulduğunda çağrılır. Dokunulan konum alınır ve lastTouchPosition güncellenir. Bu, hareket etme mekanizması için kullanılır
    
    ```
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    lastTouchPosition = location
    ...
    }



    ```
  </details> 

  <details>
    <summary><h2>playerCollied Fonksiyonu</h2></summary>
    Oyuncunun bir nesneyle çarpışması durumunda, bu fonksiyon devreye girer. Eğer oyuncu bir vortex ile çarpıştıysa, oyunun sonlandığına dair bir işlem yapılır. Eğer oyuncu bir yıldızla çarpıştıysa, skor artar ve yıldız sahneden silinir. Finish noktasıyla çarpıştığında ise bir sonraki seviyeye geçiş yapılır.
    
    ```
      func playerCollied(with node: SKNode) {
    if node.name == "vortex" {
        ...
    } else if node.name == "star" {
        ...
    } else if node.name == "finish" {
        ...
    }
     }




    ```
  </details> 

  <details>
    <summary><h2>didBegin Fonksiyonu</h2></summary>
    Bu fonksiyon, iki fiziksel cisim çarpıştığında çağrılır. Eğer bu cisimlerden biri oyuncu karakteriyse, playerCollied(with:) fonksiyonu çağrılır ve çarpışma işleme alınır.
    
    ```
       func didBegin(_ contact: SKPhysicsContact) {
    guard let nodeA = contact.bodyA.node else { return }
    guard let nodeB = contact.bodyB.node else { return }
    
    if nodeA == player  {
        playerCollied(with: nodeB)
    } else if nodeB == player {
        playerCollied(with: nodeA)
    }
    }





    ```
  </details> 

  <details>
    <summary><h2>update Fonksiyonu</h2></summary>
    Her frame'de çağrılan bu fonksiyon, oyunun her karesinde gerçekleşen fiziksel hesaplamaları günceller. Eğer oyun bitmemişse, cihazın ivme ölçer verileri kullanılarak oyuncu karakterinin hareketi sağlanır
    
    ```
        override func update(_ currentTime: TimeInterval) {
    guard isGameOver == false else { return }
    ...
    }





    ```
  </details> 

  


<details>
    <summary><h2>Uygulama Görselleri </h2></summary>
    
    
 <table style="width: 100%;">
    <tr>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Oyun Level 1</h4>
            <img src="https://github.com/user-attachments/assets/e4a05871-142c-453e-9d22-44ab2be3398c" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Oyun Level 2</h4>
            <img src="https://github.com/user-attachments/assets/57964865-e5f1-48ed-997a-7699aa7e25e8" style="width: 100%; height: auto;">
        </td>
      <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Level 2 Gecis</h4>
            <img src="https://github.com/user-attachments/assets/9111e59f-8b29-4959-a61a-395a82353c1a" style="width: 100%; height: auto;">
        </td>
    </tr>
</table>
  </details> 
