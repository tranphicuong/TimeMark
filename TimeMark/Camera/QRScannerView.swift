import SwiftUI
import AVFoundation

// MARK: - QRScannerView

struct QRScannerView: View {
    
    let onScanned: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var torchOn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview
                QRCameraPreview(onScanned: { code in
                    dismiss()
                    onScanned(code)
                }, torchOn: $torchOn)
                .ignoresSafeArea()
                
                // Overlay hướng dẫn
                VStack {
                    Spacer()
                    
                    // Khung ngắm QR
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 240, height: 240)
                        .overlay(
                            // 4 góc highlight
                            QRCornerFrame()
                        )
                    
                    Text("Đặt mã QR của admin vào khung")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    // Torch button
                    Button {
                        torchOn.toggle()
                    } label: {
                        Image(systemName: torchOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Quét mã QR chấm công")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ") { dismiss() }
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }
}

// MARK: - Camera preview wrapper
struct QRCameraPreview: UIViewRepresentable {
    
    let onScanned: (String) -> Void
    @Binding var torchOn: Bool
    
    func makeUIView(context: Context) -> QRPreviewUIView {
        let view = QRPreviewUIView()
        view.onScanned = onScanned
        return view
    }
    
    func updateUIView(_ uiView: QRPreviewUIView, context: Context) {
        uiView.setTorch(on: torchOn)
    }
}

// MARK: - UIView với AVCaptureSession
final class QRPreviewUIView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    var onScanned: ((String) -> Void)?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSession()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupSession() {
        let session = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        
        session.addInput(input)
        
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        layer.addSublayer(preview)
        previewLayer = preview
        
        captureSession = session
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput objects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !hasScanned,
              let obj = objects.first as? AVMetadataMachineReadableCodeObject,
              let code = obj.stringValue else { return }
        hasScanned = true
        // Rung nhẹ feedback
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        captureSession?.stopRunning()
        onScanned?(code)
    }
}

// MARK: - 4 góc khung ngắm
struct QRCornerFrame: View {
    let lineLength: CGFloat = 28
    let lineWidth: CGFloat = 4
    let color: Color = .green
    
    var body: some View {
        ZStack {
            // Top-left
            corner(rotation: 0)
                .offset(x: -88, y: -88)
            // Top-right
            corner(rotation: 90)
                .offset(x: 88, y: -88)
            // Bottom-right
            corner(rotation: 180)
                .offset(x: 88, y: 88)
            // Bottom-left
            corner(rotation: 270)
                .offset(x: -88, y: 88)
        }
    }
    
    private func corner(rotation: Double) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: lineLength))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: lineLength, y: 0))
        }
        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        .frame(width: lineLength, height: lineLength)
        .rotationEffect(.degrees(rotation))
    }
}
