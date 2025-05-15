//
//  ItemPickerCollectionViewCell.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import SDWebImage
import UIKit

final class ItemPickerCollectionViewCell: UICollectionViewCell {
    static let identifier = "ItemPickerCollectionViewCell"

    var image: UIImage? {
        imageView.image
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(label)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.backgroundColor = .secondarySystemBackground
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        label.text = nil
        imageView.image = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setContent(_ content: ItemPickerViewModel.Section.Content) {
        switch content {
        case let .image(url):
            label.isHidden = true
            imageView.isHidden = false
            imageView.sd_setImage(with: url)

        case let .label(text):
            label.isHidden = false
            imageView.isHidden = true
            label.text = text
        }
    }
}

