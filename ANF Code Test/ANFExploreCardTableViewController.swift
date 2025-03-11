//
//  ANFExploreCardTableViewController.swift
//  ANF Code Test
//

import UIKit

// MARK: - Models
struct ExploreCard: Codable {
    let title: String
    let backgroundImage: String
    let topDescription: String?
    let promoMessage: String?
    let bottomDescription: String?
    let content: [ExploreContent]?
}

struct ExploreContent: Codable {
    let target: String
    let title: String
}

// MARK: - ExploreCardCell (Custom UITableViewCell for displaying explore cards)
class ExploreCardCell: UITableViewCell {
    static let identifier = "ExploreCardCell"

    let cardImageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let promoLabel = UILabel()
    let bottomDescriptionTextView = UITextView()
    let actionStackView = UIStackView()

    private var card: ExploreCard?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = .white

        setupImageView()
        setupLabels()
        setupTextView()
        setupStackViews()
        setupConstraints()
    }

    private func setupImageView() {
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.clipsToBounds = true
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardImageView)
    }

    private func setupLabels() {
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        promoLabel.font = UIFont.systemFont(ofSize: 11)

        [descriptionLabel, titleLabel, promoLabel].forEach {
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
    }

    private func setupTextView() {
        bottomDescriptionTextView.font = UIFont.systemFont(ofSize: 13)
        bottomDescriptionTextView.isEditable = false
        bottomDescriptionTextView.isScrollEnabled = false
        bottomDescriptionTextView.dataDetectorTypes = [.link]
        bottomDescriptionTextView.textAlignment = .center
        bottomDescriptionTextView.backgroundColor = .clear
        bottomDescriptionTextView.textContainerInset = .zero
        bottomDescriptionTextView.textContainer.lineFragmentPadding = 0
        bottomDescriptionTextView.translatesAutoresizingMaskIntoConstraints =
            false
    }

    private var labelStackView: UIStackView!

    private func setupStackViews() {
        labelStackView = UIStackView(arrangedSubviews: [
            descriptionLabel, titleLabel, promoLabel, bottomDescriptionTextView,
        ])
        labelStackView = UIStackView(arrangedSubviews: [
            descriptionLabel, titleLabel, promoLabel, bottomDescriptionTextView,
        ])
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        labelStackView.alignment = .center
        labelStackView.distribution = .equalSpacing
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelStackView)

        actionStackView.axis = .vertical
        actionStackView.alignment = .fill
        actionStackView.distribution = .fillEqually
        actionStackView.spacing = 8
        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionStackView)
    }

    private func setupConstraints() {
        let aspectRatioConstraint = cardImageView.heightAnchor.constraint(
            equalTo: cardImageView.widthAnchor, multiplier: 9.0 / 16.0)
        aspectRatioConstraint.priority = .defaultHigh

        let dynamicHeightConstraint = cardImageView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: 50)
        dynamicHeightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            cardImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor),
            cardImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor),
            aspectRatioConstraint,
            dynamicHeightConstraint,

            labelStackView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor),
            labelStackView.topAnchor.constraint(
                equalTo: cardImageView.bottomAnchor, constant: 8),
            labelStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            labelStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),

            actionStackView.topAnchor.constraint(
                equalTo: labelStackView.bottomAnchor, constant: 16),
            actionStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            actionStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            actionStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }

    func configure(with card: ExploreCard) {
        self.card = card

        setupText(with: card)
        setupImage(with: card.backgroundImage)
        setupBottomDescription(with: card.bottomDescription)
        setupActionButtons(with: card.content)
    }

    private func setupText(with card: ExploreCard) {
        titleLabel.text = card.title
        descriptionLabel.text = card.topDescription
        promoLabel.text = card.promoMessage
    }

    // Loads the image asynchronously
    private func setupImage(with imageUrl: String) {
        let placeholderImage = UIImage(named: "anf-img-placeholder")
        cardImageView.image = placeholderImage

        ImageBuilder.shared.loadImage(
            from: imageUrl, into: cardImageView,
            placeholder: placeholderImage
        )
    }

    private func setupBottomDescription(with bottomDescription: String?) {
        if let bottomDescription = bottomDescription,
            let attributedString = convertHTMLToAttributedString(
                html: bottomDescription)
        {

            let centeredStyle = NSMutableParagraphStyle()
            centeredStyle.alignment = .center

            let mutableAttributedString = NSMutableAttributedString(
                attributedString: attributedString)
            mutableAttributedString.addAttribute(
                .paragraphStyle, value: centeredStyle,
                range: NSMakeRange(0, mutableAttributedString.length)
            )

            bottomDescriptionTextView.attributedText = mutableAttributedString
        } else {
            bottomDescriptionTextView.text = bottomDescription
        }
    }

    private func setupActionButtons(with content: [ExploreContent]?) {
        actionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        content?.forEach { content in
            let button = createActionButton(title: content.title)
            button.addTarget(
                self, action: #selector(openLink(_:)), for: .touchUpInside)

            let containerView = UIView()
            containerView.addSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor, constant: 16),
                button.trailingAnchor.constraint(
                    equalTo: containerView.trailingAnchor, constant: -16),
                button.topAnchor.constraint(equalTo: containerView.topAnchor),
                button.bottomAnchor.constraint(
                    equalTo: containerView.bottomAnchor),
            ])

            actionStackView.addArrangedSubview(containerView)
        }
    }

    private func createActionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 4
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }

    @objc private func openLink(_ sender: UIButton) {
        if let title = sender.currentTitle,
            let link = card?.content?.first(where: { $0.title == title })?
                .target,
            let url = URL(string: link)
        {
            UIApplication.shared.open(url)
        }
    }

    private func convertHTMLToAttributedString(html: String)
        -> NSAttributedString?
    {
        guard let data = html.data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue,
                ],
                documentAttributes: nil)
        } catch {
            print("Failed to convert HTML: \(error)")
            return nil
        }
    }
}

class ANFExploreCardTableViewController: UITableViewController {

    private var exploreData: [ExploreCard] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchData()
    }

    // MARK: - Setup Methods
    private func setupTableView() {
        tableView.register(
            ExploreCardCell.self,
            forCellReuseIdentifier: ExploreCardCell.identifier)
    }

    // MARK: - Network Call
    private func fetchData() {
        guard
            let url = URL(
                string:
                    "https://www.abercrombie.com/anf/nativeapp/qa/codetest/codeTest_exploreData.css"
            )
        else { return }

        let session = URLSession(configuration: createSessionConfig())
        session.dataTask(with: url) { [weak self] data, _, error in
            self?.handleResponse(data: data, error: error)
        }.resume()
    }

    private func createSessionConfig() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.httpShouldUsePipelining = true
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return config
    }

    private func handleResponse(data: Data?, error: Error?) {
        guard let data = data, error == nil else { return }
        do {
            self.exploreData = try JSONDecoder().decode(
                [ExploreCard].self, from: data)
            DispatchQueue.main.async { self.tableView.reloadData() }
        } catch {
            print("JSON Parsing Error: \(error)")
        }
    }

    override func tableView(
        _ tableView: UITableView, numberOfRowsInSection section: Int
    ) -> Int {
        return exploreData.count
    }

    override func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ExploreCardCell.identifier, for: indexPath)
                as? ExploreCardCell
        else {
            return UITableViewCell()
        }
        cell.configure(with: exploreData[indexPath.row])
        return cell
    }
}
