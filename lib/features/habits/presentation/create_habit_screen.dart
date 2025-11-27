import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/habit.dart';
import '../data/habit_provider.dart';
import 'habit_view_model.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  final Habit? habitToEdit;

  const CreateHabitScreen({super.key, this.habitToEdit});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = '✅';
  String _selectedCategory = 'Health';
  int _durationMinutes = 2;

  final List<String> _categories = ['Health', 'Productivity', 'Wellness', 'Learning', 'Fitness'];
  final List<int> _durations = [2, 3, 5, 8, 10, 15];
  final List<String> _icons = ['✅', '💧', '🏃', '📚', '🧘', '💪', '🍎', '💤', '💻', '🎨'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      final habit = widget.habitToEdit!;
      _nameController.text = habit.name;
      _selectedIcon = habit.icon;
      _selectedCategory = habit.category;
      _durationMinutes = habit.durationMinutes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final name = _nameController.text.trim();

        if (widget.habitToEdit != null) {
          // Edit mode
          final updatedHabit = widget.habitToEdit!.copyWith(
            name: name,
            icon: _selectedIcon,
            category: _selectedCategory,
            durationMinutes: _durationMinutes,
            updatedAt: DateTime.now(),
          );
          await ref.read(habitRepositoryProvider).updateHabit(updatedHabit);
        } else {
          // Create mode
          await ref
              .read(habitViewModelProvider.notifier)
              .addHabit(
                name: name,
                icon: _selectedIcon,
                category: _selectedCategory,
                durationMinutes: _durationMinutes,
              );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.habitToEdit != null
                    ? 'Habit updated successfully!'
                    : 'Habit created successfully!',
              ),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to create habit: $e'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
              ],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Habit' : 'New Habit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                hintText: 'e.g., Drink Water',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            Text('Icon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 16),

            Text('Duration', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _durations.map((duration) {
                  final isSelected = _durationMinutes == duration;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('$duration min'),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _durationMinutes = duration;
                        });
                      },
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEditing ? 'Save Changes' : 'Create Habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
