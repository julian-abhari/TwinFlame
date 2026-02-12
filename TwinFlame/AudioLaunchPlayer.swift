import Foundation
import AVFoundation

final class AudioLaunchPlayer: NSObject {

    static let shared = AudioLaunchPlayer()

    private var player: AVAudioPlayer?
    private var hasPlayed = false

    // Public entry point
    func playLaunchTrackIfNeeded(date: Date = Date()) {
        guard !hasPlayed else { return }
        hasPlayed = true

        // Decide which track to play
        let trackName = Self.selectLaunchTrackName(for: date)

        // Resolve file at bundle root (no subdirectory anymore)
        guard let url = Self.urlForTrack(named: trackName, ext: "mp3") else {
            print("AudioLaunchPlayer: Missing audio file \(trackName).mp3 at bundle root.")
            Self.debugListRootResources(ext: "mp3")
            return
        }

        // Configure session to interrupt and ignore silent switch
        do {
            try configureAudioSessionForPlayback()
        } catch {
            print("AudioLaunchPlayer: Failed to configure audio session: \(error)")
            // We still attempt to play; AVAudioPlayer may succeed depending on state.
        }

        // Create and play
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = 0
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            self.player = newPlayer
            newPlayer.play()
        } catch {
            print("AudioLaunchPlayer: Failed to start playback: \(error)")
            cleanupAndDeactivateSession()
        }
    }

    // MARK: - Selection

    static func selectLaunchTrackName(for date: Date, calendar: Calendar = .current) -> String {
        let day = calendar.component(.day, from: date)
        return day == 24 ? "Martian Dreams" : "Mars"
    }

    // MARK: - Helpers

    private static func urlForTrack(named name: String, ext: String) -> URL? {
        return Bundle.main.url(forResource: name, withExtension: ext)
    }

    private static func debugListRootResources(ext: String) {
        let rootMP3s = Bundle.main.paths(forResourcesOfType: ext, inDirectory: nil)
        print("AudioLaunchPlayer: .\(ext) at bundle root: \(rootMP3s)")
        print("AudioLaunchPlayer: Bundle path: \(Bundle.main.bundlePath)")
    }

    private func configureAudioSessionForPlayback() throws {
        let session = AVAudioSession.sharedInstance()
        // .playback ignores silent switch and will interrupt other audio by default (no mixing).
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true, options: [])
    }

    private func cleanupAndDeactivateSession() {
        player = nil
        // Deactivate and notify others so their audio can resume.
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            // Non-fatal; just log.
            print("AudioLaunchPlayer: Failed to deactivate session: \(error)")
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioLaunchPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        cleanupAndDeactivateSession()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("AudioLaunchPlayer: Decode error: \(error)")
        }
        cleanupAndDeactivateSession()
    }
}
