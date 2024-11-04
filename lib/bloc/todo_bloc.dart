import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Define your todo model
class Todo {
  final String title;
  final DateTime createdAt;

  Todo({
    required this.title,
    required this.createdAt,
  });
}

// Events
abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class AddTodo extends TodoEvent {
  final String title;

  const AddTodo(this.title);

  @override
  List<Object> get props => [title];
}

class Countdown extends TodoEvent {}

class FetchTodos extends TodoEvent {}

// States
class TodoState extends Equatable {
  final List<Todo> todos;
  final Map<String, int> remainingTime;

  const TodoState({
    required this.todos,
    required this.remainingTime,
  });

  TodoState copyWith({
    List<Todo>? todos,
    Map<String, int>? remainingTime,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  @override
  List<Object> get props => [todos, remainingTime];
}

// Bloc
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc() : super(TodoState(todos: [], remainingTime: {})) {
    on<AddTodo>(_onAddTodo);
    on<Countdown>(_onCountdown);
    on<FetchTodos>(_onFetchTodos); // Handle FetchTodos event

    // Start the countdown timer
    Timer.periodic(const Duration(seconds: 1), (timer) {
      add(Countdown());
    });
  }

  void _onAddTodo(AddTodo event, Emitter<TodoState> emit) {
    final newTodo = Todo(
      title: event.title,
      createdAt: DateTime.now(),
    );

    emit(
      state.copyWith(
        todos: List.from(state.todos)..add(newTodo),
        remainingTime: Map.from(state.remainingTime)
          ..[newTodo.title] = 15, // Set 15 seconds initially
      ),
    );
  }

  void _onCountdown(Countdown event, Emitter<TodoState> emit) {
    final updatedTodos = List<Todo>.from(state.todos); // Create a copy of todos
    final updatedRemainingTime = Map<String, int>.from(state.remainingTime);
    final todosToRemove = <Todo>[]; // Temporary list to store todos to remove

    for (final todo in updatedTodos) {
      final timeLeft = updatedRemainingTime[todo.title]! - 1;
      if (timeLeft > 0) {
        updatedRemainingTime[todo.title] = timeLeft;
      } else {
        updatedRemainingTime.remove(todo.title);
        todosToRemove.add(todo); // Add todo to the removal list
      }
    }

    // Remove todos outside the loop
    for (final todo in todosToRemove) {
      updatedTodos.remove(todo);
    }

    emit(state.copyWith(todos: updatedTodos, remainingTime: updatedRemainingTime));
}


  void _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    // Add your logic to fetch to-dos from sqflite or any other storage
    // For now, let's assume we have no stored todos initially
    final todos = <Todo>[]; // Replace with actual fetch logic

    emit(state.copyWith(todos: todos));
  }
}
