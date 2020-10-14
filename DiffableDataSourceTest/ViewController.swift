//
//  ViewController.swift
//  DiffableDataSourceTest
//
//  Created by Tsubasa Hiroe on 2020/10/14.
//

import UIKit

class CustomCell: UITableViewCell {

}

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(CustomCell.self, forCellReuseIdentifier: "CustomCell")
            tableView.delegate = self
        }
    }

    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, SectionItem>?
    var dataSource: UITableViewDiffableDataSource<Section, SectionItem>?

    override func viewDidLoad() {
        super.viewDidLoad()
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()

        dataSource = UITableViewDiffableDataSource<Section, SectionItem>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item -> UITableViewCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
                switch item {
                case .menu(item: let item):
                    cell.textLabel?.text = item.id
                case .other(item: let item):
                    cell.textLabel?.text = item.id
                }
                return cell
            }
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()
    }

    func loadItems() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()
        snapshot.appendSections([.menu, .other])
        for i in 0..<20 {
            snapshot.appendItems([
                .menu(item: .init(id: UUID().uuidString, title: "\(i)"))
            ], toSection: .menu)
        }
        for i in 0..<20 {
            var id = "\(i)"
            if i < 5 {
                id = UUID().uuidString
            }
            snapshot.appendItems([
                .other(item: .init(id: id, title: "\(i)"))
            ], toSection: .menu)
        }
        dataSource?.apply(snapshot)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

enum Section {
    case menu
    case other
}

enum SectionItem: Hashable {
    case menu(item: Menu)
    case other(item: Other)

    struct Menu: Hashable {
        let id: String
        let title: String

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }

    struct Other: Hashable {
        let id: String
        let title: String

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}
