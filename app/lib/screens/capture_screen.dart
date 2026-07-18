import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../services/notes_provider.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isListening = false;
  bool _isDeveloped = false;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }
  
  Future<void> _initSpeech() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _speech.initialize();
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  
  void _startListening() async {
    if (!_speech.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }
    
    setState(() => _isListening = true);
    
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
      },
      listenMode: stt.ListenMode.dictation,
    );
  }
  
  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }
  
  Future<void> _saveNote() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note is empty')),
      );
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      await context.read<NotesProvider>().addNote(
        _textController.text.trim(),
        isDeveloped: _isDeveloped,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Note'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text input area
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Start typing or tap the mic to speak...',
                  border: OutlineInputBorder(),
                ),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Developed note toggle
            SwitchListTile(
              title: const Text('Developed Note'),
              subtitle: const Text('Mark for follow-up questions (Phase 3)'),
              value: _isDeveloped,
              onChanged: (value) {
                setState(() => _isDeveloped = value);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Voice input button
            ElevatedButton.icon(
              onPressed: _isListening ? _stopListening : _startListening,
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(_isListening ? 'Stop Recording' : 'Start Voice Input'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: _isListening ? Colors.red : null,
                foregroundColor: _isListening ? Colors.white : null,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Save button
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveNote,
              icon: const Icon(Icons.save),
              label: const Text('Save Note'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
