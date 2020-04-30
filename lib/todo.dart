class Todo {

  int id;
  final String title;
  final String description;
  final String date;

  Todo(this.title, this.description, this.date);

  factory Todo.fromMap(Map<String, dynamic> data) {
    return Todo(
      data['title'],
      data['description'],
      data['date']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "date": date,
    };
  }
}