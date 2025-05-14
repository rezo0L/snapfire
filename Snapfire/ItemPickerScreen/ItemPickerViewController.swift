//
//  ItemPickerViewController.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import UIKit

final class ItemPickerViewController: UIViewController {
    var onItemSelected: ((UIImage) -> Void)?

    private let overlays: [Category]
    private let maximumItemsPerSection: Int

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 32, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ItemPickerCollectionViewCell.self,
                                forCellWithReuseIdentifier: ItemPickerCollectionViewCell.identifier)
        collectionView.register(ItemPickerCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ItemPickerCollectionViewHeader.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    init(overlays: [Category]) {
        self.overlays = overlays
        self.maximumItemsPerSection = overlays.count > 1 ? 12 : .max

        super.init(nibName: nil, bundle: nil)

        title = "Overlays"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension ItemPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        overlays.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ItemPickerCollectionViewHeader.reuseIdentifier,
                for: indexPath
              ) as? ItemPickerCollectionViewHeader else {
            return UICollectionReusableView()
        }

        header.configure(with: overlays[indexPath.section].title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        .init(width: collectionView.bounds.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(overlays[section].items.count, maximumItemsPerSection)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemPickerCollectionViewCell.identifier,
                                                            for: indexPath) as? ItemPickerCollectionViewCell else {
            preconditionFailure()
        }

        let content: ItemPickerCollectionViewCell.Content
        if indexPath.item == maximumItemsPerSection - 1 && overlays[indexPath.section].items.count > maximumItemsPerSection {
            content = .label("+\(overlays[indexPath.section].items.count - maximumItemsPerSection + 1)")
        } else {
            content = .image(overlays[indexPath.section].items[indexPath.item].sourceURL)
        }
        cell.configure(with: content)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ItemPickerCollectionViewCell,
              let content = cell.content else {
            return
        }

        switch content {
        case .image:
            guard let image = cell.image else { return }
            dismiss(animated: true) {
                self.onItemSelected?(image)
            }

        case .label:
            let category = overlays[indexPath.section]
            showCategoryOverlays(category: category)
        }
    }

    private func showCategoryOverlays(category: Category) {
        let viewController = ItemPickerViewController(overlays: [category])
        viewController.onItemSelected = { [weak self] image in
            self?.onItemSelected?(image)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}
