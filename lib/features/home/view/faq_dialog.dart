import 'package:flutter/material.dart';

void showFaqDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Часті запитання (FAQ)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const ExpansionTile(
                title: Text('Як додати новий курс?'),
                children: [Padding(padding: EdgeInsets.all(15.0), child: Text('Натисніть на круглу кнопку "+" внизу екрана та виберіть "Новий курс".'))],
              ),
              const ExpansionTile(
                title: Text('Як додати оцінку?'),
                children: [Padding(padding: EdgeInsets.all(15.0), child: Text('Перейдіть до потрібного курсу, відкрийте вкладку "Оцінки" та натисніть кнопку "+ Додати оцінку".'))],
              ),
              const ExpansionTile(
                title: Text('Де знайти нагадування?'),
                children: [Padding(padding: EdgeInsets.all(15.0), child: Text('Перейдіть до потрібного курсу та відкрийте вкладку "Нагадування".'))],
              ),
              const ExpansionTile(
                title: Text('Як редагувати профіль?'),
                children: [Padding(padding: EdgeInsets.all(15.0), child: Text('Натисніть на пункт меню "Профіль" та скористайтеся кнопкою "Редагувати профіль".'))],
              ),
              const SizedBox(height: 20),
              
            ],
          ),
        ),
      );
    },
  );
}