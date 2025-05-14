//
//  ItemPickerViewController.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import UIKit

final class ItemPickerViewController: UIViewController {
    var onItemSelected: ((UIImage) -> Void)?

    private let images: [UIImage] = [
        UIImage(systemName: "star.fill")!,
        UIImage(systemName: "circle.fill")!,
        UIImage(systemName: "heart.fill")!,
        UIImage(systemName: "bolt.fill")!,
        UIImage(systemName: "cloud.fill")!,
    ]

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ItemPickerCollectionViewCell.self,
                                forCellWithReuseIdentifier: ItemPickerCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}

extension ItemPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemPickerCollectionViewCell.identifier,
                                                            for: indexPath) as? ItemPickerCollectionViewCell else {
            preconditionFailure()
        }

        let image = images[indexPath.item]
        cell.configure(with: image)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = images[indexPath.item]
        dismiss(animated: true) {
            self.onItemSelected?(item)
        }
    }
}
