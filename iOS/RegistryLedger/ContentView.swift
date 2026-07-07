import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingEntry: RegistryLedgerEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    if store.entries.isEmpty {
                        Text("No gifts yet. Tap + to add your first one.")
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.textSecondary)
                            .listRowBackground(Color.clear)
                    }
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .accessibilityIdentifier("entryRow_\(entry.id)")
                        .listRowBackground(Theme.cardBackground)
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Registry Ledger")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if !purchases.isPro && store.isAtFreeLimit {
                            showingPaywall = true
                        } else {
                            showingAdd = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryEditView(entry: nil) { newEntry in
                    let added = store.add(newEntry)
                    if !added {
                        showingPaywall = true
                    }
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditView(entry: entry) { updated in
                    store.update(updated)
                } onDelete: {
                    store.delete(entry)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryRow: View {
    let entry: RegistryLedgerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(entry.giverName)")
                .font(Theme.bodyFont.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
            Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

struct EntryEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: RegistryLedgerEntry
    let isNew: Bool
    let onSave: (RegistryLedgerEntry) -> Void
    var onDelete: (() -> Void)? = nil

    init(entry: RegistryLedgerEntry?, onSave: @escaping (RegistryLedgerEntry) -> Void, onDelete: (() -> Void)? = nil) {
        _draft = State(initialValue: entry ?? RegistryLedgerEntry())
        self.isNew = entry == nil
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Gift Details") {
                    TextField("Givername", text: $draft.giverName)
                    Toggle("Thankyousent", isOn: $draft.thankYouSent)
                    TextField("Notes", text: $draft.notes)
                }
                if !isNew, let onDelete {
                    Section {
                        Button("Delete", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteEntryButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(isNew ? "New Gift" : "Edit Gift")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelEntryButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveEntryButton")
                }
            }
        }
        .tint(Theme.accent)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
