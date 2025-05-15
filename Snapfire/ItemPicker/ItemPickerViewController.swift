//
//  ItemPickerViewController.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import Combine
import UIKit

final class ItemPickerViewController: UIViewController {
    var onItemSelected: ((UIImage) -> Void)?

    private let viewModel: ItemPickerViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 72, height: 72)
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

    init(viewModel: ItemPickerViewModel) {
        self.viewModel = viewModel

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

        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension ItemPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count
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

        header.configure(with: viewModel.sections[indexPath.section].title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        .init(width: collectionView.bounds.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.sections[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemPickerCollectionViewCell.identifier,
                                                            for: indexPath) as? ItemPickerCollectionViewCell else {
            preconditionFailure()
        }

        let content = viewModel.sections[indexPath.section].items[indexPath.item]
        cell.setContent(content)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ItemPickerCollectionViewCell,
              let action = viewModel.navigationAction(for: indexPath, selectedImage: cell.image) else {
            return
        }

        switch action {
        case .showImage(let image):
            dismiss(animated: true) { self.onItemSelected?(image) }

        case .showCategory(let nextViewModel):
            let viewController = ItemPickerViewController(viewModel: nextViewModel)
            viewController.onItemSelected = self.onItemSelected
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
