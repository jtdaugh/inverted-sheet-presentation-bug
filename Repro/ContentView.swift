//
//  ContentView.swift
//  Repro
//
//  Created by Jesse Daugherty on 5/23/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Button("Present Sheet") {
                showSheet = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .sheet(isPresented: $showSheet) {
            SheetContentView()
        }
    }
}

struct SheetContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SheetViewController {
        return SheetViewController()
    }
    
    func updateUIViewController(_ uiViewController: SheetViewController, context: Context) {
        // No updates needed
    }
}

// Custom ScrollView that handles inverted gestures properly
class InvertedScrollView: UIScrollView, UIGestureRecognizerDelegate {
    private var customPanGesture: UIPanGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGestureHandling()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureHandling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestureHandling()
    }
    
    private func setupGestureHandling() {
        // Create a custom pan gesture that will compete with the sheet's gesture
        customPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCustomPan(_:)))
        customPanGesture?.delegate = self
        
        if let customPan = customPanGesture {
            addGestureRecognizer(customPan)
            
            // Make the scroll view's pan gesture require our custom gesture to fail
            // This gives our custom gesture priority to evaluate first
            panGestureRecognizer.require(toFail: customPan)
        }
    }
    
    @objc private func handleCustomPan(_ gesture: UIPanGestureRecognizer) {
        // This gesture is designed to fail most of the time, but it evaluates first
        // and can prevent the sheet gesture from triggering when needed
        
        let velocity = gesture.velocity(in: self)
        let isAtTop = contentOffset.y <= 0
        
        // If we're at the top and user is panning up, we want to "consume" this gesture
        // to prevent it from reaching the sheet
        if isAtTop && velocity.y < 0 {
            // We'll handle this gesture by doing nothing, effectively consuming it
            return
        }
        
        // For all other cases, we want this gesture to fail so the normal scroll behavior works
        gesture.state = .failed
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow simultaneous recognition with other gestures
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Our custom pan gesture should be required to fail by the scroll view's pan gesture
        if gestureRecognizer == customPanGesture && otherGestureRecognizer == panGestureRecognizer {
            return true
        }
        return false
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == customPanGesture {
            guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
                return true
            }
            let velocity = panGesture.velocity(in: self)
            let isAtTop = contentOffset.y <= 0
            
            // Only begin our custom gesture if we're at the top and panning up
            // This is when we want to prevent the sheet gesture
            return isAtTop && velocity.y < 0
        }
        
        return true
    }
}

class SheetViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSheetPresentation()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Create the inverted scroll view with custom gesture handling
        let scrollView = InvertedScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        // Apply the scale transform to invert the scroll view
        scrollView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        // Create a stack view to hold the items
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add 50 static items
        for i in 1...50 {
            let itemView = UIView()
            itemView.backgroundColor = .systemBlue
            itemView.layer.cornerRadius = 8
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = "Item \(i)"
            label.textColor = .white
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            // Since the scroll view is inverted, we need to invert the label too
            label.transform = CGAffineTransform(scaleX: 1, y: -1)
            
            itemView.addSubview(label)
            stackView.addArrangedSubview(itemView)
            
            NSLayoutConstraint.activate([
                itemView.heightAnchor.constraint(equalToConstant: 60),
                label.centerXAnchor.constraint(equalTo: itemView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: itemView.centerYAnchor)
            ])
        }
        
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func configureSheetPresentation() {
        guard let presentationController = presentationController as? UISheetPresentationController else {
            return
        }
        
        // Calculate 90% of screen height
        let screenHeight = UIScreen.main.bounds.height
        let customDetent = UISheetPresentationController.Detent.custom { _ in
            return screenHeight * 0.9
        }
        
        presentationController.detents = [customDetent]
        presentationController.prefersGrabberVisible = true
        presentationController.preferredCornerRadius = 16
    }
}

#Preview {
    ContentView()
}
