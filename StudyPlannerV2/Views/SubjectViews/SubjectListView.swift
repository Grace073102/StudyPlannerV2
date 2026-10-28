//
//  SubjectListView.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 22/10/2026.
//

import SwiftUI
import SwiftData

struct SubjectListView: View {
    @EnvironmentObject var subjectViewModel: SubjectViewModel
    @State private var showAddSubject = false
    
    var body: some View {
        Group {
            if subjectViewModel.subjects.isEmpty {
                ContentUnavailableView(
                    "No Subjects",
                    systemImage: "books.vertical",
                description: Text("Add your subjects to link them to assignments and placements."))
            } else {
                List {
                    ForEach(subjectViewModel.subjects) { subject in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subject.name)
                                .font(.headline)
                            
                            if let code = subject.code {
                                Text(code)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(minHeight: 44, alignment: .leading)
                    }
                    .onDelete(perform: deleteSubjects)
                }
            }
        }
        .background(Theme.background)
        .navigationTitle("Subjects")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSubject = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Subject")
            }
        }
        .sheet(isPresented: $showAddSubject) {
            AddSubjectView()
                .environmentObject(subjectViewModel)
        }
        .alert(
            "Something Went Wrong",
            isPresented: Binding(
                get: {subjectViewModel.errorMessage != nil && !showAddSubject},
                set: { if !$0 { subjectViewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(subjectViewModel.errorMessage ?? "")
        }
    }
    
    private func deleteSubjects(at offsets: IndexSet) {
        var ids: [UUID] = []
        for index in offsets {
            ids.append(subjectViewModel.subjects[index].id)
        }
        for id in ids {
            subjectViewModel.deleteSubject(id: id)
        }
    }
}

struct AddSubjectView: View {
    @EnvironmentObject var subjectViewModel: SubjectViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var code = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Subject Name") {
                    TextField("e.g. Advanced iOS Applications", text: $name)
                }
                Section("Subject Code (Optional)") {
                    TextField("e.g. 40005", text: $code)
                }
            }
            .navigationTitle("Add Subject")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if subjectViewModel.addSubject(name: name, code: code) {
                            dismiss()
                        }
                    } label: {
                        Text("Add")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.onAccent)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accentFill)
                }
            }
            .alert(
                "Can't Add Subject",
                isPresented: Binding(
                    get: { subjectViewModel.errorMessage != nil },
                    set: { if !$0 { subjectViewModel.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(subjectViewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    let schema = Schema([StoredSubject.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    let repository = SwiftDataSubjectRepository(container: container)

    repository.add(Subject(name: "Advanced iOS Applications", code: "40005"))
    repository.add(Subject(name: "Image Processing", code: "31256"))

    return NavigationStack {
        SubjectListView()
            .environmentObject(SubjectViewModel(repository: repository))
    }
}
