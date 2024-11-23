import 'package:flutter/material.dart';
import 'package:todolistv1/models/todo.dart';
import 'package:todolistv1/repositories/todo_repository.dart';

import '../widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();
  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoIndex;

  String? errorText;

  @override
  void initState(){
    super.initState();
    todoRepository.getTodoList().then((onValue){
      setState(() {
        todos = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Adicione uma tarefa',
                          hintText: 'Ex. Lavar louças',
                          errorText: errorText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;
                        if(text.isEmpty){
                          setState(() {
                            errorText = 'O Título não pode ser vazio';
                          });
                          return;
                        }
                        setState(() {
                          Todo newTodo = Todo(title: text, dateTime: DateTime.now());
                          todos.add(newTodo);
                          errorText = null;
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        backgroundColor: Colors.lightGreenAccent,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 22,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for(Todo todo in todos)
                        TodoListItem(todo: todo,
                        onDelete: onDelete),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Você possui ${todos.length} tarefas pendentes',
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showDeleteAllConfirmationDialog();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        backgroundColor: Colors.lightGreenAccent,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text(
                        'Limpar tudo',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo){
    deletedTodo = todo;
    deletedTodoIndex = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });

    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
          Text(
            'Tarefa ${todo.title} foi removida com sucesso!',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          backgroundColor: Colors.white,
          action:
          SnackBarAction(
            label: 'Desfazer',
            textColor: Colors.lightGreen,
            onPressed: (){
              setState(() {
                todos.insert(deletedTodoIndex!, deletedTodo!);
              });
              todoRepository.saveTodoList(todos);
            }
          ),
      ),
    );
  }

  void showDeleteAllConfirmationDialog(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deseja Limpar tudo?'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            style: ButtonStyle(foregroundColor: WidgetStateProperty.all<Color>(Colors.lightGreen)),
            child: const Text('Cancelar'),
          ),
          TextButton(
              onPressed: (){
                Navigator.of(context).pop();
                deleteAllTodos();
              },
              style: ButtonStyle(foregroundColor: WidgetStateProperty.all<Color>(Colors.redAccent)),
              child: const Text('Limpar Tudo'))
        ],
      ),
    );
  }

  void deleteAllTodos(){
    setState(() {
      todos.clear();
    });

    todoRepository.saveTodoList(todos);
  }
}

