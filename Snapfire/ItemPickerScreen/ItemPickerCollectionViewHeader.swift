//
//  ItemPickerCollectionViewHeader.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import UIKit

final class ItemPickerCollectionViewHeader: UICollectionReusableView {
    static let reuseIdentifier = "ItemPickerCollectionViewHeader"

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        label.text = nil
    }

    func configure(with text: String) {
        label.text = text
    }
}

