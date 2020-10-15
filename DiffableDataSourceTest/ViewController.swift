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
        setupNav()
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()

        dataSource = UITableViewDiffableDataSource<Section, SectionItem>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item -> UITableViewCell? in
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
                switch item {
                case .menu(item: let item):
                    cell.textLabel?.text = item.title
                    cell.backgroundColor = .yellow
                case .other(item: let item):
                    cell.textLabel?.text = item.title
                    cell.backgroundColor = .green
                }
                return cell
            }
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()
    }

    private func setupNav() {
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddItemButton))
        let delete = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapRemoveItemButton))
        let reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapReloadItemButton))
        let reset = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(didTapResetItemButton))
        navigationItem.rightBarButtonItems = [add, delete, reload, reset]
    }

    @objc private func didTapAddItemButton() {
        guard var updatedSnapshot = dataSource?.snapshot() else { return }
        // 追加するときセクションがなければ追加する
        if !updatedSnapshot.sectionIdentifiers.contains(.menu) {
            updatedSnapshot.appendSections([.menu])
        }
        let id = UUID().uuidString
        updatedSnapshot.appendItems([
            .menu(item: .init(id: id, title: id))
        ], toSection: .menu)
        dataSource?.apply(updatedSnapshot)
    }

    @objc private func didTapRemoveItemButton() {
        guard var updatedSnapshot = dataSource?.snapshot() else { return }
        updatedSnapshot.deleteAllItems()
        dataSource?.apply(updatedSnapshot)
    }

    @objc private func didTapReloadItemButton() {
        guard var updatedSnapshot = dataSource?.snapshot() else { return }
        updatedSnapshot.appendItems([
            .menu(item: .init(id: UUID().uuidString, title: "Reloaded"))
        ], toSection: .menu)
        dataSource?.apply(updatedSnapshot, animatingDifferences: true, completion: nil)
    }

    @objc private func didTapResetItemButton() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()
        snapshot.appendSections([.menu, .other])
        for i in 0..<3 {
            snapshot.appendItems([
                .menu(item: .init(id: "\(i)", title: "new-\(i)"))
            ], toSection: .menu)
        }
        dataSource?.apply(snapshot)
    }

    func loadItems() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()
        snapshot.appendSections([.menu, .other])
        for i in 0..<3 {
            snapshot.appendItems([
                .menu(item: .init(id: "\(i)", title: "1-\(i)"))
            ], toSection: .menu)
        }
        dataSource?.apply(snapshot)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

enum Section: Hashable {
    case menu
    case other
}

enum SectionItem: Hashable {
    case menu(item: Menu)
    case other(item: Other)

    struct Menu: Hashable {
        let id: String
        let title: String
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
