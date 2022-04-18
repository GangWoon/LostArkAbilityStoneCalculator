import SwiftUI

struct Attribute {
    let range: NSRange
    let font: UIFont
    let color: UIColor
}

struct AttributedText: UIViewRepresentable {
    let text: String
    let baseAttribute: Attribute
    let pointAttribute: Attribute
    let lineHeightMultple: CGFloat
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.attributedText = buildAttributeString(
            text: text,
            attributes: [
                pointAttribute,
                baseAttribute
            ],
            lineHeightMultiple: lineHeightMultple
        )
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = buildAttributeString(
            text: text,
            attributes: [
                baseAttribute,
                pointAttribute
            ],
            lineHeightMultiple: lineHeightMultple
        )
    }
    
    private func buildAttributeString(
        text: String,
        attributes: [Attribute],
        lineHeightMultiple: CGFloat
    ) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        attributes
            .forEach { attribute in
                let dictionary: [NSAttributedString.Key: Any] = [
                    .font: attribute.font,
                    .foregroundColor: attribute.color
                ]
                attributedText
                    .addAttributes(dictionary, range: attribute.range)
            }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        attributedText
            .addAttribute(
                .paragraphStyle,
                value: paragraphStyle,
                range: text.fullRange
            )
        
        return attributedText
    }
}
