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

class SheetViewController: UIViewController, UIScrollViewDelegate {
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
        
        // Create the inverted scroll view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self;

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

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y == 0 {
      scrollView.contentOffset.y = 1
    }
  }

}

#Preview {
    ContentView()
}
