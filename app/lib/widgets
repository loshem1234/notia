import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  
  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showNoteDetails(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Category chip
                  if (note.category != null)
                    Chip(
                      label: Text(
                        note.category!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    const Chip(
                      label: Text(
                        'Categorizing...',
                        style: TextStyle(fontSize: 12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  
                  const Spacer(),
                  
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: Colors.red[400],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Note text (truncated)
              Text(
                note.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              
              const SizedBox(height: 8),
              
              // Footer row
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(note.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  if (note.isDeveloped) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Developed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showNoteDetails(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Category
                if (note.category != null)
                  Chip(
                    label: Text(note.category!),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                
                const SizedBox(height: 16),
                
                // Full text
                Text(
                  note.text,
                  style: const TextStyle(fontSize: 18),
                ),
                
                const SizedBox(height: 24),
                
                // Metadata
                Text(
                  dateFormat.format(note.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                if (note.isDeveloped) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Marked as developed note',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (note.categoryConfidence != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Category confidence: ${(note.categoryConfidence! * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
