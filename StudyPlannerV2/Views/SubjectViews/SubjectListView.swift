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
    @EnvironmentObject var assignmentViewModel: AssignmentViewModel
    @State private var showAddSubject = false
    @State private var editingSubject: Subject?
    
    var body: some View {
        Group {
            if subjectViewModel.subjects.isEmpty {
                ContentUnavailableView(
                    "No Subjects",
                    systemImage: "books.vertical",
                    description: Text("Add your subjects to link them to assignments and placements."))
            } else {
                List {
                    Section {
                        ForEach(subjectViewModel.subjects) { subject in
                            Button {
                                editingSubject = subject
                            } label: {
                                row(for: subject)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: deleteSubjects)
                    } header: {
                        let count = subjectViewModel.subjects.count
                        Text("\(count) \(count == 1 ? "subject" : "subjects")")
                    }
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
            SubjectFormView(subject: nil)
                .environmentObject(subjectViewModel)
        }
        .sheet(item: $editingSubject) { subject in
            SubjectFormView(subject: subject)
                .environmentObject(subjectViewModel)
        }
        .alert(
            "Something Went Wrong",
            isPresented: Binding(
                get: {subjectViewModel.errorMessage != nil && !showAddSubject && editingSubject == nil},
                set: { if !$0 { subjectViewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(subjectViewModel.errorMessage ?? "")
        }
    }

    // MARK: - Row
    
    private func row(for subject: Subject) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "books.vertical")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
                .frame(width: 40, height: 40)
                .background(Color.accentColor.opacity(0.15), in: .rect(cornerRadius: 10))
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(.headline)
                
                Text(detailText(for: subject))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Double tap to edit")
    }
    
    private func detailText(for subject: Subject) -> String {
        let count = assignmentCount(for: subject)
        let assignmentsText = "\(count) \(count == 1 ? "assignment" : "assignments")"
        
        if let code = subject.code {
            return "\(code) · \(assignmentsText)"
        }
        return assignmentsText
    }
    
    // Assignments are linked by subject name, so count the ones whose subject matches.
    private func assignmentCount(for subject: Subject) -> Int {
        var count = 0
        for assignment in assignmentViewModel.assignments {
            if assignment.course.lowercased() == subject.name.lowercased() {
                count += 1
            }
        }
        return count
    }
    
    private func deleteSubjects(at offsets: IndexSet) {
        // Grab the IDs first, because the list reloads after each delete
        var ids: [UUID] = []
        for index in offsets {
            ids.append(subjectViewModel.subjects[index].id)
        }
        for id in ids {
            subjectViewModel.deleteSubject(id: id)
        }
    }
}

struct SubjectFormView: View {
    @EnvironmentObject var subjectViewModel: SubjectViewModel
    @Environment(\.dismiss) private var dismiss
    let subject: Subject?
    
    @State private var name: String
    @State private var code: String
    
    init(subject: Subject?) {
        self.subject = subject
        _name = State(initialValue: subject?.name ?? "")
        _code = State(initialValue: subject?.code ?? "")
    }
    
    private var isEditing: Bool { subject != nil }
    
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
            .navigationTitle(isEditing ? "Edit Subject" : "Add Subject")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        Text(isEditing ? "Save" : "Add")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.onAccent)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accentFill)
                }
            }
            .alert(
                isEditing ? "Can't Save Subject" : "Can't Add Subject",
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
    
    private func save() {
        let saved: Bool
        if let subject {
            saved = subjectViewModel.updateSubject(id: subject.id, name: name, code: code)
        } else {
            saved = subjectViewModel.addSubject(name: name, code: code)
        }
        
        if saved {
            dismiss()
        }
    }
}
    
    #Preview {
        let schema = Schema([StoredSubject.self, StoredAssignment.self, StoredAcademicTask.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let repository = SwiftDataSubjectRepository(container: container)
        
        repository.add(Subject(name: "Advanced iOS Applications", code: "40005"))
        repository.add(Subject(name: "Image Processing", code: "31256"))
        
        return NavigationStack {
            SubjectListView()
                .environmentObject(SubjectViewModel(repository: repository))
                .environmentObject(AssignmentViewModel(repository: SwiftDataAssignmentRepository(container: container)))
        }
    }

