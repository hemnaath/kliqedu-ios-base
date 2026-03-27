//
//
//import UIKit
////import Instructions
//
//internal class CustomCoachMarkBodyView: UIView, CoachMarkBodyView {
//    
//    // MARK: - Internal properties
//    var nextControl: UIControl? { return self.nextButton }
//    
//    var highlighted: Bool = false
//    
//    var nextButton: UIButton = {
//        let nextButton = UIButton()
//        nextButton.accessibilityIdentifier = AccessibilityIdentifiers.next
//        return nextButton
//    }()
//    
//    // ➕ NEW
//    let titleLabel = UILabel()
//    
//    var hintLabel = UITextView()
//    
//    // ➕ NEW
//    let stepLabel = UILabel()
//    
//    // ➕ End Tour button
//    let endButton = UIButton(type: .system)
//    
//    weak var highlightArrowDelegate: CoachMarkBodyHighlightArrowDelegate?
//    
//    // MARK: - Initialization
//    override init (frame: CGRect) {
//        super.init(frame: frame)
//        setupInnerViewHierarchy()
//    }
//    
//    convenience init() {
//        self.init(frame: .zero)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("This class does not support NSCoding.")
//    }
//    
//    // MARK: - Private methods
//    private func setupInnerViewHierarchy() {
//        
//        translatesAutoresizingMaskIntoConstraints = false
//        backgroundColor = .white
//        clipsToBounds = true
//        layer.cornerRadius = 12
//        
//        // Title
//        titleLabel.font = .boldSystemFont(ofSize: 17)
//        titleLabel.textColor = .black
//        titleLabel.numberOfLines = 1
//        titleLabel.textAlignment = .left
//        
//        // Hint
//        hintLabel.backgroundColor = .clear
//        hintLabel.textColor = .darkGray
//        hintLabel.font = .systemFont(ofSize: 15)
//        hintLabel.isScrollEnabled = false
//        hintLabel.textAlignment = .left
//        hintLabel.isEditable = false
//        
//        // End Tour
//        endButton.setTitle("Skip tour", for: .normal)
//        endButton.setTitleColor(.systemGray, for: .normal)
//        endButton.titleLabel?.font = .systemFont(ofSize: 14)
//        
//        // Step label
//        stepLabel.font = .systemFont(ofSize: 13)
//        stepLabel.textColor = .systemGray
//        stepLabel.textAlignment = .center
//        
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        hintLabel.translatesAutoresizingMaskIntoConstraints = false
//        stepLabel.translatesAutoresizingMaskIntoConstraints = false
//        endButton.translatesAutoresizingMaskIntoConstraints = false
//        nextButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        nextButton.isUserInteractionEnabled = true
//        hintLabel.isUserInteractionEnabled = false
//  
//        nextButton.setTitleColor(.systemBlue, for: .normal)
//        nextButton.titleLabel?.font = .systemFont(ofSize: 15)
//        
//        addSubview(titleLabel)
//        addSubview(hintLabel)
//        addSubview(stepLabel)
//        addSubview(nextButton)
//        addSubview(endButton)
//        
//        NSLayoutConstraint.activate([
//            
//            // Title
//            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
//            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
//            
//            // Hint
//            hintLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
//            hintLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
//            hintLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
//            
//            // Footer row
//            endButton.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 12),
//            endButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
//            
//            stepLabel.centerYAnchor.constraint(equalTo: endButton.centerYAnchor),
//            stepLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            
//            nextButton.centerYAnchor.constraint(equalTo: endButton.centerYAnchor),
//            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
//            
//            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
//        ])
//    }
//}
