import SwiftUI

struct PreferencesView: View {
    @ObservedObject var appDelegate: AppDelegate
    
    @State private var presentedHost: SSHHostConfig? = nil
    @State private var selection: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            if appDelegate.hostConfigurations.isEmpty {
                emptyStateView
            } else {
                connectionsList
            }
            
            // Toolbar
            toolbarView
        }
        .frame(minWidth: 640, minHeight: 560)
        .background(.clear)
        .sheet(item: $presentedHost) { host in
            if host.name.isEmpty && host.remoteHost.isEmpty {
                AddHostView { newHostConfig in
                    appDelegate.hostConfigurations.append(newHostConfig)
                }
            } else {
                AddHostView(host: host) { updatedHostConfig in
                    if let index = appDelegate.hostConfigurations.firstIndex(where: { $0.id == updatedHostConfig.id }) {
                        appDelegate.hostConfigurations[index] = updatedHostConfig
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Label("SSH Connections", systemImage: "network.badge.shield.half.filled")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
            
            Spacer()
            
            if !appDelegate.hostConfigurations.isEmpty {
                Text("\(appDelegate.hostConfigurations.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary.opacity(0.6), in: Capsule())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.thinMaterial.opacity(0.8))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "network.slash")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            
            Text("No Connections")
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
            
            Text("Set up your first SSH tunnel connection to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial.opacity(0.5))
    }
    
    private var connectionsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(appDelegate.hostConfigurations) { hostConfig in
                    connectionCardView(hostConfig)
                }
            }
            .padding(16)
        }
        .background(.ultraThinMaterial.opacity(0.3))
    }
    
    private func connectionCardView(_ hostConfig: SSHHostConfig) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(statusColor(for: hostConfig.status))
                    .frame(width: 10, height: 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(hostConfig.name)
                            .font(.headline.weight(.medium))
                            .foregroundStyle(.primary)
                        
                        if hostConfig.vpnMode {
                            Text("VPN")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.blue, in: Capsule())
                        }
                        
                        Spacer()
                        
                        Text(statusText(for: hostConfig.status))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(statusColor(for: hostConfig.status))
                    }
                    
                    Text(hostConfig.remoteHost)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(.thinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            selection = hostConfig.id
        }
        .overlay {
            if selection == hostConfig.id {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.blue, lineWidth: 2)
            }
        }
    }
    
    private var toolbarView: some View {
        HStack(spacing: 16) {
            Button("New Connection") {
                presentedHost = SSHHostConfig(name: "", remoteHost: "", subnetsToForward: ["0/0"])
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Edit") {
                if let selectedID = selection,
                   let selectedHost = appDelegate.hostConfigurations.first(where: { $0.id == selectedID }) {
                    presentedHost = selectedHost
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(selection == nil)
            
            Button("Delete") {
                removeSelectedHost()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(selection == nil)
            .tint(.red)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.regularMaterial.opacity(0.9))
    }

    private func removeSelectedHost() {
        guard let selectedID = selection else { return }
        appDelegate.hostConfigurations.removeAll { $0.id == selectedID }
        selection = nil
    }
    
    private func statusColor(for status: ConnectionStatus) -> Color {
        switch status {
        case .connected: return .green
        case .connecting: return .orange
        case .error: return .red
        case .disconnected: return .secondary
        }
    }
    
    private func statusText(for status: ConnectionStatus) -> String {
        switch status {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .error: return "Error"
        case .disconnected: return "Disconnected"
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyAppDelegate = AppDelegate()
        dummyAppDelegate.hostConfigurations.append(
            SSHHostConfig(name: "Preview Host", remoteHost: "user@preview", subnetsToForward: ["0/0"], forwardDNS: true, autoAddHostnames: true, excludedSubnetsString: "10.0.0.1", customSSHCommand: "ssh -X", vpnMode: false)
        )
        return PreferencesView(appDelegate: dummyAppDelegate)
    }
}