import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ToDoListPage extends StatefulWidget {
  final DateTime selectedDate;

  ToDoListPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  DatabaseReference database = FirebaseDatabase.instance.ref();

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _getTasksFromFirebase(); // Inicializa Tarefas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tarefas - ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,

        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    tasks[index].name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      decoration: tasks[index].isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: tasks[index].isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      tasks[index].isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: tasks[index].isCompleted ? Colors.green : Colors.black45,
                    ),
                    onPressed: () {
                      _toggleTaskCompletion(index);
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          _toggleTaskCompletion(index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeTask(index);
                        },
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showRemoveAllTasksDialog(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
                    textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  child: Text('Remover Todas'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: CircleBorder(),
      ),
    );
  }

  void _getTasksFromFirebase() async {
    String formattedDate =
        '${widget.selectedDate.day}${widget.selectedDate.month}${widget.selectedDate.year}';
    DatabaseReference tasksNodeRef = database.child('calendar/$formattedDate/');
    try {
      final DataSnapshot snapshot = await tasksNodeRef.get();

      final List<Task> loadedTasks = [];

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((taskId, taskData) {
          if (taskData != null && taskData is Map) {
            loadedTasks.add(Task.fromJson(taskData, taskId as String));
          }
        });
      }

      setState(() {
        tasks = loadedTasks;
      });

    } catch (error) {
      print("Erro ao buscar tarefas: $error");
      setState(() {
        tasks = [];
      });
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    String newTaskName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Tarefa'),
          content: TextField(
            onChanged: (value) {
              newTaskName = value;
            },
            decoration: InputDecoration(hintText: 'Nome da tarefa'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (newTaskName.trim().isNotEmpty) {
                  String formattedDate =
                      '${widget.selectedDate.day}${widget.selectedDate.month}${widget.selectedDate.year}';

                  Task newTaskData = Task(name: newTaskName);

                  DatabaseReference newRef = database
                      .child('calendar/$formattedDate/')
                      .push();

                  String? firebaseId = newRef.key; // Pega o ID

                  if (firebaseId != null) {
                    try {
                      await newRef.set(newTaskData.toJson());

                      setState(() {
                        newTaskData.setIdFirebase(firebaseId); // Add ID na Task
                        tasks.add(newTaskData); // Add a Task na lista de tarefas
                      });
                      print('Tarefa adicionada com ID: $firebaseId');

                    } catch (error) {
                      print("Erro ao adicionar tarefa: $error");
                    }
                  } else {
                    print("Erro ao gerar ID para a tarefa.");
                  }
                }
                Navigator.pop(context);
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveAllTasksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remover todas as Tarefas'),
          content: Text('Tem certeza que deseja remover todas as tarefas?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String formattedDate =
                    '${widget.selectedDate.day}${widget.selectedDate.month}${widget.selectedDate.year}';
                DatabaseReference dayTasksRef =
                database.child('calendar/$formattedDate');

                try {
                  await dayTasksRef.remove(); // Remote todas as tasks do dia no  Firebase
                  print('Todas as tarefas para $formattedDate removidas do Firebase.');

                  setState(() {
                    tasks.clear(); // Remove todas as tasks da lista de tarefas no app
                  });

                  Navigator.pop(context);

                } catch (error) {
                  print("Erro ao remover todas as tarefas do dia $formattedDate: $error");
                  Navigator.pop(context);
                }
              },
              child: Text('Remover todas'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTaskCompletion(int index) async {
    if (index < 0 || index >= tasks.length) return;

    Task taskToUpdate = tasks[index];

    if (taskToUpdate.idFirebase == null || taskToUpdate.idFirebase!.isEmpty) {
      print("Erro: A tarefa não tem um ID do Firebase para atualização.");

      return;
    }

    setState(() {
      taskToUpdate.isCompleted = !taskToUpdate.isCompleted; // Atualiza o status no app
    });

    String formattedDate =
        '${widget.selectedDate.day}${widget.selectedDate.month}${widget.selectedDate.year}';
    String firebaseTaskId = taskToUpdate.idFirebase!;
    DatabaseReference taskRef =
      database.child('calendar/$formattedDate/$firebaseTaskId');

    try {
      // Atualize apenas o campo 'isCompleted' no Firebase
      await taskRef.update({
        'isCompleted': taskToUpdate.isCompleted,
      });
      print('Status da tarefa $firebaseTaskId atualizado para: ${taskToUpdate.isCompleted}');
    } catch (error) {
      print("Erro ao atualizar status da tarefa no Firebase: $error");
      // Se a atualização do Firebase falhar, desfaz a mudança no app
      setState(() {
        taskToUpdate.isCompleted = !taskToUpdate.isCompleted; // Desfaz a mudança no app
      });
    }
  }

  void _removeTask(int index) async {
    if (index < 0 || index >= tasks.length) return;

    Task taskToRemove = tasks[index];

    if (taskToRemove.idFirebase == null || taskToRemove.idFirebase!.isEmpty) {
      print("Erro: ID do Firebase não encontrado.");
      return;
    }

    String formattedDate =
        '${widget.selectedDate.day}${widget.selectedDate.month}${widget.selectedDate.year}';
    String firebaseTaskId = taskToRemove.idFirebase!;
    DatabaseReference taskRef =
    database.child('calendar/$formattedDate/$firebaseTaskId');

    try {
      await taskRef.remove();
      setState(() {
        tasks.removeAt(index);
      });
      print('Tarefa $firebaseTaskId removida do Firebase.');

    } catch (error) {
      print("Erro ao remover tarefa do Firebase: $error");
    }
  }
}

class Task {
  String name;
  bool isCompleted;
  String? idFirebase;

  Task({required this.name, this.isCompleted = false});

  void setIdFirebase(id) {
    this.idFirebase = id;
  }

  // Recebe um JSon do Firebase e transforma em uma Task
  factory Task.fromJson(Map<dynamic, dynamic> json, String id) {
    Task newTask = Task(
      name: json['name'] as String? ?? 'Sem nome', // Lida com nome nulo
      isCompleted: json['isCompleted'] as bool? ?? false, // Lida com isCompleted nulo
    );
    newTask.setIdFirebase(id);
    return newTask;
  }

  // Transforma em JSon para enviar ao Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
    };
  }
}
