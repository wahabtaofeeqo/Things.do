class Todo {

  int id;
  int status;
  String title;
  String description;
  String date;

  Todo();

  factory Todo.fromMap(Map<String, dynamic> data) {
    Todo todo = new Todo();
    todo.id = data['id'];
    todo.status = data['status'];
    todo.title = data['title'];
    todo.description = data['description'];
    todo.date = data['date'];

    return todo;
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "date": date,
      "status": status,
    };
  }
}