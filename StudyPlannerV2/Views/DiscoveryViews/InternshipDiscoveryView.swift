//
//  InternshipDiscoveryView.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 24/10/2026.
//

import SwiftUI

struct InternshipDiscoveryView: View {

    /// Displays internship search results and allows users to search, filter, save, and view internship opportunities.
    @ObservedObject var viewModel: InternshipDiscoveryViewModel

    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                header
                results
            }
            .background(Theme.background.ignoresSafeArea())
            .task {
                if !viewModel.hasSearched {
                    await viewModel.search()
                }
            }
            .onAppear {
                viewModel.refreshSavedState()
            }
            .alert("Internship Error", isPresented: showSaveError) {
                Button("OK", role: .cancel) {
                    viewModel.saveErrorMessage = nil
                }
            } message: {
                Text(viewModel.saveErrorMessage ?? "")
            }
        }
    }

    private var showSaveError: Binding<Bool> {
        Binding(
            get: { viewModel.saveErrorMessage != nil },
            set: { if !$0 { viewModel.saveErrorMessage = nil } }
        )
    }

    // MARK: - Header
    /// Displays the search bar, remote filter, and title for the internship discovery screen.
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Discover Internships")
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)

            Text("Explore opportunities across Australia")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search roles, e.g. software", text: $viewModel.searchText)
                    .submitLabel(.search)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit { Task { await viewModel.search() } }
                    .accessibilityLabel("Search internship job titles")

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                        Task { await viewModel.search() }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.leading, 12)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.corner))

            Toggle("Remote opportunities only", isOn: $viewModel.remoteOnly)
                .tint(.accentColor)
                .onChange(of: viewModel.remoteOnly) { _, _ in
                    Task { await viewModel.search() }
                }
        }
        .padding(Theme.padding)
    }

    // MARK: - Results
    /// Displays internship search results, loading states, error messages, and the option to load more internships.
    @ViewBuilder
    private var results: some View {
        if (viewModel.isLoading || !viewModel.hasSearched) && viewModel.opportunities.isEmpty {
            Spacer()
            ProgressView("Finding internships…")
            Spacer()
        } else if viewModel.opportunities.isEmpty {
            Spacer()
            ContentUnavailableView(
                viewModel.searchErrorMessage == nil ? "No Internships Found" : "Unable to Load Internships",
                systemImage: "briefcase",
                description: Text(viewModel.searchErrorMessage ?? "Try another search or turn off the remote filter.")
            )
            Button("Try Again") { Task { await viewModel.search() } }
                .buttonStyle(.borderedProminent)
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let message = viewModel.searchErrorMessage {
                        Label(message, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    ForEach(viewModel.opportunities) { internship in
                        card(internship)
                    }

                    if viewModel.nextCursor != nil {
                        Button {
                            Task { await viewModel.loadMore() }
                        } label: {
                            if viewModel.isLoadingMore {
                                ProgressView()
                            } else {
                                Text("Load More Internships")
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.isLoadingMore)
                        .padding()
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.bottom, Theme.padding)
            }
            .refreshable { await viewModel.search() }
        }
    }

    // MARK: - Card
    /// Creates a card displaying internship details, with options to save the internship or view the job posting.
    private func card(_ internship: DiscoveredInternship) -> some View {
        let saved = viewModel.isSaved(internship)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(internship.title)
                        .font(.headline)
                    Text(internship.companyDisplayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Image(systemName: "briefcase.fill")
                    .foregroundStyle(Color.accentColor)
                    .padding(10)
                    .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            }

            if let location = internship.location, !location.isEmpty {
                Label(location, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let type = internship.employmentType, !type.isEmpty {
                Text(type.capitalized)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.accentColor)
            }

            HStack {
                Button {
                    viewModel.save(internship)
                } label: {
                    Label(saved ? "Saved" : "Save",
                          systemImage: saved ? "bookmark.fill" : "bookmark")
                }
                .buttonStyle(.bordered)
                .disabled(saved)
                .accessibilityLabel(saved ? "Saved \(internship.title)" : "Save \(internship.title)")

                Spacer()

                if let url = internship.applicationURL {
                    Link(destination: url) {
                        Label("View Job", systemImage: "arrow.up.right")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("View job posting for \(internship.title)")
                }
            }
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.corner))
    }
}
