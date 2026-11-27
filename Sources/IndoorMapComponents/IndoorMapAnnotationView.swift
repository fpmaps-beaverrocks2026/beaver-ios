import MapKit
import UIKit

@MainActor
final class IndoorMapAnnotationView: MKAnnotationView {
    static let reuseID = "beaver-indoor-map-icon"
    private var onActivate: (() -> Void)?
    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let countBadge = UILabel()
    private static let iconSize = CGSize(width: 22, height: 22)
    private static let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
    private static let maximumNameWidth: CGFloat = 120

    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        bounds = CGRect(origin: .zero, size: Self.iconSize)
        centerOffset = .zero
        clipsToBounds = false
        backgroundColor = .clear
        canShowCallout = false
        isEnabled = false
        displayPriority = .required
        zPriority = .defaultUnselected
        selectedZPriority = .defaultUnselected
        collisionMode = .circle
        clusteringIdentifier = nil
        isAccessibilityElement = true
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = Self.symbolConfiguration
        iconView.isUserInteractionEnabled = false
        iconView.accessibilityIdentifier = "home-marker-icon"
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.isUserInteractionEnabled = false
        nameLabel.accessibilityIdentifier = "home-marker-name"
        nameLabel.layer.shadowColor = UIColor.black.cgColor
        nameLabel.layer.shadowOpacity = 0.35
        nameLabel.layer.shadowRadius = 1
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        addSubview(iconView)
        addSubview(nameLabel)
        countBadge.textAlignment = .center
        countBadge.font = .systemFont(ofSize: 12, weight: .semibold)
        countBadge.textColor = UIColor(white: 18.0 / 255, alpha: 1)
        countBadge.backgroundColor = UIColor(red: 221.0 / 255, green: 245.0 / 255, blue: 60.0 / 255, alpha: 1)
        countBadge.clipsToBounds = true
        countBadge.isUserInteractionEnabled = false
        countBadge.accessibilityIdentifier = "home-marker-count"
        addSubview(countBadge)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        onActivate = nil
        iconView.image = nil
        nameLabel.attributedText = nil
        nameLabel.isHidden = true
        countBadge.text = nil
        countBadge.isHidden = true
    }

    func configure(_ annotation: IndoorMapPointAnnotation, onActivate: (() -> Void)?) {
        self.annotation = annotation
        self.onActivate = onActivate
        let marker = annotation.marker
        iconView.image = (UIImage(systemName: marker.kind.systemImage)
            ?? UIImage(systemName: "mappin.circle.fill"))?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = marker.kind == .favorite ? .systemPink : .white
        let font = UIFont.systemFont(ofSize: 14)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byTruncatingTail
        paragraph.minimumLineHeight = 19.6
        paragraph.maximumLineHeight = 19.6
        nameLabel.font = font
        nameLabel.attributedText = NSAttributedString(string: marker.title, attributes: [
            .font: font,
            .kern: -0.28,
            .paragraphStyle: paragraph,
            .foregroundColor: UIColor(white: 217.0 / 255, alpha: 1)
        ])
        nameLabel.isHidden = marker.kind == .favorite || marker.title.isEmpty
        countBadge.text = String(marker.favoriteIDs.count)
        countBadge.isHidden = marker.kind != .favorite || marker.favoriteIDs.count < 2
        isEnabled = onActivate != nil
        accessibilityTraits = isEnabled ? .button : []
        accessibilityHint = isEnabled ? "찜한 항목 보기" : nil
        accessibilityLabel = annotation.title
        accessibilityValue = annotation.subtitle
        accessibilityIdentifier = "home-marker-\(marker.kind.rawValue)"
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.frame = bounds
        if countBadge.isHidden {
            countBadge.frame = .zero
        } else {
            let height: CGFloat = 18
            let width = max(height, ceil(countBadge.intrinsicContentSize.width) + 8)
            countBadge.frame = CGRect(x: bounds.maxX - width / 2, y: bounds.minY - height / 2,
                                      width: width, height: height)
            countBadge.layer.cornerRadius = height / 2
        }
        guard !nameLabel.isHidden else {
            nameLabel.frame = .zero
            return
        }
        let size = nameLabel.sizeThatFits(CGSize(width: Self.maximumNameWidth, height: .greatestFiniteMagnitude))
        let width = min(Self.maximumNameWidth, ceil(size.width))
        nameLabel.frame = CGRect(x: bounds.midX - width / 2, y: bounds.maxY + 4,
                                 width: width, height: ceil(size.height))
    }

    override func accessibilityActivate() -> Bool {
        guard let onActivate else { return super.accessibilityActivate() }
        onActivate()
        return true
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event) || (!countBadge.isHidden && countBadge.frame.contains(point))
    }
}
