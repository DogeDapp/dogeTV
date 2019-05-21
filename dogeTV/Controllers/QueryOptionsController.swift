//
//  QueryOptionsController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/18.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import UIKit
import SnapKit
import Carbon
import KafkaRefresh
import SPStorkController

class QueryOptionsController: BaseViewController {
    var query: [OptionSet]?
    var onSelectOptions: (() -> Void)?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.theme_backgroundColor = AppColor.secondaryBackgroundColor
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    lazy var renderer = Renderer(
        adapter: QueryOptionsAdapter(),
        updater: UICollectionViewUpdater()
    )

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        render()
    }
    
    func setupViews() {
        view.theme_backgroundColor = AppColor.secondaryBackgroundColor
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
        }
        renderer.target = collectionView
        renderer.adapter.didSelect = { [weak self] ctx in
            guard let self = self,
                let item = ctx.node.component.as(QueryItemComponent.self), !item.data.isSelected else {
                    return
            }
            self.query?[ctx.indexPath.section].setSelected(item: item.data)
            self.onSelectOptions?()
            self.render()
        }
    }
    
    func render() {
        guard let query = query else { return }
        let sections = query.map { (set) -> Section in
            let cells = set.options.prefix(20).map { CellNode(QueryItemComponent(data: $0)) }
            let header = ViewNode(QuerySetHeaderComponent(data: set.title))
            return Section(id: set.title, header: header, cells: cells)
        }
        renderer.render(sections)
    }
}

class QueryOptionsAdapter: UICollectionViewFlowLayoutAdapter {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        SPStorkController.scrollViewDidScroll(scrollView)
    }
}
