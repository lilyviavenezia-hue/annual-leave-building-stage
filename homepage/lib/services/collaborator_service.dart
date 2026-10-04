import '../mock/mock_collaborators.dart';
import '../models/collaborator.dart';

class CollaboratorService {
  Future<List<Collaborator>> getCollaborators() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockCollaboratorsList.map((json) => Collaborator.fromJson(json)).toList();
  }

  Future<List<Collaborator>> searchCollaborators(String query) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (query.isEmpty) return [];
    
    final all = [
      ...mockCollaboratorsList,
      ...mockSearchSuggestions,
    ].map((json) => Collaborator.fromJson(json)).toList();

    return all.where((c) =>
      c.name.toLowerCase().contains(query.toLowerCase()) ||
      c.email.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}