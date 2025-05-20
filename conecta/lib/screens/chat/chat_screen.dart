// lib/screens/chat/chat_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Pantalla de chat amb estil similar a HomeEstudiantScreen
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

  Future<String?> _fetchAvatarKey(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('usuaris')
        .doc(userId)
        .get();
    return doc.data()?['avatar'] as String?;
  }

  Widget _buildAvatar(String userId, {double radius = 16}) {
    return FutureBuilder<String?>(
      future: _fetchAvatarKey(userId),
      builder: (context, snap) {
        // Ruta per defecte
        String asset = 'assets/avatars/default.png';
        if (snap.hasData && (snap.data?.isNotEmpty ?? false)) {
          var raw = snap.data!;
          // Si ve amb carpeta, ens quedem només amb el nom
          if (raw.contains('/')) raw = raw.split('/').last;
          // Eliminem qualsevol ".png" extra (case-insensitive)
          raw = raw.replaceAll(
            RegExp(r'\.png$', caseSensitive: false),
            '',
          );
          // Recomposem la ruta
          asset = 'assets/avatars/$raw.png';
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CircleAvatar(
            radius: radius,
            backgroundImage: AssetImage(asset),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Afegim AppBar amb botó per tornar enrere
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Xat', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
          SafeArea(
            child: Center(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Espai per separat del AppBar
                    const SizedBox(height: 16),

                    // Missatges
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _missatgesStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error carregant missatges.'),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final missatges = snapshot.data!.docs;
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: missatges.length,
                            itemBuilder: (context, index) {
                              final msg =
                                  missatges[index].data() as Map<String, dynamic>;
                              final autorId = msg['autorId'] as String;
                              final isMe =
                                  autorId == widget.usuariActualId;

                              return Row(
                                mainAxisAlignment: isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  if (!isMe) _buildAvatar(autorId),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? Colors.blueAccent
                                              .withOpacity(0.8)
                                          : Colors.grey.shade300,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      msg['text'] as String,
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isMe) _buildAvatar(autorId),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    // Input
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.orangeAccent),
                            onPressed: _enviarMissatge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
