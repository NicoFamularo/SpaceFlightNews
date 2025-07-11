//
//  GifImageView.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import UIKit
import ImageIO

/// Protocol for handling GIF animation events.
/// Implementing classes receive notifications about GIF playback lifecycle events,
/// particularly useful for non-looping GIFs that need to trigger actions when finished.
protocol GifImageViewProtocol: AnyObject {
    /// Called when a GIF animation reaches its end (for non-looping GIFs).
    /// This method is particularly useful for triggering navigation after splash animations,
    /// starting subsequent animations, or updating UI state based on animation completion.
    func gifEnded()
}

class GifImageView: UIImageView {
    
    // MARK: - Properties
    private var gifSource: CGImageSource?
    private var displayLink: CADisplayLink?
    private var currentFrameIndex = 0
    private var frameDurations: [TimeInterval] = []
    private var frames: [UIImage] = []
    private var speedMultiplier: Double = 1.0
    private var isLooping: Bool = true
    
    private weak var delegate: GifImageViewProtocol?
    
    // MARK: - Initializers
    
    /// Creates a GifImageView with the specified frame.
    /// This initializer sets up a GIF image view programmatically with
    /// the given frame rectangle and calls the internal setup method.
    /// - Parameter frame: The frame rectangle for the view, measured in points.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    /// Creates a GifImageView from a storyboard or XIB file.
    /// This initializer is called when the view is loaded from Interface Builder
    /// and automatically calls the internal setup method.
    /// - Parameter coder: The NSCoder object containing the view data from Interface Builder.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        contentMode = .scaleAspectFit
        clipsToBounds = true
    }
    
    // MARK: - Public Methods
    
    /// Carga y reproduce un GIF desde un archivo local
    /// - Parameter gifName: Nombre del archivo GIF (con o sin extensión)
    func loadGif(named gifName: String) {
        loadGif(named: gifName, speedMultiplier: 1.0, looping: true)
    }
    
    /// Carga y reproduce un GIF desde un archivo local con multiplicador de velocidad
    /// - Parameters:
    ///   - gifName: Nombre del archivo GIF (con o sin extensión)
    ///   - speedMultiplier: Multiplicador de velocidad (1.0 = velocidad normal, 2.0 = doble velocidad, 0.5 = mitad de velocidad)
    func loadGif(named gifName: String, speedMultiplier: Double) {
        loadGif(named: gifName, speedMultiplier: speedMultiplier, looping: true)
    }
    
    /// Carga y reproduce un GIF desde un archivo local con control completo
    /// - Parameters:
    ///   - gifName: Nombre del archivo GIF (con o sin extensión)
    ///   - speedMultiplier: Multiplicador de velocidad (1.0 = velocidad normal, 2.0 = doble velocidad, 0.5 = mitad de velocidad)
    ///   - looping: Si el GIF debe repetirse infinitamente (true) o reproducirse solo una vez (false)
    func loadGif(named gifName: String, speedMultiplier: Double, looping: Bool) {
        let name = gifName.hasSuffix(".gif") ? String(gifName.dropLast(4)) : gifName
        
        guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
              let data = NSData(contentsOfFile: path) else {
            print("⚠️ No se pudo encontrar el archivo: \(gifName)")
            return
        }
        
        self.speedMultiplier = max(0.1, speedMultiplier) // Limitar velocidad mínima
        self.isLooping = looping
        loadGif(from: data as Data)
    }
    
    func configureDelegate(_ delegate: GifImageViewProtocol) {
        self.delegate = delegate
    }
    
    /// Configura si el GIF debe hacer loop o no
    /// - Parameter looping: true para loop infinito, false para reproducción única
    func setLooping(_ looping: Bool) {
        self.isLooping = looping
    }
    
    /// Carga y reproduce un GIF desde datos
    /// - Parameter data: Datos del archivo GIF
    func loadGif(from data: Data) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("⚠️ No se pudo crear CGImageSource desde los datos")
            return
        }
        
        self.gifSource = source
        extractFrames()
        startAnimation()
    }
    
    /// Inicia la animación del GIF
    func startAnimation() {
        guard !frames.isEmpty else { return }
        
        stopAnimation()
        currentFrameIndex = 0
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// Detiene la animación del GIF
    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// Cambia la velocidad de reproducción del GIF actual
    /// - Parameter speedMultiplier: Multiplicador de velocidad (1.0 = velocidad normal, 2.0 = doble velocidad, 0.5 = mitad de velocidad)
    func setSpeedMultiplier(_ speedMultiplier: Double) {
        self.speedMultiplier = max(0.1, speedMultiplier)
        
        // Si está reproduciendo, reiniciar con la nueva velocidad
        if displayLink != nil {
            startAnimation()
        }
    }
    
    // MARK: - Private Methods
    private func extractFrames() {
        guard let source = gifSource else { return }
        
        let frameCount = CGImageSourceGetCount(source)
        frames.removeAll()
        frameDurations.removeAll()
        
        for i in 0..<frameCount {
            // Extraer imagen
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let uiImage = UIImage(cgImage: cgImage)
                frames.append(uiImage)
                
                // Extraer duración del frame y aplicar multiplicador de velocidad
                let duration = getFrameDuration(from: source, at: i)
                let adjustedDuration = duration / speedMultiplier
                frameDurations.append(adjustedDuration)
            }
        }
    }
    
    private func getFrameDuration(from source: CGImageSource, at index: Int) -> TimeInterval {
        let defaultDuration: TimeInterval = 0.1
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
              let gifDict = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] else {
            return defaultDuration
        }
        
        let delayTime = gifDict[kCGImagePropertyGIFDelayTime as String] as? NSNumber
        let unclampedDelayTime = gifDict[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber
        
        let duration = unclampedDelayTime?.doubleValue ?? delayTime?.doubleValue ?? defaultDuration
        
        // Asegurar una duración mínima para evitar animaciones demasiado rápidas
        return max(duration, 0.02)
    }
    
    @objc private func updateFrame() {
        guard !frames.isEmpty else { return }
        
        // Mostrar el frame actual
        image = frames[currentFrameIndex]
        
        // Calcular el tiempo para el siguiente frame
        let currentDuration = frameDurations[currentFrameIndex]
        
        // Verificar si estamos en el último frame
        let isLastFrame = currentFrameIndex == frames.count - 1
        
        if isLastFrame && !isLooping {
            // Si es el último frame y no hay loop, detener animación y notificar al delegate
            stopAnimation()
            delegate?.gifEnded()
            return
        }
        
        // Avanzar al siguiente frame (con loop si está habilitado)
        currentFrameIndex = (currentFrameIndex + 1) % frames.count
        
        // Programar el siguiente update basado en la duración del frame actual
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        
        // Calcular frames por segundo basado en la duración ajustada
        let framesPerSecond = max(1, min(60, Int(1.0 / currentDuration)))
        displayLink?.preferredFramesPerSecond = framesPerSecond
        displayLink?.add(to: .main, forMode: .common)
    }
    
    // MARK: - Lifecycle
    deinit {
        stopAnimation()
    }
} 
