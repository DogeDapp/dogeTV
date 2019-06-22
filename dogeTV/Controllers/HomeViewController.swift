//
//  HomeViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/14.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import UIKit
import SnapKit
import Carbon
import PromiseKit
import Kingfisher
import KafkaRefresh

class HomeViewController: BaseViewController {
    
    var hots: [Hot] = []
    var topics: [Topic] = []

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumInteritemSpacing = 0
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.theme_backgroundColor = AppColor.backgroundColor
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    lazy var renderer = Renderer(
        adapter: UICollectionViewFlowLayoutAdapter(),
        updater: UICollectionViewUpdater()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "五行缺脑"
        let searchBarBtn = UIBarButtonItem(image: UIImage(named: "search_nav"), style: .plain, target: self, action: #selector(search(_:)))
        let moreBarBtn = UIBarButtonItem(image: UIImage(named: "more"), style: .plain, target: self, action: #selector(more(_:)))
        let tvBarBtn = UIBarButtonItem(image: UIImage(named: "tv"), style: .plain, target: self, action: #selector(tv(_:)))
        navigationItem.rightBarButtonItems = [searchBarBtn, tvBarBtn]
        navigationItem.leftBarButtonItem = moreBarBtn
        setupView()
        collectionView.headRefreshControl.beginRefreshing()
    }

    @objc func search(_ sender: UIBarButtonItem) {
        let target = SearchViewController()
        navigationController?.pushViewController(target, animated: true)
    }
    @objc func more(_ sender: UIBarButtonItem) {
        let target = CategoryViewController()
        target.sourceType = .normal
        navigationController?.pushViewController(target, animated: true)
    }
    @objc func tv(_ sender: UIBarButtonItem) {
        let target = LivesViewController()
        navigationController?.pushViewController(target, animated: true)
    }
    
    func setupView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        collectionView.bindHeadRefreshHandler({ [weak self] in
            self?.refresh()
            }, themeColor: .darkGray, refreshStyle: .replicatorWoody)
        
        renderer.target = collectionView
        renderer.adapter.didSelect = { [weak self] ctx in
            guard let self = self, let item = ctx.node.component.as(VideoItemComponent.self) else {
                return
            }
            self.showVideo(with: item.data.id)
        }
    }

    func render() {
        let topicSectionHeader = ViewNode(SectionHeaderComponent(title: "精选专题") { [weak self] (_) in self?.showTopics() })
        let topicCells = [CellNode(TopicListComponent(items: topics){ [weak self] (index) in
            self?.showTopic(at: index)
        })]
        
        var sections = [Section(id: 0, header: topicSectionHeader,cells: topicCells)]
        for (index, section) in self.hots.enumerated() {
            let cells = section.items.prefix(9).map{ CellNode(VideoItemComponent(data: $0)) }
            let header = ViewNode(SectionHeaderComponent(title: section.title, category: Category(rawValue: index)) { [weak self] (category) in
                guard let category = category else { return }
                self?.showMore(of: category)
            })
            sections.append(Section(id: section.title, header: header, cells: cells))
        }
        renderer.render(sections)
    }

    func showMore(of category: Category) {
        let target = CategoryViewController()
        target.selected = category
        navigationController?.pushViewController(target, animated: true)
    }
    
    func showTopic(at index: Int) {
        let target = TopicViewController()
        let topic = topics[index]
        target.topicId = topic.id
        navigationController?.pushViewController(target, animated: true)
    }

    func showTopics() {
        let target = TopicsViewController()
        target.title = "精选专题"
        navigationController?.pushViewController(target, animated: true)
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        let target =  SettingsViewController()
        let height = view.bounds.height * 0.5
        navigationController?.presentAsStork(target, height: height, showIndicator: true, showCloseButton: false)
    }
}



extension HomeViewController {
    func refresh() {
        attempt(maximumRetryCount: 3) {
            when(fulfilled: APIClient.fetchTopics(),
                 APIClient.fetchHome())
            }.done { topics, hots in
                self.topics = topics
                self.hots = hots
            }.catch{ error in
                print(error)
                self.showError(error)
            }.finally {
                self.render()
                self.collectionView.headRefreshControl.endRefreshing()
        }
    }
}












