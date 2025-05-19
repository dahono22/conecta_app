// lib/screens/chat/chat_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Widget amb estat per gestionar el xat, ara mostrant avatar de l'autor en cada missatge.
class ChatScreen extends StatefulWidget {
  final String ofertaId;        // ID de l'oferta a la qual fa referència el xat
  final String empresaId;       // ID de l'empresa que ha creat l'oferta
  final String alumneId;        // ID de l'alumne amb qui es fa el xat
  final String usuariActualId;  // ID de l'usuari que ha iniciat la sessió (autor dels missatges)

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
  final _controller = TextEditingController(); // Controlador pel TextField

  /// Stream per escoltar els missatges en temps real
  Stream<QuerySnapshot> _missatgesStream() {
    return FirebaseFirestore.instance
        .collection('missatges_xat')
        .where('ofertaId', isEqualTo: widget.ofertaId)
        .where('empresaId', isEqualTo: widget.empresaId)
        .where('alumneId', isEqualTo: widget.alumneId)
        .orderBy('timestamp')
        .snapshots();
  }

  /// Envia un missatge al xat
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

  /// Recupera la clau d'avatar des de Firestore per un usuari
  Future<String?> _fetchAvatarKey(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('usuaris')
        .doc(userId)
        .get();
    return doc.data()?['avatar'] as String?;
  }

  /// Construeix un CircleAvatar a partir de la clau retornada
  Widget _buildAvatar(String userId, {double radius = 16}) {
    return FutureBuilder<String?>(
      future: _fetchAvatarKey(userId),
      
      builder: (context, snap) {
        // Ruta per defecte si no hi ha avatar
        String asset = 'assets/avatars/default.png';

        if (snap.hasData && (snap.data?.isNotEmpty ?? false)) {
          String raw = snap.data!;

          // Si ve amb ruta completa, n'agafem només el nom de fitxer
          if (raw.contains('/')) {
            raw = raw.split('/').last;
          }
          // Si ve amb extensió .png, la traiem
          raw = raw.replaceAll(RegExp(r'\.png$', caseSensitive: false), '');

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
                  return const Center(
                    child: Text('Error carregant missatges.'),
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
                    final autorId = msg['autorId'] as String;
                    final isMe = autorId == widget.usuariActualId;

                    return Row(
                      mainAxisAlignment:
                          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) _buildAvatar(autorId),
                        Container(
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
                            msg['text'] as String,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
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
