import 'dart:convert';

class Course {
  final int idcours;
  final String idEnseignant;
  final String enseignant;
  final String matiere;
  final String type;
  final String date;
  final List<Document> documents;

  Course({
    required this.idcours,
    required this.idEnseignant,
    required this.enseignant,
    required this.matiere,
    required this.type,
    required this.date,
    required this.documents,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var list = json['documents'] as List;
    List<Document> documentsList =
        list.map((document) => Document.fromJson(document)).toList();

    return Course(
      idcours: json['idcours'] != null ? json['idcours'] as int : 0,
      idEnseignant: json['idEnseignant'].toString(),
      enseignant: json['Enseignant'].toString(),
      matiere: json['Matiere'].toString(),
      type: json['type'].toString(),
      date: json['date'].toString(),
      documents: documentsList,
    );
  }
}

class Document {
  final String idDocument;
  final String document;
  final String titre;

  Document({
    required this.idDocument,
    required this.document,
    required this.titre,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      idDocument: json['idDocument'].toString(),
      document: json['document'].toString(),
      titre: json['titre'].toString(),
    );
  }
}
