import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String ofertaId;
  final String empresaId;
  final String alumneId;
  final String usuariActualId;

  const ChatScreen({
    super.key,
    required this.ofertaId,
    required this.empresaId,
    required this.alumneId,
    required this.usuariActualId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  Stream<QuerySnapshot> _missatgesStream() {
    return FirebaseFirestore.instance
        .collection('missatges_xat')
        .where('ofertaId', isEqualTo: widget.ofertaId)
        .where('empresaId', isEqualTo: widget.empresaId)
        .where('alumneId', isEqualTo: widget.alumneId)
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> _enviarMissatge() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance.collection('missatges_xat').add({
      'ofertaId': widget.ofertaId,
      'empresaId': widget.empresaId,
      'alumneId': widget.alumneId,
      'autorId': widget.usuariActualId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _missatgesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
  print('🔥 Error carregant missatges: ${snapshot.error}');
  return Center(
    child: Text('Error carregant dades. Consulta la terminal.'),
  );
}

if (!snapshot.hasData) {
  return const Center(child: CircularProgressIndicator());
}

                final missatges = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: missatges.length,
                  itemBuilder: (context, index) {
                    final msg = missatges[index].data() as Map<String, dynamic>;
                    final isMe = msg['autorId'] == widget.usuariActualId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blueAccent.withOpacity(0.8)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escriu un missatge...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _enviarMissatge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
