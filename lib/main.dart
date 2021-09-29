import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature/todo/infrastructure/todo_local_data_source.dart';
import 'feature/todo/infrastructure/todo_repository.dart';
import 'feature/todo/presentation/todo_cubit.dart';
import 'feature/todo/presentation/todo_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TodoLocalDataSource dataSource;
  late final TodoRepository todoRepository;

  @override
  void initState() {
    super.initState();
    dataSource = TodoLocalDataSource();
    todoRepository = TodoRepository(dataSource);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoCubit(todoRepository),
      child: MaterialApp(
        home: const TodoPage(),
        theme: ThemeData(primarySwatch: Colors.amber),
      ),
    );
  }
}
