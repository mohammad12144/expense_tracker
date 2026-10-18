import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';

/// واجهة التخزين. الشاشات والـ providers بتتعامل معها بس،
/// فلو بدّلنا Firestore بـ Supabase لاحقًا ما بنغيّر غير هالملف.
abstract class ExpenseRepository {
  Stream<List<Expense>> watch();
  Future<void> add(Expense expense);
  Future<void> remove(Expense expense);
  Future<void> restore(Expense expense);
}

/// المصاريف مخزّنة بـ: users/{uid}/expenses/{id}
class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('expenses');

  @override
  Stream<List<Expense>> watch() => _col
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(_fromDoc).toList());

  @override
  Future<void> add(Expense expense) async {
    await _col.add(_toMap(expense));
  }

  @override
  Future<void> remove(Expense expense) async {
    final id = expense.id;
    if (id == null) return;
    await _col.doc(id).delete();
  }

  /// للـ Undo: بنرجّع نفس الوثيقة بنفس الـ id
  @override
  Future<void> restore(Expense expense) async {
    final id = expense.id;
    if (id == null) {
      await _col.add(_toMap(expense));
    } else {
      await _col.doc(id).set(_toMap(expense));
    }
  }

  Expense _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Expense(
      id: doc.id,
      title: d['title'] as String,
      amount: (d['amount'] as num).toDouble(),
      date: (d['date'] as Timestamp).toDate(),
      category: d['category'] as String,
    );
  }

  Map<String, dynamic> _toMap(Expense e) => {
        'title': e.title,
        'amount': e.amount,
        'date': Timestamp.fromDate(e.date),
        'category': e.category,
      };
}