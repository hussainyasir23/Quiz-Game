//
//  SettingsViewController.swift
//  Quiz Game
//
//  Created by Yasir on 27/09/24.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Sound" : "Haptics"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SettingCell")
        cell.selectionStyle = .none
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.text = "In-App Sounds"
            cell.accessoryView = soundSwitch
        case (0, 1):
            cell.textLabel?.text = "Volume"
            cell.textLabel?.textColor = soundSwitch.isOn ? .label : .secondaryLabel
            cell.accessoryView = volumeSlider
        case (1, 0):
            cell.textLabel?.text = "In-App Haptics"
            cell.accessoryView = hapticsSwitch
        default:
            break
        }
        
        return cell
    }
}
