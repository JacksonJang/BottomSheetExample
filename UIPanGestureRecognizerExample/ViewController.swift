import UIKit

class ViewController: UIViewController {
    var state: Int = 1
    
    let dimView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        return view
    }()
    
    let pullBar: PullBar = {
        let view = PullBar()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let bottomSheetView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        return view
    }()
    
    var bottomHeightConstraint: NSLayoutConstraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.bottomHeightConstraint =  bottomSheetView.heightAnchor.constraint(equalToConstant: 400)
        
        setupUI()
        setupGesture()
    }

    private func setupUI() {
        self.view.addSubview(dimView)
        self.view.addSubview(bottomSheetView)
        self.view.addSubview(pullBar)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: self.view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            pullBar.bottomAnchor.constraint(equalTo: self.bottomSheetView.topAnchor),
            pullBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            pullBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            pullBar.heightAnchor.constraint(equalToConstant: 20),
            
            bottomSheetView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bottomSheetView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        bottomHeightConstraint?.isActive = true
    }
    
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let bottomHeightConstraint = self.bottomHeightConstraint else { return }
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        sender.setTranslation(.zero, in: view)
        let newHeight = min(max(0, bottomHeightConstraint.constant - translation.y), 700)

        switch sender.state {
        case .began, .changed:
            bottomHeightConstraint.constant = newHeight
        case .ended, .cancelled:
            adjustSheetPosition(withVelocity: velocity.y, currentHeight: newHeight)
        default:
            break
        }
        view.layoutIfNeeded()
    }

    private func adjustSheetPosition(withVelocity velocity: CGFloat, currentHeight: CGFloat) {
        if velocity > 500 {
            state = max(0, state - 1)
        } else if velocity < -500 {
            state = min(2, state + 1)
        }
        
        switch state {
        case 0:
            hideBottomSheet()
        case 1:
            animateBottomSheet(to: 400)
        case 2:
            animateBottomSheet(to: 700)
        default:
            break
        }
    }

    private func animateBottomSheet(to height: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        })
    }

    private func hideBottomSheet() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomHeightConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }) { _ in
            self.bottomSheetView.removeFromSuperview()
            self.dimView.removeFromSuperview()
        }
    }

}

final class PullBar: UIView {
    enum Style {
        static let size = CGSize(width: 40, height: 4)
    }

    private let centerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.layer.cornerRadius = Style.size.height * 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = .clear

        setupUI()
    }

    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.addSubview(centerView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            centerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            centerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            centerView.widthAnchor.constraint(equalToConstant: Style.size.width),
            centerView.heightAnchor.constraint(equalToConstant: Style.size.height)
        ])
    }
}
