import SwiftUI

struct AddHostView: View {
    @Environment(\.dismiss) var dismiss

    // Basic fields
    @State private var name: String
    @State private var remoteHost: String
    @State private var subnetsToForwardString: String
    @State private var forwardDNS: Bool
    @State private var autoAddHostnames: Bool
    
    // Advanced fields
    @State private var excludedSubnetsString: String
    @State private var customSSHCommand: String
    @State private var isAdvancedExpanded: Bool = false
    
    // VPN Mode
    @State private var vpnMode: Bool

    private var hostToEdit: SSHHostConfig?
    var onSave: (SSHHostConfig) -> Void

    // Initializer for adding
    init(onSave: @escaping (SSHHostConfig) -> Void) {
        self.hostToEdit = nil
        _name = State(initialValue: "")
        _remoteHost = State(initialValue: "")
        _subnetsToForwardString = State(initialValue: "0/0")
        _forwardDNS = State(initialValue: false)
        _autoAddHostnames = State(initialValue: false)
        _excludedSubnetsString = State(initialValue: "")
        _customSSHCommand = State(initialValue: "")
        _vpnMode = State(initialValue: false)
        self.onSave = onSave
    }

    // Initializer for editing
    init(host: SSHHostConfig, onSave: @escaping (SSHHostConfig) -> Void) {
        self.hostToEdit = host
        _name = State(initialValue: host.name)
        _remoteHost = State(initialValue: host.remoteHost)
        _subnetsToForwardString = State(initialValue: host.subnetsToForward.joined(separator: ", "))
        _forwardDNS = State(initialValue: host.forwardDNS)
        _autoAddHostnames = State(initialValue: host.autoAddHostnames)
        _excludedSubnetsString = State(initialValue: host.excludedSubnetsString ?? "")
        _customSSHCommand = State(initialValue: host.customSSHCommand ?? "")
        _isAdvancedExpanded = State(initialValue: !(host.excludedSubnetsString?.isEmpty ?? true) || !(host.customSSHCommand?.isEmpty ?? true))
        _vpnMode = State(initialValue: host.vpnMode)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tahoe-style header with refined glass
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.quaternary.opacity(0.3))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: hostToEdit == nil ? "plus.circle.fill" : "pencil.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                                .symbolRenderingMode(.hierarchical)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(hostToEdit == nil ? "New Connection" : "Edit Connection")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Text(hostToEdit == nil ? "Set up a new SSH tunnel" : "Modify connection settings")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(.thinMaterial.opacity(0.8))
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.separator.opacity(0.3))
                        .frame(height: 0.5)
                }

                ScrollView {
                    VStack(spacing: 20) {
                        // Basic Configuration with Tahoe styling
                        VStack(spacing: 16) {
                            HStack {
                                Label("Connection Details", systemImage: "network")
                                    .font(.headline.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .symbolRenderingMode(.hierarchical)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                connectionField(title: "Connection Name", text: $name, placeholder: "Enter a descriptive name")
                                connectionField(title: "Remote Host", text: $remoteHost, placeholder: "user@server.com")
                            }
                        }
                        .padding(20)
                        .background(.thinMaterial.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.separator.opacity(0.2), lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                    
                        // VPN Mode Section with refined Tahoe styling
                        VStack(spacing: 16) {
                            HStack {
                                Label("VPN Configuration", systemImage: "lock.shield")
                                    .font(.headline.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .symbolRenderingMode(.hierarchical)
                                Spacer()
                            }
                            
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("VPN Mode")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.primary)
                                        Text("Route all traffic through this connection")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $vpnMode)
                                        .toggleStyle(.switch)
                                        .tint(.blue)
                                }
                                .onChange(of: vpnMode) { _, newValue in
                                    if newValue {
                                        subnetsToForwardString = "0/0, ::/0"
                                        forwardDNS = true
                                    }
                                }
                                
                                if vpnMode {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(.orange.opacity(0.2))
                                                .frame(width: 24, height: 24)
                                            
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.caption)
                                                .foregroundStyle(.orange)
                                        }
                                        
                                        Text("All IPv4/IPv6 traffic and DNS queries will be routed through this connection")
                                            .font(.caption)
                                            .foregroundStyle(.primary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.orange.opacity(0.2), lineWidth: 0.5)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(.thinMaterial.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.separator.opacity(0.2), lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                    
                        // Manual Routing Section (hidden in VPN mode)
                        if !vpnMode {
                            VStack(spacing: 16) {
                                HStack {
                                    Label("Manual Routing", systemImage: "network.badge.shield.half.filled")
                                        .font(.headline.weight(.medium))
                                        .foregroundStyle(.primary)
                                        .symbolRenderingMode(.hierarchical)
                                    Spacer()
                                }
                                
                                VStack(spacing: 16) {
                                    connectionField(title: "Subnets to Forward", text: $subnetsToForwardString, placeholder: "0/0, 192.168.1.0/24", help: "Use 0/0 for all IPv4, ::/0 for all IPv6")
                                    
                                    HStack {
                                        Text("Forward DNS queries")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.primary)
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: $forwardDNS)
                                            .toggleStyle(.switch)
                                            .tint(.blue)
                                    }
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Auto-detect subnets")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(.primary)
                                            Text("Uses -N flag")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: $autoAddHostnames)
                                            .toggleStyle(.switch)
                                            .tint(.blue)
                                            .disabled(vpnMode)
                                    }
                                }
                            }
                            .padding(20)
                            .background(.thinMaterial.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.separator.opacity(0.2), lineWidth: 0.5)
                            }
                            .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                        }

                        // Advanced Options Section with refined styling
                        VStack(spacing: 16) {
                            DisclosureGroup(isExpanded: $isAdvancedExpanded) {
                                VStack(spacing: 16) {
                                    connectionField(title: "Excluded Subnets", text: $excludedSubnetsString, placeholder: "192.168.1.1, 10.0.5.0/24", help: "Comma-separated list of subnets to exclude from forwarding")
                                    
                                    connectionField(title: "Custom SSH Command", text: $customSSHCommand, placeholder: "ssh -p 2222 -i ~/.ssh/id_rsa", help: "Override the default SSH command with custom options")
                                }
                                .padding(.top, 12)
                            } label: {
                                HStack {
                                    Label("Advanced Options", systemImage: "gearshape.2")
                                        .font(.headline.weight(.medium))
                                        .foregroundStyle(.primary)
                                        .symbolRenderingMode(.hierarchical)
                                    
                                    Spacer()
                                    
                                    if !excludedSubnetsString.isEmpty || !customSSHCommand.isEmpty {
                                        Circle()
                                            .fill(.orange)
                                            .frame(width: 6, height: 6)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(.thinMaterial.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.separator.opacity(0.2), lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)

                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
                // Tahoe-style button bar with refined glass
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .keyboardShortcut(.escape)
                    .tint(.secondary)
                    
                    Spacer()
                    
                    Button(hostToEdit == nil ? "Add Connection" : "Save Changes") {
                        if !name.isEmpty && !remoteHost.isEmpty && !subnetsToForwardString.isEmpty {
                            let subnetsArray = subnetsToForwardString.split(separator: ",")
                                                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                                    .filter { !$0.isEmpty }
                            
                            let finalExcludedSubnets = excludedSubnetsString.trimmingCharacters(in: .whitespacesAndNewlines)
                            let finalCustomSSHCmd = customSSHCommand.trimmingCharacters(in: .whitespacesAndNewlines)

                            var updatedHost = SSHHostConfig(
                                id: hostToEdit?.id ?? UUID(),
                                name: name,
                                remoteHost: remoteHost,
                                subnetsToForward: subnetsArray.isEmpty ? ["0/0"] : subnetsArray,
                                forwardDNS: forwardDNS,
                                autoAddHostnames: autoAddHostnames,
                                excludedSubnetsString: finalExcludedSubnets.isEmpty ? nil : finalExcludedSubnets,
                                customSSHCommand: finalCustomSSHCmd.isEmpty ? nil : finalCustomSSHCmd,
                                vpnMode: vpnMode
                            )
                            if hostToEdit != nil {
                                 updatedHost.status = hostToEdit?.status ?? .disconnected
                            }
                            onSave(updatedHost)
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(name.isEmpty || remoteHost.isEmpty || subnetsToForwardString.isEmpty)
                    .tint(.accentColor)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(.regularMaterial.opacity(0.9))
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(.separator.opacity(0.3))
                        .frame(height: 0.5)
                }
        }
        }
        .background(.clear)
        .frame(width: 580, height: 720)
    }
    
    @ViewBuilder
    private func connectionField(title: String, text: Binding<String>, placeholder: String, help: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.separator.opacity(0.3), lineWidth: 0.5)
                }
            
            if let help = help {
                Text(help)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AddHostView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddHostView(onSave: { _ in })
                .previewDisplayName("Add New Host")
                .frame(height: 500)

            AddHostView(host: SSHHostConfig(name: "Sample Edit Long Name For Advanced Options To Test Wrapping Potentially", remoteHost: "edit@me.com", subnetsToForward: ["1.2.3.0/24"], forwardDNS: true, autoAddHostnames: false, excludedSubnetsString: "1.1.1.1", customSSHCommand: "ssh -p 2200", vpnMode: false), onSave: { _ in })
                .previewDisplayName("Edit Host with Advanced")
                .frame(height: 550)
        }
    }
}
