//
//  SettingsViewController.swift
//  Quiz Game
//
//  Created by Yasir on 27/09/24.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    private enum SettingSection: Int, CaseIterable {
        
        case sound, haptics, information
        
        var title: String {
            switch self {
            case .sound: return "Sound"
            case .haptics: return "Haptics"
            case .information: return "Information"
            }
        }
        
        var rows: [SettingRow] {
            switch self {
            case .sound: return [.inAppSounds, .volume]
            case .haptics: return [.inAppHaptics]
            case .information: return [.about, .developer]
            }
        }
    }
    
    private enum SettingRow: Equatable {
        
        case inAppSounds, volume, inAppHaptics, about, developer
        
        var title: String {
            switch self {
            case .inAppSounds: return "In-App Sounds"
            case .volume: return "Volume"
            case .inAppHaptics: return "In-App Haptics"
            case .about: return "About"
            case .developer: return "Developer"
            }
        }
        
        var isSelectable: Bool {
            switch self {
            case .about, .developer: return true
            default: return false
            }
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        return tableView
    }()
    
    private lazy var soundSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(soundSwitchValueChanged), for: .valueChanged)
        return switchControl
    }()
    
    private lazy var volumeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.1
        slider.maximumValue = 1
        slider.addTarget(self, action: #selector(volumeSliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    private lazy var hapticsSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(hapticsSwitchValueChanged), for: .valueChanged)
        return switchControl
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettings()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Settings Management
    
    private func loadSettings() {
        soundSwitch.isOn = SoundEffectManager.shared.isSoundEnabled
        volumeSlider.value = SoundEffectManager.shared.volume
        hapticsSwitch.isOn = FeedbackManager.isHapticsEnabled
        updateVolumeSliderState()
    }
    
    private func updateVolumeSliderState() {
        volumeSlider.isEnabled = soundSwitch.isOn
        if let volumeCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) {
            volumeCell.textLabel?.textColor = soundSwitch.isOn ? .label : .secondaryLabel
        }
    }
    
    // MARK: - Action Handlers
    
    @objc private func soundSwitchValueChanged() {
        SoundEffectManager.shared.setSoundEnabled(soundSwitch.isOn)
        SettingsManager.shared.saveSetting(soundSwitch.isOn, for: .sound)
        SoundEffectManager.shared.play(sound: .select)
        updateVolumeSliderState()
    }
    
    @objc private func volumeSliderValueChanged() {
        SoundEffectManager.shared.setVolume(volumeSlider.value)
        SettingsManager.shared.saveSetting(volumeSlider.value, for: .volume)
    }
    
    @objc private func hapticsSwitchValueChanged() {
        FeedbackManager.setHapticsEnabled(hapticsSwitch.isOn)
        SettingsManager.shared.saveSetting(hapticsSwitch.isOn, for: .haptics)
        SoundEffectManager.shared.play(sound: .select)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingSection(rawValue: section)?.rows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingSection(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        guard let settingSection = SettingSection(rawValue: indexPath.section) else {
            return cell
        }
        let settingRow = settingSection.rows[indexPath.row]
        configureCell(cell, for: settingRow)
        return cell
    }
    
    private func configureCell(_ cell: UITableViewCell, for settingRow: SettingRow) {
        cell.textLabel?.text = settingRow.title
        cell.selectionStyle = settingRow.isSelectable ? .default : .none
        switch settingRow {
        case .inAppSounds:
            cell.accessoryView = soundSwitch
        case .volume:
            cell.textLabel?.textColor = soundSwitch.isOn ? .label : .secondaryLabel
            cell.accessoryView = volumeSlider
        case .inAppHaptics:
            cell.accessoryView = hapticsSwitch
        case .about, .developer:
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let settingSection = SettingSection(rawValue: indexPath.section),
              settingSection == .information else {
            return
        }
        
        let settingRow = settingSection.rows[indexPath.row]
        handleInformationSelection(for: settingRow)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func handleInformationSelection(for row: SettingRow) {
        let urlString: String?
        switch row {
        case .about:
            urlString = "https://hussainyasir23.github.io/QuizGame/"
        case .developer:
            urlString = "https://hussainyasir23.github.io/hussainyasir23/"
        default:
            return
        }
        
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return
        }
        
        let webViewController = WebViewController(url: url)
        FeedbackManager.triggerImpactFeedback(of: .light)
        SoundEffectManager.shared.play(sound: .select)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}
